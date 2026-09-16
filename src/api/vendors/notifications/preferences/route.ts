import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { NOTIFICATION_MODULE } from "../../../../modules/notification-center"
import NotificationCenterService, {
  NotificationPrefs,
} from "../../../../modules/notification-center/service"
import { resolveVendorId } from "../../vendor-id"

/** GET /vendors/notifications/preferences */
export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const notifService: NotificationCenterService = req.scope.resolve(NOTIFICATION_MODULE)
  // La boutique, pas l'administrateur : c'est sous cet identifiant que les
  // notifications et les jetons push sont enregistrés.
  const vendorId = await resolveVendorId(req)
  const preferences = await notifService.getPreferences(vendorId)
  res.json({ preferences })
}

/**
 * PUT /vendors/notifications/preferences
 *
 * Seuls les champs reconnus sont retenus : le service fusionne avec l'existant,
 * un corps partiel ne doit donc pas pouvoir y injecter de clés arbitraires.
 */
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
    await resolveVendorId(req),
    "vendor",
    allowed
  )
  res.json({ preferences })
}
