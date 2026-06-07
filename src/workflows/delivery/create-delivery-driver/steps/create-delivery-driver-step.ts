import { 
  createStep,
  StepResponse,
} from "@medusajs/framework/workflows-sdk"
import { DELIVERY_MODULE } from "../../../../modules/delivery"
import DeliveryModuleService from "../../../../modules/delivery/service"

type CreateDeliveryDriverStepInput = {
  name: string
  phone: string
  vehicle_details?: string
  is_active?: boolean
  delivery_company_id: string // Foreign key/relation in Medusa v2 model definition
  metadata?: Record<string, any>
}

const createDeliveryDriverStep = createStep(
  "create-delivery-driver-step",
  async (driverData: CreateDeliveryDriverStepInput, { container }) => {
    const deliveryModuleService: DeliveryModuleService = 
      container.resolve(DELIVERY_MODULE)

    // In Medusa v2 model.define, relationships can be populated using company: id, or delivery_company: id
    // We map delivery_company_id to the delivery_company field
    const { delivery_company_id, ...rest } = driverData
    const driver = await deliveryModuleService.createDeliveryDrivers({
      ...rest,
      delivery_company: delivery_company_id
    })

    return new StepResponse(driver, driver.id)
  },
  async (driverId, { container }) => {
    if (!driverId) {
      return
    }

    const deliveryModuleService: DeliveryModuleService = 
      container.resolve(DELIVERY_MODULE)

    await deliveryModuleService.deleteDeliveryDrivers(driverId)
  }
)

export default createDeliveryDriverStep
