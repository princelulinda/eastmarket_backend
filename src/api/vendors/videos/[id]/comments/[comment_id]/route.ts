import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"
import { SHORT_VIDEO_MODULE } from "../../../../../../modules/short-video"
import ShortVideoService from "../../../../../../modules/short-video/service"

/**
 * DELETE /vendors/videos/:id/comments/:comment_id
 *
 * Modération : le vendeur retire un commentaire de sa propre vidéo. Les
 * réponses directes partent avec, sinon elles resteraient orphelines dans le fil.
 */
export const DELETE = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const svc = req.scope.resolve(SHORT_VIDEO_MODULE) as ShortVideoService
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id"],
    filters: { id: [req.auth_context.actor_id] },
  })

  if (!vendorAdmin?.vendor?.id) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Vendor not found")
  }

  const video = await (svc as any).retrieveShortVideo(req.params.id).catch(() => null)
  if (!video || video.vendor_id !== vendorAdmin.vendor.id) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Video not found")
  }

  const result = await svc.deleteComment(req.params.id, req.params.comment_id)
  if (!result) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Comment not found")
  }

  res.json({
    id: req.params.comment_id,
    object: "video_comment",
    deleted: true,
    deleted_ids: result.deleted_ids,
    comments_count: result.comments_count,
  })
}
