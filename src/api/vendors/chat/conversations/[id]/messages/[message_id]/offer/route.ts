import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"
import { CHAT_MODULE } from "../../../../../../../../modules/chat"
import ChatModuleService from "../../../../../../../../modules/chat/service"
import { getIO } from "../../../../../../../../modules/socket/service"
import { NOTIFICATION_MODULE } from "../../../../../../../../modules/notification-center"
import NotificationCenterService from "../../../../../../../../modules/notification-center/service"
import { sendPushNotification } from "../../../../../../../../modules/notification-center/push-service"

/** Le vendeur répond à une offre du client : accept / reject / counter */
export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const chatService: ChatModuleService = req.scope.resolve(CHAT_MODULE)
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const conversationId = req.params.id
  const messageId = req.params.message_id
  const { action, amount } = req.body as {
    action?: "accept" | "reject" | "counter"
    amount?: number
  }

  if (!action || !["accept", "reject", "counter"].includes(action)) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "action must be accept, reject or counter"
    )
  }

  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id"],
    filters: { id: [req.auth_context.actor_id] },
  })

  let conversation
  try {
    conversation = await chatService.retrieveConversation(conversationId)
  } catch {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Conversation not found")
  }

  if (conversation.vendor_id !== vendorAdmin?.vendor?.id) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Conversation not found")
  }

  const message = await chatService.retrieveMessage(messageId)
  if (message.conversation_id !== conversationId) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Message not found in this conversation")
  }

  const result = await chatService.updateOfferStatus(messageId, "vendor", action, amount)

  const io = getIO()
  if (io) {
    io.to(`conversation:${conversationId}`).emit("offer_updated", {
      conversation_id: conversationId,
      message_id: messageId,
      metadata: result.metadata,
    })
  }

  // Notifier le client
  try {
    const notifService: NotificationCenterService = req.scope.resolve(NOTIFICATION_MODULE)
    const titles: Record<string, string> = {
      accept: "Offre acceptée 🎉",
      reject: "Offre refusée",
      counter: "Contre-offre reçue",
    }
    const bodies: Record<string, string> = {
      accept: "Le vendeur a accepté votre offre. Finalisez votre commande !",
      reject: "Le vendeur a refusé votre offre.",
      counter: `Le vendeur propose ${amount ?? ""}. Répondez dans le chat.`,
    }
    const notif = await notifService.createNotification({
      recipient_id: conversation.customer_id,
      recipient_type: "customer",
      type: "offer_response",
      title: titles[action],
      body: bodies[action],
      data: { conversation_id: conversationId, message_id: messageId },
    })
    const unreadCount = await notifService.countUnread(conversation.customer_id)
    if (io) {
      io.to(`user:${conversation.customer_id}`).emit("new_notification", {
        notification: notif,
        count: unreadCount,
      })
    }
    const tokens = await notifService.getRecipientTokens(conversation.customer_id)
    if (tokens.length > 0) {
      await sendPushNotification(
        tokens.map((t: any) => t.token),
        titles[action],
        bodies[action],
        { conversation_id: conversationId }
      )
    }
  } catch (err) {
    console.error("Failed to notify customer of offer response:", err)
  }

  res.status(200).json({ message_id: messageId, metadata: result.metadata })
}
