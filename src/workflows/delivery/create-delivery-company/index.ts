import { 
  createWorkflow,
  WorkflowResponse
} from "@medusajs/framework/workflows-sdk"
import createDeliveryCompanyStep from "./steps/create-delivery-company-step"

export type CreateDeliveryCompanyWorkflowInput = {
  name: string
  logo?: string
  phone?: string
  email: string
  website?: string
  is_active?: boolean
  metadata?: Record<string, any>
}

const createDeliveryCompanyWorkflow = createWorkflow(
  "create-delivery-company",
  function (input: CreateDeliveryCompanyWorkflowInput) {
    const company = createDeliveryCompanyStep(input)

    return new WorkflowResponse({
      company,
    })
  }
)

export default createDeliveryCompanyWorkflow
