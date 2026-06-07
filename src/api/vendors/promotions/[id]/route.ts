import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { deletePromotionsWorkflow } from "@medusajs/core-flows"

export const DELETE = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const { id: promotion_id } = req.params
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  // Ownership check
  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.promotions.id"],
    filters: { id: [req.auth_context.actor_id] }
  })

  const promoIds = (vendorAdmin.vendor.promotions || []).map((p: any) => p.id)
  if (!promoIds.includes(promotion_id)) {
    return res.status(404).json({ message: "Promotion not found" })
  }

  await deletePromotionsWorkflow(req.scope).run({
    input: { ids: [promotion_id] }
  })

  res.json({ id: promotion_id, deleted: true })
}
