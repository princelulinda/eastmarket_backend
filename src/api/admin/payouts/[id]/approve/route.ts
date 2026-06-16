import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"
import { MARKETPLACE_MODULE } from "../../../../../modules/marketplace"
import MarketplaceModuleService from "../../../../../modules/marketplace/service"

export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const marketplaceModule: MarketplaceModuleService = req.scope.resolve(MARKETPLACE_MODULE)
  const payoutId = req.params.id

  // 1. Récupérer la demande de payout
  const { data: [payout] } = await query.graph({
    entity: "vendor_payout",
    fields: ["id", "status", "amount", "vendor.id"],
    filters: { id: payoutId }
  })

  if (!payout) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Payout request not found")
  }

  if (payout.status !== "pending") {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      `Payout cannot be approved because it is already '${payout.status}'`
    )
  }

  // 2. Mettre à jour le statut à approved
  const updatedPayouts = await marketplaceModule.updateVendorPayouts({
    id: payoutId,
    status: "approved"
  })

  res.json({ payout: updatedPayouts[0] })
}
