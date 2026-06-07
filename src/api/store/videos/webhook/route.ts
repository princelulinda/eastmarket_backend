import { 
  MedusaRequest, 
  MedusaResponse 
} from "@medusajs/framework"
import { SHORT_VIDEO_MODULE } from "../../../../modules/short-video"
import ShortVideoService from "../../../../modules/short-video/service"

export const POST = async (
  req: MedusaRequest,
  res: MedusaResponse
) => {
  const service = req.scope.resolve(SHORT_VIDEO_MODULE) as ShortVideoService
  
  const payload = req.body
  
  const publicId = payload.public_id
  const videoId = publicId.split('/').pop()

  const hlsAsset = payload.eager?.find((e: any) => e.format === "m3u8")
  const hlsUrl = hlsAsset?.secure_url

  if (videoId && hlsUrl) {
    await service.markAsProcessed(videoId, hlsUrl)
    return res.status(200).json({ message: "Processed" })
  }

  console.log(`[Cloudinary Webhook] Notification reçue mais pas encore prête ou mal formatée.`)
  res.sendStatus(200)
}
