import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { Modules } from "@medusajs/framework/utils"
import { LOYALTY_MODULE } from "../../../../modules/loyalty"
import LoyaltyModuleService from "../../../../modules/loyalty/service"
import issueLoyaltyCouponWorkflow from "../../../../workflows/loyalty/issue-loyalty-coupon"

const MILESTONE_COUPON_DISCOUNT_PCT = 10
const MILESTONE_COUPON_VALIDITY_DAYS = 7

export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const customerId = req.auth_context.actor_id
  const service = req.scope.resolve(LOYALTY_MODULE) as LoyaltyModuleService

  const result = await service.checkIn(customerId)

  let milestoneCoupon = null
  if (result.milestone_reached) {
    const { result: coupon } = await issueLoyaltyCouponWorkflow(req.scope).run({
      input: {
        customer_id: customerId,
        discount_type: "percentage",
        discount_value: MILESTONE_COUPON_DISCOUNT_PCT,
        validity_days: MILESTONE_COUPON_VALIDITY_DAYS,
        source: "checkin_milestone",
        source_ref_id: result.checkin.id,
      },
    })
    milestoneCoupon = coupon

    const eventBus = req.scope.resolve(Modules.EVENT_BUS)
    await eventBus.emit({
      name: "loyalty.streak_milestone",
      data: { customer_id: customerId, streak: result.milestone_streak, coupon_code: coupon.code, coupon_id: coupon.id },
    })
  }

  res.json({
    loyalty: result.loyalty,
    checkin: {
      streak: result.streak,
      points_earned: result.points_earned,
      milestone_coupon: milestoneCoupon,
    },
  })
}
