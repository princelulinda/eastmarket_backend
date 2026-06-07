import { 
  createStep,
  StepResponse,
} from "@medusajs/framework/workflows-sdk"
import { DELIVERY_MODULE } from "../../../../modules/delivery"
import DeliveryModuleService from "../../../../modules/delivery/service"

type CreateDeliveryCompanyStepInput = {
  name: string
  logo?: string
  phone?: string
  email: string
  website?: string
  is_active?: boolean
  metadata?: Record<string, any>
}

const createDeliveryCompanyStep = createStep(
  "create-delivery-company-step",
  async (companyData: CreateDeliveryCompanyStepInput, { container }) => {
    const deliveryModuleService: DeliveryModuleService = 
      container.resolve(DELIVERY_MODULE)

    const company = await deliveryModuleService.createDeliveryCompanies(companyData)

    return new StepResponse(company, company.id)
  },
  async (companyId, { container }) => {
    if (!companyId) {
      return
    }

    const deliveryModuleService: DeliveryModuleService = 
      container.resolve(DELIVERY_MODULE)

    await deliveryModuleService.deleteDeliveryCompanies(companyId)
  }
)

export default createDeliveryCompanyStep
