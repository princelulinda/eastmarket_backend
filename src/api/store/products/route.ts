import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"

export const GET = async (req: MedusaRequest, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const {
    limit = 20,
    offset = 0,
    category_id,
    q,
  } = req.query as Record<string, any>

  const filters: Record<string, any> = { status: "published" }
  if (category_id) {
    filters["categories.id"] = Array.isArray(category_id) ? category_id : [category_id]
  }
  if (q) {
    filters["title"] = { $ilike: `%${q}%` }
  }

  const { data: products, metadata } = await query.graph({
    entity: "product",
    fields: [
      "id",
      "title",
      "handle",
      "description",
      "subtitle",
      "status",
      "thumbnail",
      "weight",
      "material",
      "variants.id",
      "variants.title",
      "variants.sku",
      "variants.prices.*",
      "variants.options.*",
      "variants.inventory.location_levels.*",
      "options.*", 

      "options.values.*",
      "images.*",
      "categories.*",
      "tags.*",
      "vendor.*",
    ],
    filters,
    pagination: {
      take: Number(limit),
      skip: Number(offset),
    },
  })

  res.json({
    products,
    count: metadata?.count ?? products.length,
    limit: Number(limit),
    offset: Number(offset),
  })
}
