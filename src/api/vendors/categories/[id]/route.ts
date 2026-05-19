import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const { data: [category] } = await query.graph({
    entity: "product_category",
    fields: ["id", "name", "handle", "description", "rank", "parent_category_id", "parent_category.*", "category_children.*"],
    filters: { id: req.params.id }
  })

  if (!category) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Category not found")
  }

  res.json({ category })
}
