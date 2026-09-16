import { z } from "@medusajs/framework/zod"
import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { MedusaError, Modules } from "@medusajs/framework/utils"
import { MARKETPLACE_MODULE } from "../../../../../modules/marketplace"
import MarketplaceModuleService from "../../../../../modules/marketplace/service"

/** Le motif est obligatoire : il est transmis tel quel au vendeur, qui doit
 * savoir quoi corriger pour re-soumettre. */
export const PostAdminRejectVerificationSchema = z.object({
  rejection_reason: z.string().min(5),
}).strict()

type PostBody = z.infer<typeof PostAdminRejectVerificationSchema>

export const POST = async (req: AuthenticatedMedusaRequest<PostBody>, res: MedusaResponse) => {
  const marketplaceModule: MarketplaceModuleService = req.scope.resolve(MARKETPLACE_MODULE)
  const eventBus = req.scope.resolve(Modules.EVENT_BUS)
  const { rejection_reason } = req.validatedBody

  const [verification] = await marketplaceModule.listVendorVerifications({ id: req.params.id })
  if (!verification) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Verification request not found")
  }

  const current = verification as any
  if (current.status !== "pending") {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      `Verification cannot be rejected because it is already '${current.status}'`
    )
  }

  const updated: any = await marketplaceModule.updateVendorVerifications({
    id: current.id,
    status: "rejected",
    rejection_reason,
    reviewed_at: new Date(),
    reviewed_by: req.auth_context?.actor_id ?? null,
  } as any)

  // Un refus ne retire jamais une vérification déjà acquise : `is_verified`
  // n'est pas touché ici. Retirer un badge est une action distincte.
  await eventBus.emit({
    name: "vendor.verification_rejected",
    data: { id: current.id, vendor_id: current.vendor_id, reason: rejection_reason },
  })

  res.json({ vendor_verification: updated })
}
