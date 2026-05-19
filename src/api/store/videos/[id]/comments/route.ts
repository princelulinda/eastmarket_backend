import { 
  AuthenticatedMedusaRequest, 
  MedusaResponse 
} from "@medusajs/framework"
import { z } from "@medusajs/framework/zod"
import { SHORT_VIDEO_MODULE } from "../../../../../modules/short-video"
import ShortVideoService from "../../../../../modules/short-video/service"

export const PostCommentSchema = z.object({
  content: z.string().min(1),
})

export const GET = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const service = req.scope.resolve(SHORT_VIDEO_MODULE) as ShortVideoService
  const { limit = 20, offset = 0 } = req.query as any

  const comments = await service.getComments(req.params.id, Number(limit), Number(offset))

  res.json({ comments })
}

export const POST = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const customerId = req.auth_context.actor_id
  const validated = PostCommentSchema.parse(req.body)
  const service = req.scope.resolve(SHORT_VIDEO_MODULE) as ShortVideoService

  const comment = await service.addComment(req.params.id, customerId, validated.content)

  res.json({ comment })
}
