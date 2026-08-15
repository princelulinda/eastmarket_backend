import { SubscriberArgs, SubscriberConfig } from "@medusajs/framework"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { LOYALTY_MODULE } from "../modules/loyalty"
import LoyaltyModuleService from "../modules/loyalty/service"
import { NOTIFICATION_MODULE } from "../modules/notification-center"
import NotificationCenterService from "../modules/notification-center/service"
import { getIO } from "../modules/socket/service"
import { sendPushNotification } from "../modules/notification-center/push-service"
import { sendEmail, getRewardEmailTemplate } from "../modules/notification-center/email-service"
import issueLoyaltyCouponWorkflow from "../workflows/loyalty/issue-loyalty-coupon"

const REFERRAL_DISCOUNT_PCT = 10
const REFERRAL_COUPON_VALIDITY_DAYS = 14

async function notify(
  container: any,
  customerId: string,
  title: string,
  body: string,
  data: Record<string, any>,
  email: { heading: string; message: string },
) {
  const notifService: NotificationCenterService = container.resolve(NOTIFICATION_MODULE)
  const notif = await notifService.createNotification({
    recipient_id: customerId,
    recipient_type: "customer",
    type: "referral_reward",
    title,
    body,
    data,
  })

  const io = getIO()
  if (io) {
    const count = await notifService.countUnread(customerId)
    io.to(`user:${customerId}`).emit("new_notification", { notification: notif, count })
  }

  const tokens = await notifService.getRecipientTokens(customerId)
  if (tokens.length > 0) {
    await sendPushNotification(tokens.map((t) => t.token), title, body, data)
  }

  // Notification durable par email — le push peut être manqué/ignoré.
  const query = container.resolve(ContainerRegistrationKeys.QUERY)
  const { data: [customer] } = await query.graph({
    entity: "customer",
    fields: ["id", "email", "first_name"],
    filters: { id: customerId },
  })

  if (customer?.email) {
    try {
      await sendEmail({
        to: customer.email,
        subject: `${email.heading} - East Market`,
        html: getRewardEmailTemplate({
          name: customer.first_name || customer.email,
          heading: email.heading,
          message: email.message,
          couponCode: data.coupon_code,
        }),
      })
    } catch (err) {
      console.error(`Failed to send referral reward email to ${customer.email}:`, err)
    }
  }
}

// Rewards both sides of a referral the first time the referred customer
// places an order. Only fires for genuinely new customers — apply-time
// already rejected anyone with prior orders, and this only rewards the
// pending link once (status flips to "rewarded", never re-triggered).
export default async function referralRewardsHandler({
  event: { data },
  container,
}: SubscriberArgs<{ id: string }>) {
  const query = container.resolve(ContainerRegistrationKeys.QUERY)
  const loyaltyService: LoyaltyModuleService = container.resolve(LOYALTY_MODULE)

  const { data: [order] } = await query.graph({
    entity: "order",
    fields: ["id", "customer_id"],
    filters: { id: data.id },
  })
  if (!order?.customer_id) return

  const referral = await loyaltyService.getReferralLink(order.customer_id)
  if (!referral || referral.status !== "pending") return

  const [referrerCoupon, referredCoupon] = await Promise.all([
    issueLoyaltyCouponWorkflow(container).run({
      input: {
        customer_id: referral.referrer_customer_id,
        discount_type: "percentage",
        discount_value: REFERRAL_DISCOUNT_PCT,
        validity_days: REFERRAL_COUPON_VALIDITY_DAYS,
        source: "referral",
        source_ref_id: referral.id,
      },
    }).then((r) => r.result),
    issueLoyaltyCouponWorkflow(container).run({
      input: {
        customer_id: referral.referred_customer_id,
        discount_type: "percentage",
        discount_value: REFERRAL_DISCOUNT_PCT,
        validity_days: REFERRAL_COUPON_VALIDITY_DAYS,
        source: "referral",
        source_ref_id: referral.id,
      },
    }).then((r) => r.result),
  ])

  await loyaltyService.markReferralRewarded(referral.id, referrerCoupon.id, referredCoupon.id)

  await Promise.all([
    notify(
      container,
      referral.referrer_customer_id,
      "Your referral just made a purchase!",
      `You earned a ${REFERRAL_DISCOUNT_PCT}% off coupon — code ${referrerCoupon.code}.`,
      { coupon_code: referrerCoupon.code },
      {
        heading: "Votre filleul vient de commander !",
        message: `Vous avez gagné un coupon de ${REFERRAL_DISCOUNT_PCT}% de réduction grâce à votre parrainage.`,
      },
    ),
    notify(
      container,
      referral.referred_customer_id,
      "Welcome bonus unlocked!",
      `Thanks for your first order — here's a ${REFERRAL_DISCOUNT_PCT}% off coupon, code ${referredCoupon.code}.`,
      { coupon_code: referredCoupon.code },
      {
        heading: "Votre bonus de bienvenue est débloqué !",
        message: `Merci pour votre première commande — voici un coupon de ${REFERRAL_DISCOUNT_PCT}% de réduction pour la prochaine.`,
      },
    ),
  ])
}

export const config: SubscriberConfig = {
  event: "order.placed",
}
