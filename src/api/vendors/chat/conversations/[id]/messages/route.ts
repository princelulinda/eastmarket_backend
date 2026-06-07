import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"
import { CHAT_MODULE } from "../../../../../../modules/chat"
import ChatModuleService from "../../../../../../modules/chat/service"
import { getIO } from "../../../../../../modules/socket/service"
import { NOTIFICATION_MODULE } from "../../../../../../modules/notification-center"
import NotificationCenterService from "../../../../../../modules/notification-center/service"
import { sendPushNotification } from "../../../../../../modules/notification-center/push-service"


export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const chatService: ChatModuleService = req.scope.resolve(CHAT_MODULE)
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id"],
    filters: { id: [req.auth_context.actor_id] }
  })

  let conversation
  try {
    conversation = await chatService.retrieveConversation(req.params.id)
  } catch {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Conversation not found")
  }

  if (conversation.vendor_id !== vendorAdmin.vendor.id) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Conversation not found")
  }

  const limit = Number(req.query.limit) || 50
  const offset = Number(req.query.offset) || 0

  const messages = await chatService.getMessages(req.params.id, limit, offset)

  res.json({ messages, count: messages.length, limit, offset })
}

export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const { id } = req.params
  const chatService: ChatModuleService = req.scope.resolve(CHAT_MODULE)
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const io = getIO()

  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id"],
    filters: { id: [req.auth_context.actor_id] }
  })

  const conversation = await chatService.retrieveConversation(id)
  if (conversation.vendor_id !== vendorAdmin.vendor.id) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Conversation not found")
  }

  const message = await chatService.sendMessage({
    conversation_id: id,
    sender_type: "vendor",
    sender_id: vendorAdmin.vendor.id,
    content: req.body.content,
    type: req.body.type || "text",
    file_url: req.body.file_url,
  })

  if (io) {
    io.to(`conversation:${id}`).emit("message_received", {
      message,
      conversation_id: id,
    })
  }

  // Création et envoi de la notification et mise à jour de la liste de conversation
  const notifService: NotificationCenterService = req.scope.resolve(NOTIFICATION_MODULE)
  const recipientId = conversation.customer_id
  const contentText = req.body.content || ""

  try {
    // ─── Envoi des mises à jour dynamiques de la liste de conversation (WhatsApp flow) ───
    if (io) {
      try {
        const unreadMsgs = await chatService.listMessages({
          conversation_id: id,
          sender_type: "vendor", // non lu pour le client
          is_read: false,
        } as any)

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
          unread_count: unreadMsgs.length,
        }

        // Mettre à jour le client
        io.to(`user:${recipientId}`).emit("conversation_list_updated", conversationUpdate)
        // Mettre à jour le vendeur (expéditeur) avec 0 messages non lus
        io.to(`user:${vendorAdmin.vendor.id}`).emit("conversation_list_updated", {
          ...conversationUpdate,
          unread_count: 0,
        })
      } catch (err) {
        console.error("Failed to emit conversation_list_updated from REST POST vendor message:", err)
      }
    }

    const notif = await notifService.createNotification({
      recipient_id: recipientId,
      recipient_type: "customer",
      type: "new_message",
      title: "Nouveau message",
      body: contentText.substring(0, 100),
      data: {
        conversation_id: id,
        sender_type: "vendor",
        sender_id: vendorAdmin.vendor.id,
      },
    })

    const unreadCount = await notifService.countUnread(recipientId)

    if (io) {
      io.to(`user:${recipientId}`).emit("new_notification", {
        notification: notif,
        count: unreadCount,
      })
    }

    // Push Notification (Expo)
    const tokens = await notifService.getRecipientTokens(recipientId)
    if (tokens.length > 0) {
      await sendPushNotification(
        tokens.map(t => t.token),
        "Nouveau message",
        contentText.substring(0, 100),
        { conversation_id: id }
      )
    }
  } catch (error) {
    console.error("Failed to process message notification in vendor route:", error)
  }

  res.json({ message })
}
