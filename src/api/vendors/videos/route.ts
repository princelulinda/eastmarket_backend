import { 
  AuthenticatedMedusaRequest, 
  MedusaResponse 
} from "@medusajs/framework"
import { z } from "@medusajs/framework/zod"
import { SHORT_VIDEO_MODULE } from "../../../modules/short-video"
import ShortVideoService from "../../../modules/short-video/service"

export const PostVendorVideoSchema = z.object({
  title: z.string(),
  description: z.string().optional(),
  video_url: z.string().url(),
  thumbnail_url: z.string().url().optional(),
  duration: z.number().optional(),
  tag: z.string().optional(),
  product_ids: z.array(z.string()).optional(),
})

export const POST = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const vendorId = req.auth_context.actor_id 
  const validated = PostVendorVideoSchema.parse(req.body)

  const service = req.scope.resolve(SHORT_VIDEO_MODULE) as ShortVideoService

  const video = await service.createVideo({
    vendor_id: vendorId,
    ...validated,
  })

  res.json({
    video,
  })
}

export const GET = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const vendorId = req.auth_context.actor_id
  const service = req.scope.resolve(SHORT_VIDEO_MODULE) as ShortVideoService

  const videos = await service.getVendorVideos(vendorId)

  res.json({
    videos,
  })
}
