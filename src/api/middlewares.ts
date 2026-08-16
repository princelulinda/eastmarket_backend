import {
  defineMiddlewares,
  authenticate,
  validateAndTransformBody,
  MedusaRequest,
  MedusaResponse,
  MedusaNextFunction,
} from "@medusajs/framework/http"
import { AdminCreateProduct, AdminUpdateProduct } from "@medusajs/medusa/api/admin/products/validators"
import { PostVendorCreateSchema } from "./vendors/route"
import { PostConversationSchema } from "./store/chat/conversations/route"
import { PutVendorMeSchema } from "./vendors/me/route"
import { PostVendorAdminSchema } from "./vendors/admins/route"
import { PutVendorAdminSchema } from "./vendors/admins/[id]/route"
import { PostFulfillOrderSchema } from "./vendors/orders/[id]/fulfill/route"
import { PostShipmentOrderSchema } from "./vendors/orders/[id]/fulfillments/[fulfillment_id]/shipments/route"
import { PostVendorVideoSchema } from "./vendors/videos/route"
import { PutVendorVideoSchema } from "./vendors/videos/[id]/route"
import { PostVendorStockLocationSchema } from "./vendors/stock-locations/route"
import { PostVendorPromotionSchema } from "./vendors/promotions/route"
import { PostVendorFlashSaleSchema } from "./vendors/flash-sales/route"
import { PostActivitySchema } from "./store/activity/route"
import { PostApplyReferralSchema } from "./store/customers/me/referral/apply/route"
import { PostVerifyEmailSchema } from "./store/customers/me/verify-email/route"
import { PostRegisterStartSchema } from "./store/auth/register/start/route"
import { PostRegisterConfirmSchema } from "./store/auth/register/confirm/route"
import { PostRegisterResendSchema } from "./store/auth/register/resend/route"
import { requireVerifiedEmail } from "./middlewares/require-verified-email"
import { PostVendorPayoutSchema } from "./vendors/payouts/route"
import { PostVendorInventorySchema } from "./vendors/products/[id]/variants/[variant_id]/inventory/route"
import { trackProductClick } from "./middlewares/analytics"
import { PostCommentSchema } from "./store/videos/[id]/comments/route"
import { PostAdminCreateDeliveryCompanySchema } from "./admin/delivery-companies/route"
import { PostAdminCreateDeliveryDriverSchema } from "./admin/delivery-companies/[id]/drivers/route"
import { PostAdminRejectPayoutSchema } from "./admin/payouts/[id]/reject/route"
import multer from "multer"
import { ContainerRegistrationKeys, Modules } from "@medusajs/framework/utils"
import jwt from "jsonwebtoken"
import { MARKETPLACE_MODULE } from "../modules/marketplace"

/**
 * Maps short provider aliases to their full Medusa container key.
 * Format: pp_{identifier}_{config_id}
 * Add new providers here as needed.
 */
const PROVIDER_ID_MAP: Record<string, string> = {
  "kashflow":       "pp_kashflow_kashflow",
  "stripe":         "pp_stripe_stripe",
  "mbiyopay":       "pp_mbiyopay_mbiyopay",
  "system_default": "pp_system_default",
}

/**
 * Normalises the `provider_id` in payment-session creation requests.
 * The storefront may send short IDs like "kashflow"; Medusa's container
 * requires the full key "pp_kashflow_kashflow". This middleware transparently
 * remaps the value before the workflow runs.
 */
function normalizePaymentProviderId(
  req: MedusaRequest,
  _res: MedusaResponse,
  next: MedusaNextFunction
) {
  const body = req.body as Record<string, unknown>
  if (body?.provider_id && typeof body.provider_id === "string") {
    const mapped = PROVIDER_ID_MAP[body.provider_id]
    if (mapped) {
      body.provider_id = mapped
    }
  }
  next()
}


/**
 * Validates the cart has a region/currency and that all requested variants
 * have a price in that currency before Medusa's addToCart workflow runs.
 * Without this, Medusa crashes with "Cannot read properties of undefined (reading 'calculated_amount')".
 */
async function validateCartRegion(
  req: MedusaRequest,
  res: MedusaResponse,
  next: MedusaNextFunction
) {
  try {
    const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
    const cartId = req.params.id

    const { data: [cart] } = await query.graph({
      entity: "cart",
      fields: ["id", "region_id", "currency_code", "region.currency_code"],
      filters: { id: cartId },
    })

    if (!cart) {
      res.status(404).json({ message: "Cart not found" })
      return
    }

    const cartCurrency: string | undefined =
      (cart as any).currency_code ?? (cart as any).region?.currency_code

    if (!(cart as any).region_id && !cartCurrency) {
      res.status(400).json({
        message: "Cart must have a region_id before adding items. Create the cart with a region_id.",
        type: "invalid_data",
      })
      return
    }

    // Check that the requested variant has a price in the cart's currency.
    // POST /store/carts/:id/line-items takes a single { variant_id, quantity }
    // body (see @medusajs/medusa's StoreAddCartLineItem validator) — NOT a
    // batch { items: [...] } array. Reading body.items here always produced
    // an empty list, so this check silently never ran and let un-priced
    // variants through to crash later in Medusa's own pricing workflow.
    const body = req.body as { variant_id?: string }
    const variantIds = body?.variant_id ? [body.variant_id] : []

    if (variantIds.length > 0 && cartCurrency) {
      const { data: variants } = await query.graph({
        entity: "variant",
        fields: ["id", "price_set.prices.currency_code"],
        filters: { id: variantIds },
      })

      const missingPrice: string[] = []
      for (const variant of variants) {
        const prices: Array<{ currency_code: string }> =
          (variant as any).price_set?.prices ?? []
        const hasPrice = prices.some((p) => p.currency_code === cartCurrency)
        if (!hasPrice) {
          missingPrice.push(variant.id)
        }
      }

      if (missingPrice.length > 0) {
        res.status(400).json({
          message: `Variants ${missingPrice.join(", ")} do not have a price in currency "${cartCurrency}". Add prices for both "eur" and "usd" when creating the product.`,
          type: "invalid_data",
        })
        return
      }
    }

    next()
  } catch (err) {
    next(err)
  }
}

const upload = multer()

async function linkGoogleAccountMiddleware(
  req: MedusaRequest,
  res: MedusaResponse,
  next: MedusaNextFunction
) {
  const originalJson = res.json
  const originalRedirect = res.redirect

  // Override res.json
  res.json = function (this: any, body: any) {
    if (body && typeof body === "object" && typeof body.token === "string") {
      const configModule = req.scope.resolve("configModule")
      const jwtSecret = configModule.projectConfig.http.jwtSecret || "supersecret"

      try {
        const decoded = jwt.verify(body.token, jwtSecret) as any

        if (decoded && decoded.auth_identity_id && !decoded.actor_id) {
          const authIdentityId = decoded.auth_identity_id
          const actorType = decoded.actor_type || "customer"
          const email = decoded.user_metadata?.email
          const name = decoded.user_metadata?.name || ""
          const givenName = decoded.user_metadata?.given_name || name.split(" ")[0] || ""
          const familyName = decoded.user_metadata?.family_name || name.split(" ").slice(1).join(" ") || ""
          console.log(decoded.user_metadata)
          if (email) {
            (async () => {
              try {
                let actorId = ""

                if (actorType === "customer") {
                  const customerModule = req.scope.resolve(Modules.CUSTOMER)
                  const remoteLink = req.scope.resolve("remoteLink")

                  const customers = await customerModule.listCustomers({ email })
                  let customer = customers[0]

                  if (!customer) {
                    customer = await customerModule.createCustomers({
                      email,
                      first_name: givenName,
                      last_name: familyName,
                    })
                  }

                  actorId = customer.id

                  try {
                    await remoteLink.create({
                      [Modules.CUSTOMER]: {
                        customer_id: customer.id,
                      },
                      [Modules.AUTH]: {
                        auth_identity_id: authIdentityId,
                      },
                    })
                  } catch (e) {
                    // ignore if link exists
                  }

                  const authModule = req.scope.resolve(Modules.AUTH)
                  await authModule.updateAuthIdentities([
                    {
                      id: authIdentityId,
                      app_metadata: {
                        customer: customer.id,
                      },
                    },
                  ])
                } else if (actorType === "vendor") {
                  const marketplaceModule = req.scope.resolve(MARKETPLACE_MODULE)
                  const vendorAdmins = await marketplaceModule.listVendorAdmins({ email })
                  const vendorAdmin = vendorAdmins[0]

                  if (vendorAdmin) {
                    actorId = vendorAdmin.id
                    const authModule = req.scope.resolve(Modules.AUTH)
                    await authModule.updateAuthIdentities([
                      {
                        id: authIdentityId,
                        app_metadata: {
                          vendor: vendorAdmin.id,
                        },
                      },
                    ])
                  }
                }

                if (actorId) {
                  const newPayload = {
                    ...decoded,
                    actor_id: actorId,
                  }
                  if (!newPayload.app_metadata) {
                    newPayload.app_metadata = {}
                  }
                  newPayload.app_metadata[actorType] = actorId

                  const { iat, exp, ...payloadToSign } = newPayload
                  const newToken = jwt.sign(payloadToSign, jwtSecret, { expiresIn: "24h" })
                  
                  body.token = newToken
                }
              } catch (err) {
                console.error("Error in linkGoogleAccountMiddleware async logic:", err)
              } finally {
                originalJson.call(this, body)
              }
            })()
            return this
          }
        }
      } catch (err) {
        // ignore
      }
    }
    return originalJson.call(this, body)
  }

  // Override res.redirect
  ;(res as any).redirect = function (this: any, url: string) {
    let urlObj: URL
    try {
      urlObj = new URL(url, "http://localhost")
    } catch (e) {
      return originalRedirect.call(this, url)
    }

    const token = urlObj.searchParams.get("token")

    if (token) {
      const configModule = req.scope.resolve("configModule")
      const jwtSecret = configModule.projectConfig.http.jwtSecret || "supersecret"

      try {
        const decoded = jwt.verify(token, jwtSecret) as any

        if (decoded && decoded.auth_identity_id && !decoded.actor_id) {
          const authIdentityId = decoded.auth_identity_id
          const actorType = decoded.actor_type || "customer"
          const email = decoded.user_metadata?.email
          const name = decoded.user_metadata?.name || ""
          const givenName = decoded.user_metadata?.given_name || name.split(" ")[0] || ""
          const familyName = decoded.user_metadata?.family_name || name.split(" ").slice(1).join(" ") || ""

          if (email) {
            (async () => {
              try {
                let actorId = ""

                if (actorType === "customer") {
                  const customerModule = req.scope.resolve(Modules.CUSTOMER)
                  const remoteLink = req.scope.resolve("remoteLink")

                  const customers = await customerModule.listCustomers({ email })
                  let customer = customers[0]

                  if (!customer) {
                    customer = await customerModule.createCustomers({
                      email,
                      first_name: givenName,
                      last_name: familyName,
                    })
                  }

                  actorId = customer.id

                  try {
                    await remoteLink.create({
                      [Modules.CUSTOMER]: {
                        customer_id: customer.id,
                      },
                      [Modules.AUTH]: {
                        auth_identity_id: authIdentityId,
                      },
                    })
                  } catch (e) {
                    // ignore if link exists
                  }

                  const authModule = req.scope.resolve(Modules.AUTH)
                  await authModule.updateAuthIdentities([
                    {
                      id: authIdentityId,
                      app_metadata: {
                        customer: customer.id,
                      },
                    },
                  ])
                } else if (actorType === "vendor") {
                  const marketplaceModule = req.scope.resolve(MARKETPLACE_MODULE)
                  const vendorAdmins = await marketplaceModule.listVendorAdmins({ email })
                  const vendorAdmin = vendorAdmins[0]

                  if (vendorAdmin) {
                    actorId = vendorAdmin.id
                    const authModule = req.scope.resolve(Modules.AUTH)
                    await authModule.updateAuthIdentities([
                      {
                        id: authIdentityId,
                        app_metadata: {
                          vendor: vendorAdmin.id,
                        },
                      },
                    ])
                  }
                }

                if (actorId) {
                  const newPayload = {
                    ...decoded,
                    actor_id: actorId,
                  }
                  if (!newPayload.app_metadata) {
                    newPayload.app_metadata = {}
                  }
                  newPayload.app_metadata[actorType] = actorId

                  const { iat, exp, ...payloadToSign } = newPayload
                  const newToken = jwt.sign(payloadToSign, jwtSecret, { expiresIn: "24h" })
                  
                  urlObj.searchParams.set("token", newToken)
                }
              } catch (err) {
                console.error("Error in linkGoogleAccountMiddleware redirect async logic:", err)
              } finally {
                const finalUrl = url.startsWith("/") 
                  ? urlObj.pathname + urlObj.search + urlObj.hash
                  : urlObj.toString()
                originalRedirect.call(this, finalUrl)
              }
            })()
            return
          }
        }
      } catch (err) {
        // ignore
      }
    }
    return originalRedirect.call(this, url)
  }

  next()
}

export default defineMiddlewares({
  routes: [
    // ─── GOOGLE AUTH CALLBACK INTERCEPTOR ─────────────────────────
    {
      matcher: "/auth/*/google/callback",
      method: ["GET", "POST"],
      middlewares: [linkGoogleAccountMiddleware],
    },
    // ─── GOOGLE ONE TAP INTERCEPTOR (same linking logic, no redirect) ──
    {
      matcher: "/auth/*/google-onetap",
      method: ["POST"],
      middlewares: [linkGoogleAccountMiddleware],
    },

    // ─── PAYMENT SESSION — provider_id normalisation ──────────────
    // Maps short IDs ("kashflow", "stripe") to full container keys
    {
      matcher: "/store/payment-collections/:id/payment-sessions",
      method: ["POST"],
      middlewares: [normalizePaymentProviderId],
    },

    // ─── ADMIN DELIVERY ───────────────────────────────────────────
    {
      matcher: "/admin/delivery-companies",
      method: ["POST"],
      middlewares: [
        authenticate("user", ["session"]),
        validateAndTransformBody(PostAdminCreateDeliveryCompanySchema),
      ],
    },
    {
      matcher: "/admin/delivery-companies/:id",
      method: ["DELETE"],
      middlewares: [
        authenticate("user", ["session"]),
      ],
    },
    {
      matcher: "/admin/shipping-options",
      method: ["GET"],
      middlewares: [
        authenticate("user", ["session"]),
      ],
    },
    {
      matcher: "/admin/delivery-companies/:id/drivers",
      method: ["POST"],
      middlewares: [
        authenticate("admin", ["session"]),
        validateAndTransformBody(PostAdminCreateDeliveryDriverSchema),
      ],
    },
    {
      matcher: "/admin/payouts",
      method: ["GET"],
      middlewares: [
        authenticate("user", ["session", "bearer"]),
      ],
    },
    {
      matcher: "/admin/payouts/:id/approve",
      method: ["POST"],
      middlewares: [
        authenticate("user", ["session", "bearer"]),
      ],
    },
    {
      matcher: "/admin/payouts/:id/reject",
      method: ["POST"],
      middlewares: [
        authenticate("user", ["session", "bearer"]),
        validateAndTransformBody(PostAdminRejectPayoutSchema),
      ],
    },

    // ─── VENDOR AUTH ──────────────────────────────────────────────
    {
      matcher: "/vendors",
      method: ["POST"],
      middlewares: [
        authenticate("vendor", ["session", "bearer"], { allowUnregistered: true }),
        validateAndTransformBody(PostVendorCreateSchema),
      ],
    },
    {
      matcher: "/vendors/upload",
      method: ["POST"],
      middlewares: [
        authenticate("vendor", ["session", "bearer"]),
        upload.any(),
      ],
    },

    // ─── VENDOR ROUTES (toutes protégées) ─────────────────────────
    {
      matcher: "/vendors/*",
      middlewares: [
        authenticate("vendor", ["session", "bearer"]),
      ],
    },

    // ─── VENDOR BODY VALIDATION ───────────────────────────────────
    {
      matcher: "/vendors/me",
      method: ["PUT"],
      middlewares: [
        validateAndTransformBody(PutVendorMeSchema)
      ],
    },
    {
      matcher: "/vendors/stock-locations",
      method: ["POST"],
      middlewares: [validateAndTransformBody(PostVendorStockLocationSchema)],
    },
    {
      matcher: "/vendors/payouts",
      method: ["POST"],
      middlewares: [validateAndTransformBody(PostVendorPayoutSchema)],
    },
    {
      matcher: "/vendors/promotions",
      method: ["POST"],
      middlewares: [validateAndTransformBody(PostVendorPromotionSchema)],
    },
    {
      matcher: "/vendors/promotions/:id",
      method: ["DELETE"],
      middlewares: [],
    },
    {
      matcher: "/vendors/flash-sales",
      method: ["POST"],
      middlewares: [validateAndTransformBody(PostVendorFlashSaleSchema)],
    },
    {
      matcher: "/vendors/analytics",
      method: ["GET"],
      middlewares: [authenticate("vendor", ["session", "bearer"])],
    },
    {
      matcher: "/vendors/videos/:id/comments",
      method: ["GET"],
      middlewares: [authenticate("vendor", ["session", "bearer"])],
    },
    {
      matcher: "/vendors/videos/:id/comments",
      method: ["POST"],
      middlewares: [authenticate("vendor", ["session", "bearer"])],
    },
    {
      matcher: "/vendors/admins",
      method: ["POST"],
      middlewares: [validateAndTransformBody(PostVendorAdminSchema)],
    },
    {
      matcher: "/vendors/admins/:id",
      method: ["PUT"],
      middlewares: [validateAndTransformBody(PutVendorAdminSchema)],
    },
    {
      matcher: "/vendors/products",
      method: ["POST"],
      middlewares: [validateAndTransformBody(AdminCreateProduct)],
    },
    {
      matcher: "/vendors/products/:id",
      method: ["PUT"],
      middlewares: [validateAndTransformBody(AdminUpdateProduct)],
    },
    {
      matcher: "/vendors/products/:id/variants/:variant_id/inventory",
      method: ["POST"],
      middlewares: [validateAndTransformBody(PostVendorInventorySchema)],
    },
    {
      matcher: "/vendors/orders/:id/fulfill",
      method: ["POST"],
      middlewares: [
        authenticate("vendor", ["session", "bearer"]),
        validateAndTransformBody(PostFulfillOrderSchema)
      ],
    },
    {
      matcher: "/vendors/orders/:id/fulfillments/:fulfillment_id/shipments",
      method: ["POST"],
      middlewares: [
        authenticate("vendor", ["session", "bearer"]),
        validateAndTransformBody(PostShipmentOrderSchema)
      ],
    },
    {
      matcher: "/vendors/orders/:id/fulfillments/:fulfillment_id/mark-as-delivered",
      method: ["POST"],
      middlewares: [
        authenticate("vendor", ["session", "bearer"]),
      ],
    },
    {
      matcher: "/vendors/videos",
      method: ["POST"],
      middlewares: [validateAndTransformBody(PostVendorVideoSchema)],
    },
    {
      matcher: "/vendors/videos/:id",
      method: ["PUT"],
      middlewares: [validateAndTransformBody(PutVendorVideoSchema)],
    },

    // ─── STORE — ORDERS ───────────────────────────────────────────
    {
      matcher: "/store/orders/:id/complete",
      method: ["POST"],
      middlewares: [
        authenticate("customer", ["session", "bearer"]),
      ],
    },

    // ─── STORE — CUSTOMERS ────────────────────────────────────────
    {
      matcher: "/store/customers/me/coupons",
      middlewares: [
        authenticate("customer", ["session", "bearer"]),
      ],
    },
    {
      matcher: "/store/customers/me/wishlist",
      middlewares: [
        authenticate("customer", ["session", "bearer"]),
      ],
    },
    {
      matcher: "/store/customers/me/loyalty",
      middlewares: [
        authenticate("customer", ["session", "bearer"]),
      ],
    },
    {
      matcher: "/store/customers/me/following",
      middlewares: [
        authenticate("customer", ["session", "bearer"]),
      ],
    },
    {
      matcher: "/store/customers/me/referral",
      middlewares: [
        authenticate("customer", ["session", "bearer"]),
      ],
    },
    {
      matcher: "/store/customers/me/referral/apply",
      middlewares: [
        authenticate("customer", ["session", "bearer"]),
        validateAndTransformBody(PostApplyReferralSchema),
      ],
    },
    {
      matcher: "/store/customers/me/verify-email",
      middlewares: [
        authenticate("customer", ["session", "bearer"]),
        validateAndTransformBody(PostVerifyEmailSchema),
      ],
    },
    {
      matcher: "/store/customers/me/resend-verification",
      middlewares: [
        authenticate("customer", ["session", "bearer"]),
      ],
    },
    {
      matcher: "/store/auth/register/start",
      middlewares: [validateAndTransformBody(PostRegisterStartSchema)],
    },
    {
      matcher: "/store/auth/register/confirm",
      middlewares: [validateAndTransformBody(PostRegisterConfirmSchema)],
    },
    {
      matcher: "/store/auth/register/resend",
      middlewares: [validateAndTransformBody(PostRegisterResendSchema)],
    },
    {
      method: ["POST"],
      matcher: "/store/customers",
      middlewares: [requireVerifiedEmail],
    },
    {
      matcher: "/store/customers/me/recommendations",
      middlewares: [
        authenticate("customer", ["session", "bearer"]),
      ],
    },
    {
      matcher: "/store/customers/me/recently-viewed",
      middlewares: [
        authenticate("customer", ["session", "bearer"]),
      ],
    },
    {
      matcher: "/store/activity",
      method: ["POST"],
      middlewares: [
        authenticate("customer", ["session", "bearer"]),
        validateAndTransformBody(PostActivitySchema),
      ],
    },

    // ─── STORE — VENDOR FOLLOW ──────────────────────────────────────
    // Auth is required even for GET (Medusa's allowUnregistered only
    // tolerates a signup-in-progress token, not a fully absent one — a
    // truly public status check would need a second, unauthenticated
    // route). Guests never call this; the frontend only fetches follow
    // status when a customer is logged in.
    {
      matcher: "/store/vendors/:id/follow",
      method: ["GET", "POST", "DELETE"],
      middlewares: [
        authenticate("customer", ["session", "bearer"]),
      ],
    },

    // ─── STORE — LOYALTY (streaks / wheel / rewards) ───────────────
    {
      matcher: "/store/loyalty/status",
      middlewares: [
        authenticate("customer", ["session", "bearer"]),
      ],
    },
    {
      matcher: "/store/loyalty/checkin",
      middlewares: [
        authenticate("customer", ["session", "bearer"]),
      ],
    },
    {
      matcher: "/store/loyalty/wheel/prizes",
      middlewares: [
        authenticate("customer", ["session", "bearer"]),
      ],
    },
    {
      matcher: "/store/loyalty/wheel/spin",
      middlewares: [
        authenticate("customer", ["session", "bearer"]),
      ],
    },

    // ─── STORE — CART LINE ITEMS ──────────────────────────────────
    {
      matcher: "/store/*",
      middlewares: [trackProductClick],
    },
    {
      matcher: "/store/carts/:id/line-items",
      method: ["POST"],
      middlewares: [validateCartRegion],
    },

    // ─── STORE — VENDORS (public) ──────────────────────────────────
    {
      matcher: "/store/vendors",
      method: ["GET"],
      // middlewares: [
      //   authenticate("customer", ["session", "bearer"], { allowUnregistered: true }),
      // ],
    },
    {
      matcher: "/store/vendors/*",
      method: ["GET"],
      // middlewares: [
      //   authenticate("customer", ["session", "bearer"], { allowUnregistered: true }),
      // ],
    },

    // ─── STORE — NOTIFICATIONS ────────────────────────────────────
    {
      matcher: "/store/notifications",
      middlewares: [authenticate("customer", ["session", "bearer"])],
    },
    {
      matcher: "/store/notifications/*",
      middlewares: [authenticate("customer", ["session", "bearer"])],
    },

    // ─── STORE — CHAT ─────────────────────────────────────────────
    {
      matcher: "/store/chat/conversations",
      method: ["GET"],
      middlewares: [authenticate("customer", ["session", "bearer"])],
    },
    {
      matcher: "/store/chat/conversations",
      method: ["POST"],
      middlewares: [
        authenticate("customer", ["session", "bearer"]),
        validateAndTransformBody(PostConversationSchema),
      ],
    },
    {
      matcher: "/store/chat/conversations/:id/upload",
      method: ["POST"],
      middlewares: [
        authenticate("customer", ["session", "bearer"]),
        upload.any(),
      ],
    },
    {
      matcher: "/store/reviews/upload",
      method: ["POST"],
      middlewares: [
        authenticate("customer", ["session", "bearer"]),
        upload.any(),
      ],
    },
    {
      matcher: "/store/chat/conversations/*",
      middlewares: [authenticate("customer", ["session", "bearer"])],
    },

    // ─── STORE — VIDEOS (public) ───────────────────────────────────
    {
      matcher: "/store/videos/webhook",
      method: ["POST"],
      middlewares: [],
    },
    {
      matcher: "/store/videos",
      method: ["GET"],
      // middlewares: [
      //   authenticate("customer", ["session", "bearer"], { allowUnregistered: true }),
      // ],
    },
    {
      matcher: "/store/videos/:id",
      method: ["GET"],
      middlewares: [],
    },
    {
      matcher: "/store/videos/:id/view",
      method: ["POST"],
      middlewares: [],
    },
    {
      matcher: "/store/videos/:id/share",
      method: ["POST"],
      middlewares: [],
    },
    {
      matcher: "/store/videos/:id/comments",
      method: ["GET"],
      middlewares: [],
    },

    // ─── STORE — VIDEOS (auth customer) ───────────────────────────
    {
      matcher: "/store/videos/saved",
      method: ["GET"],
      middlewares: [authenticate("customer", ["session", "bearer"])],
    },
    {
      matcher: "/store/videos/:id/like",
      method: ["POST"],
      middlewares: [authenticate("customer", ["session", "bearer"])],
    },
    {
      matcher: "/store/videos/:id/save",
      method: ["POST"],
      middlewares: [authenticate("customer", ["session", "bearer"])],
    },
    {
      matcher: "/store/videos/:id/comments",
      method: ["POST"],
      middlewares: [
        authenticate("customer", ["session", "bearer"]),
        validateAndTransformBody(PostCommentSchema),
      ],
    },

    // ─── STORE — DELIVERY COMPANIES (public) ──────────────────────
    {
      matcher: "/store/delivery-companies",
      method: ["GET"],
      middlewares: [],
    },

    // ─── STORE — PAYMENT METHODS ──────────────────────────────────
    {
      matcher: "/store/payments/request-otp",
      method: ["POST"],
      middlewares: [authenticate("customer", ["session", "bearer"])],
    },
    {
      matcher: "/store/payment-methods",
      middlewares: [authenticate(["customer","vendor"], ["session", "bearer"])],
    },
    {
      matcher: "/store/payment-methods/*",
      middlewares: [authenticate(["customer","vendor"], ["session", "bearer"])],
    },
  ],
})
