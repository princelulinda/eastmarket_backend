import { MedusaService } from "@medusajs/framework/utils"
import DeliveryCompany from "./models/delivery-company"
import DeliveryDriver from "./models/delivery-driver"

class DeliveryModuleService extends MedusaService({
  DeliveryCompany,
  DeliveryDriver,
}) {}

export default DeliveryModuleService
