import { z } from "@medusajs/framework/zod"
import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"
import { LOYALTY_MODULE } from "../../../../../../modules/loyalty"
import LoyaltyModuleService from "../../../../../../modules/loyalty/service"

export const PostApplyReferralSchema = z.object({
  code: z.string().min(1),
}).strict()

type PostBody = z.infer<typeof PostApplyReferralSchema>

export const POST = async (req: AuthenticatedMedusaRequest<PostBody>, res: MedusaResponse) => {
  const customerId = req.auth_context.actor_id
  const service = req.scope.resolve(LOYALTY_MODULE) as LoyaltyModuleService
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  // Referral codes are for new customers only — reject anyone who has
  // already placed an order, server-side, regardless of what the client claims.
  const { data: orders } = await query.graph({
    entity: "order",
    fields: ["id"],
    filters: { customer_id: customerId },
  })
  if (orders.length > 0) {
    throw new MedusaError(MedusaError.Types.NOT_ALLOWED, "Referral codes can only be used by new customers")
  }

  const code = req.validatedBody.code.trim().toUpperCase()
  const referral = await service.applyReferralCode(customerId, code)

  res.json({ referral: { status: referral.status } })
}
