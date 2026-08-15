import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { LOYALTY_MODULE } from "../../../../../modules/loyalty"
import LoyaltyModuleService from "../../../../../modules/loyalty/service"

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const customerId = req.auth_context.actor_id
  const service = req.scope.resolve(LOYALTY_MODULE) as LoyaltyModuleService

  const code = await service.getOrCreateReferralCode(customerId)
  const stats = await service.getReferralStats(customerId)
  const link = await service.getReferralLink(customerId)

  res.json({
    code,
    total_referred: stats.total_referred,
    total_rewarded: stats.total_rewarded,
    referred_by: link ? { status: link.status } : null,
  })
}
