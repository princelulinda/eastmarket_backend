import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { NOTIFICATION_MODULE } from "../../../../../modules/notification-center"
import NotificationCenterService from "../../../../../modules/notification-center/service"

export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const notifService: NotificationCenterService = req.scope.resolve(NOTIFICATION_MODULE)
  await notifService.markAsRead(req.params.id)
  const count = await notifService.countUnread(req.auth_context.actor_id)
  res.json({ success: true, unread_count: count })
}
