import { SubscriberArgs, SubscriberConfig } from "@medusajs/framework"
import { FOLLOW_MODULE } from "../modules/follow"
import FollowModuleService from "../modules/follow/service"
import { NOTIFICATION_MODULE } from "../modules/notification-center"
import NotificationCenterService from "../modules/notification-center/service"
import { getIO } from "../modules/socket/service"
import { sendPushNotification } from "../modules/notification-center/push-service"

type VideoPublishedData = {
  video_id: string
  vendor_id: string
  title: string
  thumbnail_url?: string
}

export default async function followerNotificationsHandler({
  event: { data },
  container,
}: SubscriberArgs<VideoPublishedData>) {
  if (!data.vendor_id) return

  const followService: FollowModuleService = container.resolve(FOLLOW_MODULE)
  const notifService: NotificationCenterService = container.resolve(NOTIFICATION_MODULE)

  const followerIds = await followService.listFollowerCustomerIds(data.vendor_id)
  if (followerIds.length === 0) return

  const io = getIO()

  await Promise.all(
    followerIds.map(async (customerId) => {
      const notif = await notifService.createNotification({
        recipient_id: customerId,
        recipient_type: "customer",
        type: "new_video",
        title: "New video from a vendor you follow",
        body: data.title,
        data: { video_id: data.video_id, vendor_id: data.vendor_id },
      })

      if (io) {
        const count = await notifService.countUnread(customerId)
        io.to(`user:${customerId}`).emit("new_notification", { notification: notif, count })
      }

      const tokens = await notifService.getRecipientTokens(customerId)
      if (tokens.length > 0) {
        await sendPushNotification(
          tokens.map((t) => t.token),
          "New video",
          data.title,
          { video_id: data.video_id, vendor_id: data.vendor_id }
        )
      }
    })
  )
}

export const config: SubscriberConfig = {
  event: "short_video.published",
}
