import { 
  AuthenticatedMedusaRequest, 
  MedusaResponse 
} from "@medusajs/framework"
import { SHORT_VIDEO_MODULE } from "../../../../modules/short-video"
import ShortVideoService from "../../../../modules/short-video/service"

// GET /store/videos/:id — Détail d'une vidéo
export const GET = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const service = req.scope.resolve(SHORT_VIDEO_MODULE) as ShortVideoService
  const query = req.scope.resolve("query")

  const video = await service.retrieveShortVideo(req.params.id)
  
  if (video.product_ids && video.product_ids.length > 0) {
    const { data: products } = await query.graph({
      entity: "product",
      fields: ["id", "title", "thumbnail", "variants.prices.*"],
      filters: { id: video.product_ids }
    })
    ;(video as any).products = products
  }

  res.json({ video })
}

// POST /store/videos/:id/view — Incrémenter les vues
export const POST = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const service = req.scope.resolve(SHORT_VIDEO_MODULE) as ShortVideoService
  
  if (req.url.endsWith('/view')) {
    await service.incrementView(req.params.id)
    return res.json({ message: "View incremented" })
  }
  
  if (req.url.endsWith('/share')) {
    await service.incrementShare(req.params.id)
    return res.json({ message: "Share incremented" })
  }

  res.status(404).json({ message: "Not found" })
}
