import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import { CHAT_MODULE } from "../../../../../../../../modules/chat"
import ChatModuleService from "../../../../../../../../modules/chat/service"
import { getIO } from "../../../../../../../../modules/socket/service"
import { NOTIFICATION_MODULE } from "../../../../../../../../modules/notification-center"
import NotificationCenterService from "../../../../../../../../modules/notification-center/service"
import { sendPushNotification } from "../../../../../../../../modules/notification-center/push-service"

/** Le client répond à une contre-offre du vendeur : accept / reject */
export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const chatService: ChatModuleService = req.scope.resolve(CHAT_MODULE)
  const conversationId = req.params.id
  const messageId = req.params.message_id
  const { action } = req.body as { action?: "accept" | "reject" }

  if (!action || !["accept", "reject"].includes(action)) {
    throw new MedusaError(MedusaError.Types.INVALID_DATA, "action must be accept or reject")
  }

  let conversation
  try {
    conversation = await chatService.retrieveConversation(conversationId)
  } catch {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Conversation not found")
  }

  if (conversation.customer_id !== req.auth_context.actor_id) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Conversation not found")
  }

  const message = await chatService.retrieveMessage(messageId)
  if (message.conversation_id !== conversationId) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Message not found in this conversation")
  }

  const result = await chatService.updateOfferStatus(messageId, "customer", action)

  const io = getIO()
  if (io) {
    io.to(`conversation:${conversationId}`).emit("offer_updated", {
      conversation_id: conversationId,
      message_id: messageId,
      metadata: result.metadata,
    })
  }

  // Notifier le vendeur
  try {
    const notifService: NotificationCenterService = req.scope.resolve(NOTIFICATION_MODULE)
    const statusLabel = action === "accept" ? "acceptée" : "refusée"
    const notif = await notifService.createNotification({
      recipient_id: conversation.vendor_id,
      recipient_type: "vendor",
      type: "offer_response",
      title: `Contre-offre ${statusLabel}`,
      body: `Le client a ${action === "accept" ? "accepté" : "refusé"} votre contre-offre.`,
      data: { conversation_id: conversationId, message_id: messageId },
    })
    const unreadCount = await notifService.countUnread(conversation.vendor_id)
    if (io) {
      io.to(`user:${conversation.vendor_id}`).emit("new_notification", {
        notification: notif,
        count: unreadCount,
      })
    }
    const tokens = await notifService.getRecipientTokens(conversation.vendor_id)
    if (tokens.length > 0) {
      await sendPushNotification(
        tokens.map((t: any) => t.token),
        `Contre-offre ${statusLabel}`,
        notif.body || "",
        { conversation_id: conversationId }
      )
    }
  } catch (err) {
    console.error("Failed to notify vendor of offer response:", err)
  }

  res.status(200).json({ message_id: messageId, metadata: result.metadata })
}
