import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { LOYALTY_MODULE } from "../../../../modules/loyalty"
import LoyaltyModuleService from "../../../../modules/loyalty/service"

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const customerId = req.auth_context.actor_id
  const service = req.scope.resolve(LOYALTY_MODULE) as LoyaltyModuleService

  const { loyalty, checked_in_today, can_spin_today } = await service.getStatus(customerId)

  res.json({
    checked_in_today,
    can_spin_today,
    current_streak: Number(loyalty.current_streak),
    points_balance: Number(loyalty.points_balance),
  })
}
