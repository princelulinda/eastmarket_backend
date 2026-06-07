import { 
  AuthenticatedMedusaRequest, 
  MedusaResponse
} from "@medusajs/framework/http";
import { 
  HttpTypes,
} from "@medusajs/framework/types"
import { 
  ContainerRegistrationKeys,
  Modules
} from "@medusajs/framework/utils"
import createVendorProductWorkflow from "../../../workflows/marketplace/create-vendor-product";

export const GET = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const pricingModule = req.scope.resolve(Modules.PRICING)

  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: [
      "vendor.products.*", 
      "vendor.products.variants.*", 
      "vendor.products.variants.prices.*",
      "vendor.products.variants.inventory.location_levels.*"
    ],
    filters: { id: [req.auth_context.actor_id] },
  })

  const products = vendorAdmin.vendor.products || []

  // Injection de calculated_price pour compatibilité frontend via les données déjà chargées
  for (const product of products) {
    for (const variant of product.variants) {
      const price = variant.prices?.[0]
      if (price) {
        (variant as any).calculated_price = {
          calculated_amount: price.amount,
          original_amount: price.amount,
          currency_code: price.currency_code,
          is_calculated_price_price_list: false 
        }
      }
    }
  }

  res.json({ products })
}

export const POST = async (
  req: AuthenticatedMedusaRequest<HttpTypes.AdminCreateProduct>,
  res: MedusaResponse
) => {
  const { result } = await createVendorProductWorkflow(req.scope)
    .run({
      input: {
        vendor_admin_id: req.auth_context.actor_id,
        product: req.validatedBody
      }
    })

  res.json({
    product: result.product
  })
}