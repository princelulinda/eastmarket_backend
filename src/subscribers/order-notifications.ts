import { SubscriberArgs, SubscriberConfig } from "@medusajs/framework"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { NOTIFICATION_MODULE } from "../modules/notification-center"
import NotificationCenterService from "../modules/notification-center/service"
import { getIO } from "../modules/socket/service"
import { sendPushNotification } from "../modules/notification-center/push-service"
import {
  sendEmail,
  getOrderPlacedEmailTemplate,
  getVendorOrderEmailTemplate
} from "../modules/notification-center/email-service"

// ── New Order ──────────────────────────────────────────────────────────────

export default async function orderPlacedHandler({
  event: { data },
  container,
}: SubscriberArgs<{ id: string }>) {
  const query = container.resolve(ContainerRegistrationKeys.QUERY)
  const notifService: NotificationCenterService = container.resolve(NOTIFICATION_MODULE)

  const { data: [order] } = await query.graph({
    entity: "order",
    fields: [
      "id",
      "display_id",
      "customer_id",
      "email",
      "total",
      "subtotal",
      "shipping_total",
      "tax_total",
      "currency_code",
      "items.*",
      "shipping_address.*",
      "vendor.id",
      "vendor.name",
      "vendor.email"
    ],
    filters: { id: data.id }
  })

  if (!order) return

  // Notify customer via app notification
  const customerNotif = await notifService.createNotification({
    recipient_id: order.customer_id,
    recipient_type: "customer",
    type: "new_order",
    title: "Commande confirmée",
    body: `Votre commande #${order.display_id} a été confirmée.`,
    data: { order_id: order.id, display_id: order.display_id },
  })

  // Notify customer via email
  if (order.email) {
    try {
      await sendEmail({
        to: order.email,
        subject: `Confirmation de votre commande #${order.display_id} - East Market`,
        html: getOrderPlacedEmailTemplate(order)
      })
    } catch (err) {
      console.error(`Failed to send order placed email to customer ${order.email}:`, err)
    }
  }

  // Notify vendor if linked
  const vendorId = (order as any).vendor?.id
  const vendorEmail = (order as any).vendor?.email
  if (vendorId) {
    const vendorNotif = await notifService.createNotification({
      recipient_id: vendorId,
      recipient_type: "vendor",
      type: "new_order",
      title: "Nouvelle commande",
      body: `Vous avez reçu une nouvelle commande #${order.display_id}.`,
      data: { order_id: order.id, display_id: order.display_id },
    })

    // Notify vendor via email
    if (vendorEmail) {
      try {
        await sendEmail({
          to: vendorEmail,
          subject: `Nouvelle commande reçue #${order.display_id} - East Market`,
          html: getVendorOrderEmailTemplate(order, order.items || [])
        })
      } catch (err) {
        console.error(`Failed to send order notification email to vendor ${vendorEmail}:`, err)
      }
    }

    const io = getIO()
    if (io) {
      const vendorCount = await notifService.countUnread(vendorId)
      io.to(`user:${vendorId}`).emit("new_notification", {
        notification: vendorNotif,
        count: vendorCount,
      })
    }

    // Push Notification for Vendor
    const tokens = await notifService.getRecipientTokens(vendorId)
    console.log(tokens, vendorId)
    if (tokens.length > 0) {
      await sendPushNotification(tokens.map(t => t.token), "Nouvelle commande", `Commande #${order.display_id} reçue.`, { order_id: order.id })
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

  // Push Notification for Customer
  const customerTokens = await notifService.getRecipientTokens(order.customer_id)
  console.log(customerTokens)

  if (customerTokens.length > 0) {
    await sendPushNotification(customerTokens.map(t => t.token), "Commande confirmée", `Votre commande #${order.display_id} a été confirmée.`, { order_id: order.id })
  }
}

export const config: SubscriberConfig = {
  event: "order.placed",
}

