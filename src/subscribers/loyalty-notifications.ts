import { SubscriberArgs, SubscriberConfig } from "@medusajs/framework"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { NOTIFICATION_MODULE } from "../modules/notification-center"
import NotificationCenterService from "../modules/notification-center/service"
import { getIO } from "../modules/socket/service"
import { sendPushNotification } from "../modules/notification-center/push-service"
import { sendEmail, getRewardEmailTemplate } from "../modules/notification-center/email-service"

type LoyaltyEventData = {
  customer_id: string
  label?: string
  streak?: number
  coupon_id?: string
  coupon_code?: string
}

export default async function loyaltyNotificationsHandler({
  event,
  container,
}: SubscriberArgs<LoyaltyEventData>) {
  const { customer_id, label, streak, coupon_code } = event.data
  const notifService: NotificationCenterService = container.resolve(NOTIFICATION_MODULE)

  const isMilestone = event.name === "loyalty.streak_milestone"

  const title = isMilestone ? "Streak reward unlocked!" : "You won a reward!"
  const body = isMilestone
    ? `${streak}-day streak! You earned ${coupon_code ? `coupon ${coupon_code}` : "a bonus reward"}.`
    : `You won ${label ?? "a prize"} on the daily wheel${coupon_code ? ` — code ${coupon_code}` : ""}.`

  const notif = await notifService.createNotification({
    recipient_id: customer_id,
    recipient_type: "customer",
    type: isMilestone ? "streak_milestone" : "reward_won",
    title,
    body,
    data: event.data,
  })

  const io = getIO()
  if (io) {
    const count = await notifService.countUnread(customer_id)
    io.to(`user:${customer_id}`).emit("new_notification", { notification: notif, count })
  }

  const tokens = await notifService.getRecipientTokens(customer_id)
  if (tokens.length > 0) {
    await sendPushNotification(tokens.map((t) => t.token), title, body, event.data)
  }

  // Notification durable par email — le push peut être manqué/ignoré, l'email
  // reste un point d'entrée fiable pour relancer l'engagement.
  const query = container.resolve(ContainerRegistrationKeys.QUERY)
  const { data: [customer] } = await query.graph({
    entity: "customer",
    fields: ["id", "email", "first_name"],
    filters: { id: customer_id },
  })

  if (customer?.email) {
    const heading = isMilestone ? "Série de connexions récompensée !" : "Vous avez gagné une récompense !"
    const message = isMilestone
      ? `${streak} jours d'affilée ! Voici votre récompense pour votre fidélité.`
      : `Vous avez remporté ${label ?? "un cadeau"} à la roue quotidienne.`

    try {
      await sendEmail({
        to: customer.email,
        subject: `${heading} - East Market`,
        html: getRewardEmailTemplate({
          name: customer.first_name || customer.email,
          heading,
          message,
          couponCode: coupon_code,
        }),
      })
    } catch (err) {
      console.error(`Failed to send loyalty reward email to ${customer.email}:`, err)
    }
  }
}

export const config: SubscriberConfig = {
  event: ["loyalty.reward_won", "loyalty.streak_milestone"],
}
