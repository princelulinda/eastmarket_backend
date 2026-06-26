import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError, Modules } from "@medusajs/framework/utils"
import { updateProductVariantsWorkflow } from "@medusajs/medusa/core-flows"

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

  let updateData = req.body
  if (Array.isArray(req.body)) {
    updateData = req.body[0]
  }

  if (typeof updateData !== 'object' || updateData === null) {
    throw new MedusaError(MedusaError.Types.INVALID_DATA, "Invalid request body: Expected an object")
  }

  const { result } = await updateProductVariantsWorkflow(req.scope).run({
    input: {
      product_variants: [
        {
          id: variant_id,
          ...updateData,
        },
      ],
    },
  })
  
  res.json({ variant: result[0] })
}

export const DELETE = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const { id, variant_id } = req.params
  await assertProductOwnership(req, id)

  const productModule = req.scope.resolve(Modules.PRODUCT)
  
  await productModule.deleteProductVariants([variant_id])
  
  res.json({ message: "Variant deleted successfully" })
}
