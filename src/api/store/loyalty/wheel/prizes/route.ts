import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { LOYALTY_MODULE } from "../../../../../modules/loyalty"
import LoyaltyModuleService from "../../../../../modules/loyalty/service"

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const service = req.scope.resolve(LOYALTY_MODULE) as LoyaltyModuleService

  const prizes = await service.getActiveWheelPrizes()

  // Never leak `weight` (relative probability) to the client.
  res.json({
    prizes: prizes.map((p) => ({
      id: p.id,
      label: p.label,
      prize_type: p.prize_type,
      color: p.color,
      icon: p.icon,
      sort_order: p.sort_order,
    })),
  })
}
