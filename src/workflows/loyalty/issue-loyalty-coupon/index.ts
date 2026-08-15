import {
  createStep,
  StepResponse,
  createWorkflow,
  transform,
  WorkflowResponse,
} from "@medusajs/framework/workflows-sdk"
import { createPromotionsWorkflow } from "@medusajs/core-flows"
import { PromotionStatus, PromotionType } from "@medusajs/framework/utils"
import { LOYALTY_MODULE } from "../../../modules/loyalty"
import LoyaltyModuleService from "../../../modules/loyalty/service"

export type IssueLoyaltyCouponInput = {
  customer_id: string
  discount_type: "percentage" | "fixed" | "free_shipping"
  discount_value?: number
  validity_days: number
  source: "wheel" | "checkin_milestone" | "referral" | "manual"
  source_ref_id?: string
}

function generateCode(): string {
  const random = Math.random().toString(36).slice(2, 10).toUpperCase()
  return `EM-${random}`
}

const createLoyaltyCouponRecordStep = createStep(
  "create-loyalty-coupon-record-step",
  async (
    input: { promotionId: string; code: string; issueInput: IssueLoyaltyCouponInput },
    { container }
  ) => {
    const service = container.resolve(LOYALTY_MODULE) as LoyaltyModuleService

    const expiresAt = new Date(Date.now() + input.issueInput.validity_days * 24 * 60 * 60 * 1000)

    const coupon = await service.createLoyaltyCoupons({
      customer_id: input.issueInput.customer_id,
      promotion_id: input.promotionId,
      code: input.code,
      source: input.issueInput.source,
      discount_type: input.issueInput.discount_type,
      discount_value: input.issueInput.discount_value ?? null,
      status: "issued",
      expires_at: expiresAt,
      source_ref_id: input.issueInput.source_ref_id ?? null,
    })

    return new StepResponse(coupon, coupon.id)
  },
  async (couponId, { container }) => {
    if (!couponId) return
    const service = container.resolve(LOYALTY_MODULE) as LoyaltyModuleService
    await service.deleteLoyaltyCoupons(couponId)
  }
)

const issueLoyaltyCouponWorkflow = createWorkflow(
  "issue-loyalty-coupon",
  (input: IssueLoyaltyCouponInput) => {
    const built = transform({ input }, (data) => {
      const code = generateCode()
      const isFreeShipping = data.input.discount_type === "free_shipping"

      return {
        code,
        promotionData: {
          code,
          type: PromotionType.STANDARD,
          status: PromotionStatus.ACTIVE,
          is_automatic: false,
          application_method: {
            type: isFreeShipping ? "fixed" : (data.input.discount_type as "percentage" | "fixed"),
            value: isFreeShipping ? 0 : data.input.discount_value ?? 0,
            allocation: "across" as const,
            target_type: isFreeShipping ? "shipping_methods" : "items",
          },
          usage_limit: 1,
        },
      }
    })

    const promotions = createPromotionsWorkflow.runAsStep({
      input: { promotionsData: [built.promotionData] },
    })

    const coupon = createLoyaltyCouponRecordStep({
      promotionId: promotions[0].id,
      code: built.code,
      issueInput: input,
    })

    return new WorkflowResponse(coupon)
  }
)

export default issueLoyaltyCouponWorkflow
