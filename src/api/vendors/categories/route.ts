import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, Modules } from "@medusajs/framework/utils"

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const { data: categories } = await query.graph({
    entity: "product_category",
    fields: ["id", "name", "handle", "description", "rank", "parent_category_id", "parent_category.*", "category_children.*"],
  })

  res.json({ categories })
}

export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const productModule = req.scope.resolve(Modules.PRODUCT)
  
  const category = await productModule.createProductCategories([req.body])
  
  res.json({ category: category[0] })
}
