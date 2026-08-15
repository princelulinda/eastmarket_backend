import { CHAT_MODULE } from "./index"
import ChatModuleService from "./service"
import { getIO } from "../socket/service"

type OrderChatUpdate = {
  customerId: string
  vendorId: string
  orderId: string
  displayId: string | number
  status: string
  body: string
}

/**
 * Poste un message système "order_update" dans la conversation client↔vendeur
 * (créée si besoin) et le diffuse en temps réel. Chaque commande devient
 * un fil vivant dans le chat.
 */
export async function postOrderUpdateToChat(
  container: any,
  { customerId, vendorId, orderId, displayId, status, body }: OrderChatUpdate
) {
  if (!customerId || !vendorId) return

  try {
    const chatService: ChatModuleService = container.resolve(CHAT_MODULE)
    const conversation = await chatService.findOrCreateConversation(customerId, vendorId)

    const message = await chatService.sendMessage({
      conversation_id: conversation.id,
      sender_type: "vendor",
      sender_id: vendorId,
      content: body,
      type: "order_update",
      metadata: {
        order_id: orderId,
        display_id: displayId,
        status,
      },
    })

    const io = getIO()
    if (io) {
      io.to(`conversation:${conversation.id}`).emit("message_received", {
        message,
        conversation_id: conversation.id,
      })
      const conversationUpdate = {
        id: conversation.id,
        customer_id: conversation.customer_id,
        vendor_id: conversation.vendor_id,
        last_message_at: message.created_at,
        last_message: {
          id: message.id,
          content: message.content,
          sender_type: message.sender_type,
          sender_id: message.sender_id,
          type: message.type,
          file_url: message.file_url,
          created_at: message.created_at,
        },
      }
      io.to(`user:${customerId}`).emit("conversation_list_updated", conversationUpdate)
      io.to(`user:${vendorId}`).emit("conversation_list_updated", conversationUpdate)
    }
  } catch (err) {
    console.error("[order-chat] Failed to post order update to chat:", err)
  }
}
