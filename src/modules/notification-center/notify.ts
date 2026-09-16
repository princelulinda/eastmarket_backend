import { MedusaContainer } from "@medusajs/framework/types"
import { NOTIFICATION_MODULE } from "."
import NotificationCenterService, { PushCategory } from "./service"
import { getIO } from "../socket/service"
import { sendPushNotification } from "./push-service"

type NotifyRecipientInput = {
  recipientId: string
  recipientType: "customer" | "vendor"
  type: string
  title: string
  body: string
  data?: Record<string, any>
  /** Catégorie de préférence push. La notification in-app est toujours créée. */
  pushCategory?: PushCategory
}

/**
 * Notification in-app + socket + push, en un appel.
 * Reprend la séquence utilisée par subscribers/order-notifications.ts ; chaque
 * canal échoue indépendamment pour qu'un push cassé n'empêche pas la
 * notification in-app.
 */
export async function notifyRecipient(
  container: MedusaContainer,
  { recipientId, recipientType, type, title, body, data, pushCategory = "orders" }: NotifyRecipientInput,
) {
  const notifService: NotificationCenterService = container.resolve(NOTIFICATION_MODULE)

  const notification = await notifService.createNotification({
    recipient_id: recipientId,
    recipient_type: recipientType,
    type,
    title,
    body,
    data,
  })

  try {
    const io = getIO()
    if (io) {
      const count = await notifService.countUnread(recipientId)
      io.to(`user:${recipientId}`).emit("new_notification", { notification, count })
    }
  } catch (err) {
    console.error(`Failed to push socket notification to ${recipientType} ${recipientId}:`, err)
  }

  try {
    if (await notifService.isPushAllowed(recipientId, pushCategory)) {
      const tokens = await notifService.getRecipientTokens(recipientId)
      if (tokens.length > 0) {
        await sendPushNotification(tokens.map((t: any) => t.token), title, body, data ?? {})
      }
    }
  } catch (err) {
    console.error(`Failed to send push notification to ${recipientType} ${recipientId}:`, err)
  }

  return notification
}

/** Raccourci pour le cas le plus fréquent. */
export async function notifyVendor(
  container: MedusaContainer,
  input: Omit<NotifyRecipientInput, "recipientId" | "recipientType"> & { vendorId: string },
) {
  const { vendorId, ...rest } = input
  return notifyRecipient(container, {
    ...rest,
    recipientId: vendorId,
    recipientType: "vendor",
  })
}
