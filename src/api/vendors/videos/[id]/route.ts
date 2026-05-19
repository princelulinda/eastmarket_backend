import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { MedusaError, ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { z } from "@medusajs/framework/zod"
import { SHORT_VIDEO_MODULE } from "../../../../modules/short-video"
import ShortVideoService from "../../../../modules/short-video/service"

export const PutVendorVideoSchema = z.object({
  title: z.string().min(1).optional(),
  video_url: z.string().url().optional(),
  description: z.string().optional(),
  thumbnail_url: z.string().url().optional(),
  duration: z.number().int().positive().optional(),
  tag: z.string().optional(),
  status: z.enum(["draft", "published", "archived"]).optional(),
  product_ids: z.array(z.string()).optional(),
}).strict()

type PutBody = z.infer<typeof PutVendorVideoSchema>

async function resolveVendorId(req: AuthenticatedMedusaRequest): Promise<string> {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id"],
    filters: { id: [req.auth_context.actor_id] },
  })
  return vendorAdmin.vendor.id
}

async function assertOwnership(svc: ShortVideoService, videoId: string, vendorId: string) {
  const video = await svc.retrieveShortVideo(videoId)
  if (video.vendor_id !== vendorId) {
    throw new MedusaError(MedusaError.Types.NOT_ALLOWED, "Access denied")
  }
  return video
}

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const svc: ShortVideoService = req.scope.resolve(SHORT_VIDEO_MODULE)
  const vendorId = await resolveVendorId(req)
  const video = await assertOwnership(svc, req.params.id, vendorId)
  res.json({ video })
}

export const PUT = async (req: AuthenticatedMedusaRequest<PutBody>, res: MedusaResponse) => {
  const svc: ShortVideoService = req.scope.resolve(SHORT_VIDEO_MODULE)
  const vendorId = await resolveVendorId(req)
  await assertOwnership(svc, req.params.id, vendorId)
  const video = await svc.updateVideo(req.params.id, req.validatedBody)
  res.json({ video })
}

export const DELETE = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const svc: ShortVideoService = req.scope.resolve(SHORT_VIDEO_MODULE)
  const vendorId = await resolveVendorId(req)
  await assertOwnership(svc, req.params.id, vendorId)
  await svc.deleteShortVideoes(req.params.id)
  res.json({ deleted: true })
}
