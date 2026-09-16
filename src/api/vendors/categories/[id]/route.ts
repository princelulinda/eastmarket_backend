import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError, Modules } from "@medusajs/framework/utils"

const CATEGORY_FIELDS = [
  "id", "name", "handle", "description", "rank",
  "parent_category_id", "parent_category.*", "category_children.*",
]

async function retrieveCategory(req: AuthenticatedMedusaRequest, id: string) {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { data: [category] } = await query.graph({
    entity: "product_category",
    fields: CATEGORY_FIELDS,
    filters: { id },
  })

  if (!category) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Category not found")
  }
  return category
}

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  res.json({ category: await retrieveCategory(req, req.params.id) })
}

/** POST /vendors/categories/:id — Met à jour la catégorie. */
export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const id = req.params.id
  await retrieveCategory(req, id)

  const productModule = req.scope.resolve(Modules.PRODUCT)
  await productModule.updateProductCategories(id, req.body as any)

  res.json({ category: await retrieveCategory(req, id) })
}

/** DELETE /vendors/categories/:id — Supprime la catégorie. */
export const DELETE = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const id = req.params.id
  const category = await retrieveCategory(req, id)

  // Une catégorie parente supprimée laisserait ses enfants orphelins.
  if ((category as any).category_children?.length) {
    throw new MedusaError(
      MedusaError.Types.NOT_ALLOWED,
      "Cette catégorie contient des sous-catégories. Supprimez-les d'abord.",
    )
  }

  const productModule = req.scope.resolve(Modules.PRODUCT)
  await productModule.deleteProductCategories([id])

  res.json({ id, object: "product_category", deleted: true })
}
