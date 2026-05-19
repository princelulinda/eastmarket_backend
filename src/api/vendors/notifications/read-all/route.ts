import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { NOTIFICATION_MODULE } from "../../../../modules/notification-center"
import NotificationCenterService from "../../../../modules/notification-center/service"

export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const notifService: NotificationCenterService = req.scope.resolve(NOTIFICATION_MODULE)
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id"],
    filters: { id: [req.auth_context.actor_id] }
  })

  await notifService.markAllAsRead(vendorAdmin.vendor.id)
  res.json({ success: true, unread_count: 0 })
}
