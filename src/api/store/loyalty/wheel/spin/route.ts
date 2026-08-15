import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { Modules } from "@medusajs/framework/utils"
import { LOYALTY_MODULE } from "../../../../../modules/loyalty"
import LoyaltyModuleService from "../../../../../modules/loyalty/service"
import issueLoyaltyCouponWorkflow from "../../../../../workflows/loyalty/issue-loyalty-coupon"

export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const customerId = req.auth_context.actor_id
  const service = req.scope.resolve(LOYALTY_MODULE) as LoyaltyModuleService

  const { loyalty, spin, prize } = await service.spinWheel(customerId)

  let coupon = null
  if (prize.prize_type === "coupon_percentage" || prize.prize_type === "coupon_fixed" || prize.prize_type === "free_shipping") {
    const discountType =
      prize.prize_type === "coupon_percentage" ? "percentage" :
      prize.prize_type === "coupon_fixed" ? "fixed" : "free_shipping"

    const { result } = await issueLoyaltyCouponWorkflow(req.scope).run({
      input: {
        customer_id: customerId,
        discount_type: discountType,
        discount_value: prize.coupon_discount_value ?? undefined,
        validity_days: prize.coupon_validity_days ?? 7,
        source: "wheel",
        source_ref_id: spin.id,
      },
    })
    coupon = result
    await service.attachCouponToSpin(spin.id, coupon.id)

    const eventBus = req.scope.resolve(Modules.EVENT_BUS)
    await eventBus.emit({
      name: "loyalty.reward_won",
      data: { customer_id: customerId, label: prize.label, coupon_code: coupon.code, coupon_id: coupon.id },
    })
  }

  res.json({
    loyalty,
    prize: {
      id: prize.id,
      label: prize.label,
      prize_type: prize.prize_type,
      color: prize.color,
      icon: prize.icon,
    },
    points_earned: spin.points_earned,
    coupon,
  })
}
