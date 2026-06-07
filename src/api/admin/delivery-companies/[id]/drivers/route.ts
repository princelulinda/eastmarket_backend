import { 
  AuthenticatedMedusaRequest, 
  MedusaResponse
} from "@medusajs/framework/http"
import { z } from "@medusajs/framework/zod"
import createDeliveryDriverWorkflow from "../../../../../workflows/delivery/create-delivery-driver"
import { DELIVERY_MODULE } from "../../../../../modules/delivery"
import DeliveryModuleService from "../../../../../modules/delivery/service"

export const PostAdminCreateDeliveryDriverSchema = z.object({
  name: z.string(),
  phone: z.string(),
  vehicle_details: z.string().optional(),
  is_active: z.boolean().optional(),
  metadata: z.record(z.any()).optional(),
}).strict()

type RequestBody = z.infer<typeof PostAdminCreateDeliveryDriverSchema>

export const POST = async (
  req: AuthenticatedMedusaRequest<RequestBody>,
  res: MedusaResponse
) => {
  const { id } = req.params
  const driverData = req.validatedBody

  const { result } = await createDeliveryDriverWorkflow(req.scope)
    .run({
      input: {
        ...driverData,
        delivery_company_id: id,
      }
    })

  res.status(201).json({
    delivery_driver: result.driver,
  })
}

export const GET = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const { id } = req.params
  const deliveryModuleService: DeliveryModuleService = 
    req.scope.resolve(DELIVERY_MODULE)

  const [drivers, count] = await deliveryModuleService.listAndCountDeliveryDrivers(
    {
      delivery_company: id,
    }
  )

  res.json({
    delivery_drivers: drivers,
    count,
  })
}
