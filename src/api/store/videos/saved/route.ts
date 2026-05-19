import { 
  AuthenticatedMedusaRequest, 
  MedusaResponse 
} from "@medusajs/framework"
import { SHORT_VIDEO_MODULE } from "../../../../modules/short-video"
import ShortVideoService from "../../../../modules/short-video/service"

export const GET = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const customerId = req.auth_context.actor_id
  const service = req.scope.resolve(SHORT_VIDEO_MODULE) as ShortVideoService

  const videos = await service.getSavedVideos(customerId)

  res.json({ videos })
}
