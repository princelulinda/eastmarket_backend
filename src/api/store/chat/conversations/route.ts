import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { z } from "@medusajs/framework/zod"
import { CHAT_MODULE } from "../../../../modules/chat"
import ChatModuleService from "../../../../modules/chat/service"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { FOLLOW_MODULE } from "../../../../modules/follow"
import { LOYALTY_MODULE } from "../../../../modules/loyalty"

export const PostConversationSchema = z.object({
  vendor_id: z.string(),
}).strict()

type PostBody = z.infer<typeof PostConversationSchema>

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const chatService: ChatModuleService = req.scope.resolve(CHAT_MODULE)
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  
  const conversations = await chatService.listConversationsByCustomer(req.auth_context.actor_id)

  // Canaux de diffusion des vendeurs suivis
  let broadcasts: any[] = []
  try {
    const followService: any = req.scope.resolve(FOLLOW_MODULE)
    const followedVendorIds: string[] = await followService.listFollowedVendorIds(
      req.auth_context.actor_id
    )
    if (followedVendorIds.length > 0) {
      broadcasts = await chatService.listConversations({
        vendor_id: followedVendorIds,
        type: "broadcast",
      } as any)
    }
  } catch (err) {
    console.error("Failed to list broadcast channels:", err)
  }

  const allConversations = [...conversations, ...broadcasts]

  // Extraire les IDs de vendeurs
  const vendorIds = [...new Set(allConversations.map(c => c.vendor_id).filter(Boolean))]

  // Récupérer les détails des vendeurs
  const { data: vendors } = await query.graph({
    entity: "vendor",
    fields: ["id", "name", "logo"],
    filters: { id: vendorIds }
  })

  // Fusionner les données
  const enrichedConversations = allConversations.map(conv => ({
    ...conv,
    vendor: vendors.find(v => v.id === conv.vendor_id)
  }))

  res.json({ conversations: enrichedConversations })
}

export const POST = async (req: AuthenticatedMedusaRequest<PostBody>, res: MedusaResponse) => {
  const chatService: ChatModuleService = req.scope.resolve(CHAT_MODULE)
  const vendorId = req.validatedBody.vendor_id

  const existing = await chatService.listConversations({
    customer_id: req.auth_context.actor_id,
    vendor_id: vendorId,
  })
  const isNew = existing.length === 0

  const conversation = await chatService.findOrCreateConversation(
    req.auth_context.actor_id,
    vendorId
  )

  // Message de bienvenue automatique du vendeur à la première conversation
  if (isNew) {
    try {
      const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
      const { data: [vendor] } = await query.graph({
        entity: "vendor",
        fields: ["id", "name", "metadata"],
        filters: { id: [vendorId] },
      })
      const welcome =
        (vendor as any)?.metadata?.chat_welcome_message ||
        `Bienvenue chez ${vendor?.name ?? "notre boutique"} 👋 Posez-nous vos questions, nous vous répondons rapidement !`

      await chatService.sendMessage({
        conversation_id: conversation.id,
        sender_type: "vendor",
        sender_id: vendorId,
        content: welcome,
        type: "text",
      })
    } catch (err) {
      console.error("Failed to send welcome message:", err)
    }

    // Points de fidélité pour la première conversation avec ce vendeur
    // (uniquement à la création — pas de récompense au volume de messages)
    try {
      const loyaltyService: any = req.scope.resolve(LOYALTY_MODULE)
      await loyaltyService.addPoints(
        req.auth_context.actor_id,
        10,
        "chat_engagement",
        conversation.id,
        "Première conversation avec un vendeur"
      )
    } catch (err) {
      console.error("Failed to award chat loyalty points:", err)
    }
  }

  res.json({ conversation })
}
