import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { FOLLOW_MODULE } from "../../../../../modules/follow"
import FollowModuleService from "../../../../../modules/follow/service"

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const service = req.scope.resolve(FOLLOW_MODULE) as FollowModuleService
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const customerId = req.auth_context.actor_id

  const vendorIds = await service.listFollowedVendorIds(customerId)
  if (vendorIds.length === 0) {
    return res.json({ vendors: [] })
  }

  const { data: vendors } = await query.graph({
    entity: "vendor",
    fields: ["id", "name", "handle", "logo", "is_verified"],
    filters: { id: vendorIds },
  })

  res.json({ vendors })
}
