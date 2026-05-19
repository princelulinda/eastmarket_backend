import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { z } from "@medusajs/framework/zod"
import { CHAT_MODULE } from "../../../../modules/chat"
import ChatModuleService from "../../../../modules/chat/service"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"

export const PostConversationSchema = z.object({
  vendor_id: z.string(),
}).strict()

type PostBody = z.infer<typeof PostConversationSchema>

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const chatService: ChatModuleService = req.scope.resolve(CHAT_MODULE)
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  
  const conversations = await chatService.listConversationsByCustomer(req.auth_context.actor_id)
  
  // Extraire les IDs de vendeurs
  const vendorIds = conversations.map(c => c.vendor_id)
  console.log("DEBUG: Vendor IDs from conversations:", vendorIds)
  
  // Récupérer les détails des vendeurs
  const { data: vendors } = await query.graph({
    entity: "vendor",
    fields: ["id", "name", "logo"],
    filters: { id: vendorIds }
  })
  console.log("DEBUG: Vendors found:", vendors)
  
  // Fusionner les données
  const enrichedConversations = conversations.map(conv => ({
    ...conv,
    vendor: vendors.find(v => v.id === conv.vendor_id)
  }))
  console.log("DEBUG: Enriched conversations:", JSON.stringify(enrichedConversations, null, 2))

  res.json({ conversations: enrichedConversations })
}

export const POST = async (req: AuthenticatedMedusaRequest<PostBody>, res: MedusaResponse) => {
  const chatService: ChatModuleService = req.scope.resolve(CHAT_MODULE)
  const conversation = await chatService.findOrCreateConversation(
    req.auth_context.actor_id,
    req.validatedBody.vendor_id
  )
  res.json({ conversation })
}
