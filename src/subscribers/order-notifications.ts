import { SubscriberArgs, SubscriberConfig } from "@medusajs/framework"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { NOTIFICATION_MODULE } from "../modules/notification-center"
import NotificationCenterService from "../modules/notification-center/service"
import { getIO } from "../modules/socket/service"

// ── New Order ──────────────────────────────────────────────────────────────

export default async function orderPlacedHandler({
  event: { data },
  container,
}: SubscriberArgs<{ id: string }>) {
  const query = container.resolve(ContainerRegistrationKeys.QUERY)
  const notifService: NotificationCenterService = container.resolve(NOTIFICATION_MODULE)

  const { data: [order] } = await query.graph({
    entity: "order",
    fields: ["id", "display_id", "customer_id", "vendor.id", "vendor.name"],
    filters: { id: data.id }
  })

  if (!order) return

  // Notify customer
  const customerNotif = await notifService.createNotification({
    recipient_id: order.customer_id,
    recipient_type: "customer",
    type: "new_order",
    title: "Commande confirmée",
    body: `Votre commande #${order.display_id} a été confirmée.`,
    data: { order_id: order.id, display_id: order.display_id },
  })

  // Notify vendor if linked
  const vendorId = (order as any).vendor?.id
  if (vendorId) {
    const vendorNotif = await notifService.createNotification({
      recipient_id: vendorId,
      recipient_type: "vendor",
      type: "new_order",
      title: "Nouvelle commande",
      body: `Vous avez reçu une nouvelle commande #${order.display_id}.`,
      data: { order_id: order.id, display_id: order.display_id },
    })

    const io = getIO()
    if (io) {
      const vendorCount = await notifService.countUnread(vendorId)
      io.to(`user:${vendorId}`).emit("new_notification", {
        notification: vendorNotif,
        count: vendorCount,
      })
    }
  }

  const io = getIO()
  if (io) {
    const customerCount = await notifService.countUnread(order.customer_id)
    io.to(`user:${order.customer_id}`).emit("new_notification", {
      notification: customerNotif,
      count: customerCount,
    })
  }
}

export const config: SubscriberConfig = {
  event: "order.placed",
}
