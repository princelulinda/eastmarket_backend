import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { NOTIFICATION_MODULE } from "../../../modules/notification-center"
import NotificationCenterService from "../../../modules/notification-center/service"

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const notifService: NotificationCenterService = req.scope.resolve(NOTIFICATION_MODULE)
  const onlyUnread = req.query.unread === "true"

  const notifications = await notifService.listForRecipient(
    req.auth_context.actor_id,
    onlyUnread
  )
  const count = await notifService.countUnread(req.auth_context.actor_id)

  res.json({ notifications, unread_count: count })
}
