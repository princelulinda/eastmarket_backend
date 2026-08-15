import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { NOTIFICATION_MODULE } from "../../../../modules/notification-center"
import NotificationCenterService, {
  NotificationPrefs,
} from "../../../../modules/notification-center/service"

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const notifService: NotificationCenterService = req.scope.resolve(NOTIFICATION_MODULE)
  const preferences = await notifService.getPreferences(req.auth_context.actor_id)
  res.json({ preferences })
}

export const PUT = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const notifService: NotificationCenterService = req.scope.resolve(NOTIFICATION_MODULE)
  const body = req.body as Partial<NotificationPrefs>

  const allowed: Partial<NotificationPrefs> = {}
  if (typeof body.messages === "boolean") allowed.messages = body.messages
  if (typeof body.reminders === "boolean") allowed.reminders = body.reminders
  if (typeof body.broadcasts === "boolean") allowed.broadcasts = body.broadcasts
  if (typeof body.orders === "boolean") allowed.orders = body.orders
  if (body.quiet_hours === null || (body.quiet_hours?.start && body.quiet_hours?.end)) {
    allowed.quiet_hours = body.quiet_hours ?? null
  }

  const preferences = await notifService.setPreferences(
    req.auth_context.actor_id,
    "customer",
    allowed
  )
  res.json({ preferences })
}
