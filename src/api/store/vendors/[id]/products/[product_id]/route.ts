import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"

export const GET = async (req: MedusaRequest, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  // Verify vendor exists
  const { data: [vendor] } = await query.graph({
    entity: "vendor",
    fields: ["products.id"],
    filters: { id: req.params.id }
  })

  if (!vendor) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Vendor not found")
  }

  const productIds = (vendor.products || []).map((p: { id: string }) => p.id)
  if (!productIds.includes(req.params.product_id)) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Product not found")
  }

  const { data: [product] } = await query.graph({
    entity: "product",
    fields: [
      "id", "title", "handle", "description", "thumbnail", "status",
      "variants.*", "variants.prices.*",
      "options.*", "options.values.*",
      "images.*", "categories.*", "tags.*",
    ],
    filters: { id: req.params.product_id }
  })

  res.json({ product })
}
