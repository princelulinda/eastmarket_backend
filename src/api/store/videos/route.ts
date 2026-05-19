import { 
  AuthenticatedMedusaRequest, 
  MedusaResponse 
} from "@medusajs/framework"
import { SHORT_VIDEO_MODULE } from "../../../modules/short-video"
import ShortVideoService from "../../../modules/short-video/service"

export const GET = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const service = req.scope.resolve(SHORT_VIDEO_MODULE) as ShortVideoService
  const { limit = 10, offset = 0 } = req.query as any

  const videos = await service.getFeed(Number(limit), Number(offset))

  res.json({
    videos,
  })
}
