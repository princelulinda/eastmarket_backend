import { 
  AuthenticatedMedusaRequest, 
  MedusaResponse
} from "@medusajs/framework/http"
import { DELIVERY_MODULE } from "../../../../modules/delivery"
import DeliveryModuleService from "../../../../modules/delivery/service"

export const DELETE = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const { id } = req.params
  const deliveryModuleService: DeliveryModuleService = req.scope.resolve(DELIVERY_MODULE)

  await deliveryModuleService.deleteDeliveryCompanies([id])

  res.status(200).json({
    id,
    object: "delivery_company",
    deleted: true,
  })
}
