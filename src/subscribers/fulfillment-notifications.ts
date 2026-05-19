import { SubscriberArgs, SubscriberConfig } from "@medusajs/framework"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { NOTIFICATION_MODULE } from "../modules/notification-center"
import NotificationCenterService from "../modules/notification-center/service"
import { getIO } from "../modules/socket/service"

export default async function fulfillmentCreatedHandler({
  event: { data },
  container,
}: SubscriberArgs<{ id: string; order_id: string }>) {
  const query = container.resolve(ContainerRegistrationKeys.QUERY)
  const notifService: NotificationCenterService = container.resolve(NOTIFICATION_MODULE)

  const { data: [order] } = await query.graph({
    entity: "order",
    fields: ["id", "display_id", "customer_id"],
    filters: { id: data.order_id }
  })

  if (!order) return

  const notif = await notifService.createNotification({
    recipient_id: order.customer_id,
    recipient_type: "customer",
    type: "order_shipped",
    title: "Commande expédiée",
    body: `Votre commande #${order.display_id} est en route !`,
    data: { order_id: order.id, display_id: order.display_id },
  })

  const io = getIO()
  if (io) {
    const count = await notifService.countUnread(order.customer_id)
    io.to(`user:${order.customer_id}`).emit("new_notification", {
      notification: notif,
      count,
    })
  }
}

export const config: SubscriberConfig = {
  event: "order.fulfillment_created",
}
