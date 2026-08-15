import { AuthenticatedMedusaRequest, MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { FOLLOW_MODULE } from "../../../../../modules/follow"
import FollowModuleService from "../../../../../modules/follow/service"

export const GET = async (req: MedusaRequest, res: MedusaResponse) => {
  const service = req.scope.resolve(FOLLOW_MODULE) as FollowModuleService
  const vendorId = req.params.id

  const followerCount = await service.countFollowers(vendorId)

  const authReq = req as AuthenticatedMedusaRequest
  const customerId = authReq.auth_context?.actor_id
  const isFollowing = customerId ? await service.isFollowing(customerId, vendorId) : false

  res.json({ is_following: isFollowing, follower_count: followerCount })
}

export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const service = req.scope.resolve(FOLLOW_MODULE) as FollowModuleService
  const vendorId = req.params.id
  const customerId = req.auth_context.actor_id

  await service.follow(customerId, vendorId)
  const followerCount = await service.countFollowers(vendorId)

  res.json({ is_following: true, follower_count: followerCount })
}

export const DELETE = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const service = req.scope.resolve(FOLLOW_MODULE) as FollowModuleService
  const vendorId = req.params.id
  const customerId = req.auth_context.actor_id

  await service.unfollow(customerId, vendorId)
  const followerCount = await service.countFollowers(vendorId)

  res.json({ is_following: false, follower_count: followerCount })
}
