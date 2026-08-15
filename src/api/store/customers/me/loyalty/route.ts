import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { LOYALTY_MODULE } from "../../../../../modules/loyalty"
import LoyaltyModuleService from "../../../../../modules/loyalty/service"

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const customerId = req.auth_context.actor_id
  const service = req.scope.resolve(LOYALTY_MODULE) as LoyaltyModuleService

  const loyalty = await service.getOrCreateLoyalty(customerId)
  const progress = service.getTierProgress(Number(loyalty.lifetime_points))

  res.json({
    loyalty: {
      points: Number(loyalty.points_balance),
      tier: loyalty.tier,
      next_tier: progress.next_tier,
      points_to_next_tier: progress.points_to_next_tier,
      tier_progress_pct: progress.tier_progress_pct,
      current_streak: Number(loyalty.current_streak),
      longest_streak: Number(loyalty.longest_streak),
    },
  })
}
