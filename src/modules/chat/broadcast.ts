import { CHAT_MODULE } from "./index"
import ChatModuleService from "./service"
import { FOLLOW_MODULE } from "../follow"
import { getIO } from "../socket/service"
import { NOTIFICATION_MODULE } from "../notification-center"
import NotificationCenterService from "../notification-center/service"
import { sendPushNotification } from "../notification-center/push-service"

type BroadcastInput = {
  content: string
  type?: string
  file_url?: string
  metadata?: Record<string, unknown>
  vendorName?: string | null
}

/**
 * Publie une annonce dans le canal de diffusion du vendeur et notifie
 * tous ses abonnés (notification in-app + push groupé).
 */
export async function postBroadcastAnnouncement(
  container: any,
  vendorId: string,
  { content, type = "text", file_url, metadata, vendorName }: BroadcastInput
) {
  const chatService: ChatModuleService = container.resolve(CHAT_MODULE)
  const followService: any = container.resolve(FOLLOW_MODULE)
  const notifService: NotificationCenterService = container.resolve(NOTIFICATION_MODULE)

  const conversation = await chatService.findOrCreateBroadcastConversation(vendorId)

  const message = await chatService.sendMessage({
    conversation_id: conversation.id,
    sender_type: "vendor",
    sender_id: vendorId,
    content,
    type: type as any,
    file_url,
    metadata,
  })

  const io = getIO()
  if (io) {
    io.to(`conversation:${conversation.id}`).emit("message_received", {
      message,
      conversation_id: conversation.id,
    })
  }

  try {
    const followerIds: string[] = await followService.listFollowerCustomerIds(vendorId)
    const pushTitle = `📢 ${vendorName ?? "Boutique suivie"}`
    const pushBody = content.substring(0, 100)

    const allTokens: string[] = []
    for (const customerId of followerIds) {
      const notif = await notifService.createNotification({
        recipient_id: customerId,
        recipient_type: "customer",
        type: "new_message",
        title: pushTitle,
        body: pushBody,
        data: { conversation_id: conversation.id, broadcast: true },
      })
      if (io) {
        const count = await notifService.countUnread(customerId)
        io.to(`user:${customerId}`).emit("new_notification", { notification: notif, count })
      }
      if (await notifService.isPushAllowed(customerId, "broadcasts")) {
        const tokens = await notifService.getRecipientTokens(customerId)
        allTokens.push(...tokens.map((t: any) => t.token))
      }
    }

    if (allTokens.length > 0) {
      await sendPushNotification(allTokens, pushTitle, pushBody, {
        conversation_id: conversation.id,
      })
    }
  } catch (err) {
    console.error("Failed to notify followers of broadcast:", err)
  }

  return { conversation, message }
}
