import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { NOTIFICATION_MODULE } from "../../../../modules/notification-center"
import NotificationCenterService from "../../../../modules/notification-center/service"

export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const notifService: NotificationCenterService = req.scope.resolve(NOTIFICATION_MODULE)
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  
  const { token, device_type } = req.body as { token: string; device_type?: string }
  const actorId = req.auth_context.actor_id

  if (!token) {
    return res.status(400).json({ message: "Token is required" })
  }

  const { data: [customer] } = await query.graph({
    entity: "customer",
    fields: ["id"],
    filters: { id: [actorId] }
  })

  if (!customer) {
    return res.status(404).json({ message: "Customer not found" })
  }

  const customerId = customer.id

  await notifService.registerPushToken({
    recipient_id: customerId,
    recipient_type: "customer",
    token,
    device_type
  })

  res.json({ message: "Token registered successfully" })
}


