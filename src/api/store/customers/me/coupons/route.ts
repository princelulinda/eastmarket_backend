import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { LOYALTY_MODULE } from "../../../../../modules/loyalty"
import LoyaltyModuleService from "../../../../../modules/loyalty/service"

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const customerId = req.auth_context.actor_id
  const service = req.scope.resolve(LOYALTY_MODULE) as LoyaltyModuleService

  const coupons = await service.listCustomerCoupons(customerId)

  res.json({
    coupons: coupons.map((c) => ({
      id: c.id,
      code: c.code,
      discount_type: c.discount_type,
      discount_value: c.discount_value !== null ? Number(c.discount_value) : null,
      expires_at: c.expires_at,
      status: c.status,
      source: c.source,
      is_used: c.status === "redeemed",
    })),
    count: coupons.length,
  })
}
