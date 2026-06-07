import { 
  AuthenticatedMedusaRequest, 
  MedusaResponse 
} from "@medusajs/framework"
import { z } from "@medusajs/framework/zod"
import { Modules } from "@medusajs/framework/utils"
import { SHORT_VIDEO_MODULE } from "../../../../../modules/short-video"
import ShortVideoService from "../../../../../modules/short-video/service"

export const PostCommentSchema = z.object({
  content: z.string().min(1),
  parent_id: z.string().optional().nullable(),
})

export const GET = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const service = req.scope.resolve(SHORT_VIDEO_MODULE) as ShortVideoService
  const { limit = 20, offset = 0 } = req.query as any

  const comments = await service.getComments(req.params.id, Number(limit), Number(offset))

  const customerModule = req.scope.resolve(Modules.CUSTOMER)
  const enrichedComments = await Promise.all(
    comments.map(async (comment: any) => {
      if (!comment.customer_id) return comment
      try {
        const customer = await customerModule.retrieveCustomer(comment.customer_id)
        return { ...comment, customer }
      } catch (e) {
        return comment
      }
    })
  )

  res.json({ comments: enrichedComments })
}

export const POST = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const customerId = req.auth_context.actor_id
  const { content, parent_id } = PostCommentSchema.parse(req.body)
  const service = req.scope.resolve(SHORT_VIDEO_MODULE) as ShortVideoService

  const comment = await service.addComment(
    req.params.id, 
    customerId, 
    content, 
    parent_id || undefined
  )

  res.json({ comment })
}
