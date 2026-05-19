import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { NOTIFICATION_MODULE } from "../../../modules/notification-center"
import NotificationCenterService from "../../../modules/notification-center/service"

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const notifService: NotificationCenterService = req.scope.resolve(NOTIFICATION_MODULE)
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const onlyUnread = req.query.unread === "true"

  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id"],
    filters: { id: [req.auth_context.actor_id] }
  })

  const vendorId = vendorAdmin.vendor.id
  const notifications = await notifService.listForRecipient(vendorId, onlyUnread)
  const count = await notifService.countUnread(vendorId)

  res.json({ notifications, unread_count: count })
}
