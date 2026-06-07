import { 
  AuthenticatedMedusaRequest, 
  MedusaResponse 
} from "@medusajs/framework"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { SHORT_VIDEO_MODULE } from "../../../modules/short-video"
import ShortVideoService from "../../../modules/short-video/service"

export const GET = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const service = req.scope.resolve(SHORT_VIDEO_MODULE) as ShortVideoService
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { limit = 10, offset = 0 } = req.query as any

  const videos = await service.getFeed(Number(limit), Number(offset))

  // Extract all unique vendor IDs
  const vendorIds = Array.from(
    new Set(videos.map((v: any) => v.vendor_id).filter(Boolean))
  )

  if (vendorIds.length > 0) {
    const { data: vendors } = await query.graph({
      entity: "vendor",
      fields: ["id", "name", "logo"],
      filters: { id: vendorIds }
    })

    const vendorMap = new Map(vendors.map((v: any) => [v.id, v]))
    for (const video of videos) {
      if (video.vendor_id) {
        (video as any).vendor = vendorMap.get(video.vendor_id)
      }
    }
  }

  // Extract all unique product IDs from the videos
  const productIds = Array.from(
    new Set(videos.flatMap((v: any) => v.product_ids || []))
  )

  if (productIds.length > 0) {
    const { data: products } = await query.graph({
      entity: "product",
      fields: ["id", "title", "thumbnail", "variants.prices.*"],
      filters: { id: productIds }
    })

    // Map products to videos
    const productMap = new Map(products.map((p: any) => [p.id, p]))
    
    for (const video of videos) {
      if (video.product_ids) {
        (video as any).products = video.product_ids
          .map((id: string) => productMap.get(id))
          .filter(Boolean)
      }
    }
  }

  res.json({
    videos,
  })
}
