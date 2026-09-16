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
  // is_verified alimente le badge « Vérifié » de la liste côté app : sans lui
  // l'app devait recharger tout l'annuaire des vendeurs juste pour l'afficher.
  const { data: vendors } = await query.graph({
    entity: "vendor",
    fields: ["id", "name", "logo", "is_verified"],
    filters: { id: vendorIds }
  })

  // Non lus pour le client = messages du vendeur pas encore lus. Une seule
  // requête pour toute la liste, au lieu d'une par conversation.
  const unreadCounts = await chatService.countUnreadByConversation(
    allConversations.map((c) => c.id),
    "vendor"
  )

  // Fusionner les données et joindre le dernier message + le nombre de non-lus.
  // Sans ça, la liste renvoie les lignes brutes de `conversation`, qui ne
  // portent ni aperçu ni compteur : l'app afficherait « Démarrer une
  // conversation » même après un message du vendeur, et le badge disparaîtrait
  // à chaque rechargement de l'écran. Symétrique de /vendors/chat/conversations.
  const enrichedConversations = await Promise.all(
    allConversations.map(async (conv) => {
      const messages = await chatService.getMessages(conv.id, 1)
      const lastMessage = messages.length > 0 ? messages[0] : null

      return {
        ...conv,
        vendor: vendors.find(v => v.id === conv.vendor_id),
        last_message: lastMessage ? {
          id: lastMessage.id,
          content: lastMessage.content,
          sender_type: lastMessage.sender_type,
          sender_id: lastMessage.sender_id,
          type: lastMessage.type,
          file_url: lastMessage.file_url,
          created_at: lastMessage.created_at,
        } : null,
        unread_count: unreadCounts[conv.id] ?? 0,
      }
    })
  )

  // Les plus récentes d'abord, comme la liste se réordonne côté app
  enrichedConversations.sort((a, b) => {
    const ta = new Date(a.last_message?.created_at ?? a.last_message_at ?? 0).getTime()
    const tb = new Date(b.last_message?.created_at ?? b.last_message_at ?? 0).getTime()
    return tb - ta
  })

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
