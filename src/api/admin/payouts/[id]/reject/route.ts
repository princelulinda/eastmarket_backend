import { z } from "@medusajs/framework/zod"
import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"
import { MARKETPLACE_MODULE } from "../../../../../modules/marketplace"
import MarketplaceModuleService from "../../../../../modules/marketplace/service"

export const PostAdminRejectPayoutSchema = z.object({
  rejection_reason: z.string().optional()
}).strict()

type PostBody = z.infer<typeof PostAdminRejectPayoutSchema>

export const POST = async (req: AuthenticatedMedusaRequest<PostBody>, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const marketplaceModule: MarketplaceModuleService = req.scope.resolve(MARKETPLACE_MODULE)
  const payoutId = req.params.id
  const { rejection_reason } = req.validatedBody

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
      `Payout cannot be rejected because it is already '${payout.status}'`
    )
  }

  // 2. Rembourser le solde du vendeur
  const vendorId = payout.vendor?.id
  if (vendorId) {
    await marketplaceModule.addVendorBalance(vendorId, payout.amount)
  }

  // 3. Mettre à jour la demande de payout avec le motif de rejet
  const updatedPayouts = await marketplaceModule.updateVendorPayouts({
    id: payoutId,
    status: "rejected",
    rejection_reason: rejection_reason || "Demande rejetée par l'administrateur"
  })

  res.json({ payout: updatedPayouts[0] })
}
