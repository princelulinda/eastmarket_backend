import { 
  AuthenticatedMedusaRequest, 
  MedusaResponse 
} from "@medusajs/framework"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { SHORT_VIDEO_MODULE } from "../../../../../modules/short-video"
import ShortVideoService from "../../../../../modules/short-video/service"

// GET /vendors/videos/:id/comments — Lister les commentaires
export const GET = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const service = req.scope.resolve(SHORT_VIDEO_MODULE) as ShortVideoService
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { limit = 20, offset = 0 } = req.query as any

  const comments = await service.getComments(req.params.id, Number(limit), Number(offset))

  // Extract unique customer IDs
  const customerIds = Array.from(
    new Set(comments.map((c: any) => c.customer_id).filter(Boolean))
  )

  if (customerIds.length > 0) {
    const { data: customers } = await query.graph({
      entity: "customer",
      fields: ["id", "first_name", "last_name", "email"], // Adjust fields based on what's available
      filters: { id: customerIds }
    })

    const customerMap = new Map(customers.map((c: any) => [c.id, c]))

    for (const comment of comments) {
      if (comment.customer_id) {
        (comment as any).customer = customerMap.get(comment.customer_id)
        delete (comment as any).customer_id
      }
    }
  }

  res.json({ comments })
}

// POST /vendors/videos/:id/comments — Répondre à un commentaire
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
  const { content, parent_id } = req.body
  const service = req.scope.resolve(SHORT_VIDEO_MODULE) as ShortVideoService

  const comment = await service.addComment(req.params.id, null, content, parent_id, vendorId)

  res.json({ comment })
}
