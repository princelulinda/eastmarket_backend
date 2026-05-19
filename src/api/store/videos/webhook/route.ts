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
  
  // Format réel de la notification Cloudinary
  const payload = req.body
  
  // On extrait l'ID de la vidéo à partir du public_id (ex: "marketplace/videos/vid_123")
  const publicId = payload.public_id
  const videoId = publicId.split('/').pop()

  // On cherche l'URL m3u8 (HLS) dans les résultats "eager" de Cloudinary
  const hlsAsset = payload.eager?.find((e: any) => e.format === "m3u8")
  const hlsUrl = hlsAsset?.secure_url

  if (videoId && hlsUrl) {
    await service.markAsProcessed(videoId, hlsUrl)
    console.log(`[Cloudinary Webhook] Vidéo ${videoId} est prête : ${hlsUrl}`)
    return res.status(200).json({ message: "Processed" })
  }

  console.log(`[Cloudinary Webhook] Notification reçue mais pas encore prête ou mal formatée.`)
  res.sendStatus(200)
}
