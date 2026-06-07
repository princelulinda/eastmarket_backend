import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { CHAT_MODULE } from "../../../../modules/chat"
import ChatModuleService from "../../../../modules/chat/service"

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const chatService: ChatModuleService = req.scope.resolve(CHAT_MODULE)
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  // Get vendor_id from the authenticated vendor admin
  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id"],
    filters: { id: [req.auth_context.actor_id] }
  })

  const conversations = await chatService.listConversationsByVendor(vendorAdmin.vendor.id)
  
  // Extraire les IDs des clients
  const customerIds = conversations
    .map(c => c.customer_id)
    .filter((id): id is string => id !== null)
  
  // Récupérer les détails des clients (via Customer Module)
  const { data: customers } = await query.graph({
    entity: "customer",
    fields: ["id", "first_name", "last_name", "email"],
    filters: { id: customerIds }
  })
  
  // Fusionner les données et récupérer le dernier message & count unread pour chaque conversation
  const enrichedConversations = await Promise.all(
    conversations.map(async (conv) => {
      // Récupérer le dernier message
      const messages = await chatService.getMessages(conv.id, 1)
      const lastMessage = messages.length > 0 ? messages[0] : null

      // Compter le nombre de messages non lus envoyés par le client (donc non lus par le vendeur)
      const unreadMsgs = await chatService.listMessages({
        conversation_id: conv.id,
        sender_type: "customer",
        is_read: false,
      } as any)

      return {
        ...conv,
        customer: customers.find(c => c.id === conv.customer_id),
        last_message: lastMessage ? {
          id: lastMessage.id,
          content: lastMessage.content,
          sender_type: lastMessage.sender_type,
          sender_id: lastMessage.sender_id,
          type: lastMessage.type,
          file_url: lastMessage.file_url,
          created_at: lastMessage.created_at,
        } : null,
        unread_count: unreadMsgs.length,
      }
    })
  )

  // Trier les conversations par date du dernier message (WhatsApp flow)
  enrichedConversations.sort((a, b) => {
    const dateA = a.last_message_at ? new Date(a.last_message_at).getTime() : 0
    const dateB = b.last_message_at ? new Date(b.last_message_at).getTime() : 0
    return dateB - dateA
  })

  res.json({ conversations: enrichedConversations })
}

export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const chatService: ChatModuleService = req.scope.resolve(CHAT_MODULE)
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  
  const { customer_id } = req.body as { customer_id: string }
  if (!customer_id) {
    return res.status(400).json({ message: "customer_id is required" })
  }

  // Get vendor_id from the authenticated vendor admin
  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id"],
    filters: { id: [req.auth_context.actor_id] }
  })

  if (!vendorAdmin?.vendor?.id) {
     return res.status(400).json({ message: "Vendor not found" })
  }

  const conversation = await chatService.findOrCreateConversation(customer_id, vendorAdmin.vendor.id)
  
  res.status(200).json({ conversation })
}
