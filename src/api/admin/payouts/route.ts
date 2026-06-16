import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  // Récupérer toutes les demandes de retrait de tous les vendeurs
  const { data: payouts } = await query.graph({
    entity: "vendor_payout",
    fields: [
      "id",
      "amount",
      "status",
      "payment_method",
      "payment_details",
      "rejection_reason",
      "created_at",
      "vendor.id",
      "vendor.name"
    ]
  })

  res.json({ payouts })
}
