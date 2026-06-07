import { 
  AuthenticatedMedusaRequest, 
  MedusaResponse 
} from "@medusajs/framework"
import { Modules, ContainerRegistrationKeys } from "@medusajs/framework/utils"
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
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id"],
    filters: { id: [req.auth_context.actor_id] },
  })

  if (!vendorAdmin) {
    return res.status(401).json({ message: "Vendor admin not found" })
  }

  const vendorId = vendorAdmin.vendor.id
  const validated = PostVendorVideoSchema.parse(req.body)

  const service = req.scope.resolve(SHORT_VIDEO_MODULE) as ShortVideoService
  const eventBus = req.scope.resolve(Modules.EVENT_BUS)

  const video = await service.createVideo({
    vendor_id: vendorId,
    ...validated,
  }, eventBus)

  res.json({
    video,
  })
}

export const GET = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id"],
    filters: { id: [req.auth_context.actor_id] },
  })

  if (!vendorAdmin) {
    return res.status(401).json({ message: "Vendor admin not found" })
  }

  const vendorId = vendorAdmin.vendor.id
  const service = req.scope.resolve(SHORT_VIDEO_MODULE) as ShortVideoService

  const videos = await service.getVendorVideos(vendorId)

  // Extract all unique product IDs
  const productIds = Array.from(
    new Set(videos.flatMap((v: any) => v.product_ids || []))
  )

  if (productIds.length > 0) {
    const { data: products } = await query.graph({
      entity: "product",
      fields: ["id", "title", "thumbnail"],
      filters: { id: productIds }
    })

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
