import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError, Modules } from "@medusajs/framework/utils"

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
  const { id, variant_id } = req.params
  await assertProductOwnership(req, id)

  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { data: [variant] } = await query.graph({
    entity: "variant",
    fields: ["*", "prices.*", "inventory.location_levels.*"],
    filters: { id: variant_id }
  })

  if (!variant) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Variant not found")
  }
  
  res.json({ variant })
}

export const PUT = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const { id, variant_id } = req.params
  await assertProductOwnership(req, id)

  const productModule = req.scope.resolve(Modules.PRODUCT)
  
  const variant = await productModule.updateProductVariants([
    {
      id: variant_id,
      ...req.body,
    },
  ])
  
  res.json({ variant: variant[0] })
}

export const DELETE = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const { id, variant_id } = req.params
  await assertProductOwnership(req, id)

  const productModule = req.scope.resolve(Modules.PRODUCT)
  
  await productModule.deleteProductVariants([variant_id])
  
  res.json({ message: "Variant deleted successfully" })
}
