import { MedusaContainer } from "@medusajs/framework/types"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { CHAT_MODULE } from "../modules/chat"
import ChatModuleService from "../modules/chat/service"
import { NOTIFICATION_MODULE } from "../modules/notification-center"
import NotificationCenterService from "../modules/notification-center/service"
import { sendPushNotification } from "../modules/notification-center/push-service"

const DAY_MS = 24 * 60 * 60 * 1000

/**
 * Relances douces, UNE seule fois par sujet (anti-spam) :
 *  1. Message vendeur non lu depuis 24 h → un rappel push au client.
 *  2. Panier abandonné depuis 24 h → suggestion de poser la question au vendeur.
 */
export default async function chatRemindersJob(container: MedusaContainer) {
  const logger = container.resolve("logger")
  const chatService: ChatModuleService = container.resolve(CHAT_MODULE)
  const notifService: NotificationCenterService = container.resolve(NOTIFICATION_MODULE)
  const query = container.resolve(ContainerRegistrationKeys.QUERY)

  const now = Date.now()

  // ── 1. Messages vendeur non lus depuis 24 h ────────────────────────────────
  try {
    const conversations = await chatService.listConversations({}, { take: null } as any)

    for (const conv of conversations) {
      if (!conv.customer_id || !conv.vendor_id) continue

      const unread = await chatService.listMessages(
        {
          conversation_id: conv.id,
          sender_type: "vendor",
          is_read: false,
        } as any,
        { order: { created_at: "DESC" }, take: 1 } as any
      )
      if (unread.length === 0) continue

      const lastUnread = unread[0] as any
      const age = now - new Date(lastUnread.created_at).getTime()
      // Fenêtre 24h–72h : jamais de rappel avant 24 h, jamais après 72 h
      if (age < DAY_MS || age > 3 * DAY_MS) continue

      // Déduplication : un seul rappel par conversation par 7 jours
      const previous = await notifService.listAppNotifications(
        { recipient_id: conv.customer_id, type: "chat_reminder" } as any,
        { order: { created_at: "DESC" }, take: 20 } as any
      )
      const alreadyReminded = previous.some(
        (n: any) =>
          n.data?.conversation_id === conv.id &&
          now - new Date(n.created_at).getTime() < 7 * DAY_MS
      )
      if (alreadyReminded) continue

      if (!(await notifService.isPushAllowed(conv.customer_id, "reminders"))) continue

      const notif = await notifService.createNotification({
        recipient_id: conv.customer_id,
        recipient_type: "customer",
        type: "chat_reminder",
        title: "Un vendeur vous a répondu 💬",
        body: lastUnread.content?.substring(0, 100) || "Vous avez un message non lu.",
        data: { conversation_id: conv.id },
      })

      const tokens = await notifService.getRecipientTokens(conv.customer_id)
      if (tokens.length > 0) {
        await sendPushNotification(
          tokens.map((t: any) => t.token),
          notif.title,
          notif.body || "",
          { conversation_id: conv.id }
        )
      }
    }
  } catch (err) {
    logger.error("[chat-reminders] unread reminder pass failed:", err)
  }

  // ── 2. Paniers abandonnés depuis 24 h ─────────────────────────────────────
  try {
    const { data: carts } = await query.graph({
      entity: "cart",
      fields: ["id", "customer_id", "updated_at", "completed_at", "items.id"],
      filters: {} as any,
    })

    for (const cart of carts || []) {
      if (!cart.customer_id || cart.completed_at) continue
      if (!cart.items || cart.items.length === 0) continue

      const age = now - new Date(cart.updated_at).getTime()
      if (age < DAY_MS || age > 3 * DAY_MS) continue

      const previous = await notifService.listAppNotifications(
        { recipient_id: cart.customer_id, type: "cart_reminder" } as any,
        { order: { created_at: "DESC" }, take: 10 } as any
      )
      const alreadyReminded = previous.some(
        (n: any) => now - new Date(n.created_at).getTime() < 7 * DAY_MS
      )
      if (alreadyReminded) continue

      if (!(await notifService.isPushAllowed(cart.customer_id, "reminders"))) continue

      const notif = await notifService.createNotification({
        recipient_id: cart.customer_id,
        recipient_type: "customer",
        type: "cart_reminder",
        title: "Votre panier vous attend 🛒",
        body: "Une question avant de commander ? Posez-la directement au vendeur dans le chat.",
        data: { screen: "/cart-page" },
      })

      const tokens = await notifService.getRecipientTokens(cart.customer_id)
      if (tokens.length > 0) {
        await sendPushNotification(
          tokens.map((t: any) => t.token),
          notif.title,
          notif.body || "",
          { screen: "/cart-page" }
        )
      }
    }
  } catch (err) {
    logger.error("[chat-reminders] abandoned cart pass failed:", err)
  }

  logger.info("[chat-reminders] Reminder job completed.")
}

export const config = {
  name: "chat-reminders",
  // Toutes les 6 heures
  schedule: "0 */6 * * *",
}
