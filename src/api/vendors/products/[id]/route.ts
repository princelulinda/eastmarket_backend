import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"
import { HttpTypes } from "@medusajs/framework/types"
import { updateProductsWorkflow, deleteProductsWorkflow } from "@medusajs/medusa/core-flows"

async function assertProductOwnership(req: AuthenticatedMedusaRequest, productId: string): Promise<void> {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.products.id"],
    filters: { id: [req.auth_context.actor_id] }
  })
  const productIds = (vendorAdmin.vendor.products || []).map((p: { id: string }) => p.id)
  if (!productIds.includes(productId)) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Product not found")
  }
}

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  await assertProductOwnership(req, req.params.id)
  
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { data: [product] } = await query.graph({
    entity: "product",
    fields: ["*", "variants.*", "variants.prices.*", "options.*", "options.values.*", "images.*", "categories.*", "tags.*"],
    filters: { id: req.params.id }
  })

  res.json({ product })
}

export const PUT = async (req: AuthenticatedMedusaRequest<HttpTypes.AdminUpdateProduct>, res: MedusaResponse) => {
  await assertProductOwnership(req, req.params.id)

  const { result: [product] } = await updateProductsWorkflow(req.scope).run({
    input: {
      products: [{ id: req.params.id, ...req.validatedBody }]
    }
  })

  res.json({ product })
}

export const DELETE = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  await assertProductOwnership(req, req.params.id)

  await deleteProductsWorkflow(req.scope).run({
    input: { ids: [req.params.id] }
  })

  res.json({ id: req.params.id, deleted: true })
}
