import { 
  AuthenticatedMedusaRequest, 
  MedusaResponse 
} from "@medusajs/framework"
import { SHORT_VIDEO_MODULE } from "../../../../../modules/short-video"
import ShortVideoService from "../../../../../modules/short-video/service"

export const POST = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const customerId = req.auth_context.actor_id
  const videoId = req.params.id
  const service = req.scope.resolve(SHORT_VIDEO_MODULE) as ShortVideoService

  const result = await service.toggleSave(videoId, customerId)

  res.json(result)
}
