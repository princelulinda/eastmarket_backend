import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"

export const GET = async (req: MedusaRequest, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const { data: [vendor] } = await query.graph({
    entity: "vendor",
    fields: ["id"],
    filters: { id: req.params.id }
  })

  if (!vendor) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Vendor not found")
  }

  const { data: [vendorWithProducts] } = await query.graph({
    entity: "vendor",
    fields: [
      "products.id",
      "products.title",
      "products.handle",
      "products.description",
      "products.thumbnail",
      "products.status",
      "products.variants.*",
      "products.variants.prices.*",
      "products.options.*",
      "products.options.values.*",
      "products.images.*",
      "products.categories.*",
      "products.tags.*",
    ],
    filters: { id: req.params.id }
  })

  const products = (vendorWithProducts.products || []).filter(
    (p: { status: string }) => p.status === "published"
  )

  res.json({ products })
}
