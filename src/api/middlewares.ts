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
import { PostVendorVideoSchema } from "./vendors/videos/route"
import { PutVendorVideoSchema } from "./vendors/videos/[id]/route"
import { PostCommentSchema } from "./store/videos/[id]/comments/route"
import multer from "multer"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"

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

    // Check that all requested variants have a price in the cart's currency
    const body = req.body as { items?: Array<{ variant_id?: string }> }
    const variantIds = (body?.items ?? [])
      .map((i) => i.variant_id)
      .filter((id): id is string => !!id)

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

export default defineMiddlewares({
  routes: [
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
      middlewares: [validateAndTransformBody(PutVendorMeSchema)],
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
      matcher: "/vendors/orders/:id/fulfill",
      method: ["POST"],
      middlewares: [validateAndTransformBody(PostFulfillOrderSchema)],
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

    // ─── STORE — CART LINE ITEMS ──────────────────────────────────
    {
      matcher: "/store/carts/:id/line-items",
      method: ["POST"],
      middlewares: [validateCartRegion],
    },

    // ─── STORE — VENDORS (public) ──────────────────────────────────
    {
      matcher: "/store/vendors",
      method: ["GET"],
      middlewares: [
        authenticate("customer", ["session", "bearer"], { allowUnregistered: true }),
      ],
    },
    {
      matcher: "/store/vendors/*",
      method: ["GET"],
      middlewares: [
        authenticate("customer", ["session", "bearer"], { allowUnregistered: true }),
      ],
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
      middlewares: [
        authenticate("customer", ["session", "bearer"], { allowUnregistered: true }),
      ],
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

    // ─── STORE — PAYMENT METHODS ──────────────────────────────────
    {
      matcher: "/store/payment-methods",
      middlewares: [authenticate("customer", ["session", "bearer"])],
    },
    {
      matcher: "/store/payment-methods/*",
      middlewares: [authenticate("customer", ["session", "bearer"])],
    },
  ],
})
