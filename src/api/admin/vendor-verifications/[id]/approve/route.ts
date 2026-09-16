import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { MedusaError, Modules } from "@medusajs/framework/utils"
import { MARKETPLACE_MODULE } from "../../../../../modules/marketplace"
import MarketplaceModuleService from "../../../../../modules/marketplace/service"

/**
 * Approbation d'un dossier KYC. C'est le seul endroit du code qui met
 * `vendor.is_verified` à vrai — le badge vitrine et le droit de publier des
 * produits en découlent tous les deux.
 */
export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const marketplaceModule: MarketplaceModuleService = req.scope.resolve(MARKETPLACE_MODULE)
  const eventBus = req.scope.resolve(Modules.EVENT_BUS)

  const [verification] = await marketplaceModule.listVendorVerifications({ id: req.params.id })
  if (!verification) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Verification request not found")
  }

  const current = verification as any
  if (current.status !== "pending") {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      `Verification cannot be approved because it is already '${current.status}'`
    )
  }

  const verifiedAt = new Date()

  const updated: any = await marketplaceModule.updateVendorVerifications({
    id: current.id,
    status: "approved",
    rejection_reason: null,
    reviewed_at: verifiedAt,
    reviewed_by: req.auth_context?.actor_id ?? null,
  } as any)

  await marketplaceModule.updateVendors({
    id: current.vendor_id,
    is_verified: true,
    verified_at: verifiedAt,
  } as any)

  // Déclenche la mise en ligne des produits retenus en brouillon + les
  // notifications vendeur (subscribers/vendor-verification-approved.ts).
  await eventBus.emit({
    name: "vendor.verification_approved",
    data: { id: current.id, vendor_id: current.vendor_id },
  })

  res.json({ vendor_verification: updated })
}
