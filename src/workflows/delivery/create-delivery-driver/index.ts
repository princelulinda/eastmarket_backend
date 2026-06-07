import { 
  createWorkflow,
  WorkflowResponse
} from "@medusajs/framework/workflows-sdk"
import createDeliveryDriverStep from "./steps/create-delivery-driver-step"

export type CreateDeliveryDriverWorkflowInput = {
  name: string
  phone: string
  vehicle_details?: string
  is_active?: boolean
  delivery_company_id: string
  metadata?: Record<string, any>
}

const createDeliveryDriverWorkflow = createWorkflow(
  "create-delivery-driver",
  function (input: CreateDeliveryDriverWorkflowInput) {
    const driver = createDeliveryDriverStep(input)

    return new WorkflowResponse({
      driver,
    })
  }
)

export default createDeliveryDriverWorkflow
