import { 
  createStep, 
  StepResponse, 
  createWorkflow, 
  WorkflowResponse 
} from "@medusajs/framework/workflows-sdk"
import { PAYMENT_METHODS_MODULE } from "../../../modules/payment-methods"
import PaymentMethodsModuleService from "../../../modules/payment-methods/service"

export type AddPaymentMethodInput = {
  customer_id: string
  provider_id: string
  data?: any
  label?: string
  is_default?: boolean
}

export const createPaymentMethodStep = createStep(
  "create-payment-method-step",
  async (input: AddPaymentMethodInput, { container }) => {
    const service = container.resolve(PAYMENT_METHODS_MODULE) as PaymentMethodsModuleService
    
    // If it's going to be default, unset previous default
    if (input.is_default) {
      const existing = await service.listCustomerPaymentMethods({
        customer_id: input.customer_id,
        is_default: true
      })
      if (existing.length > 0) {
        await service.updateCustomerPaymentMethods({
          selector: { customer_id: input.customer_id, is_default: true },
          update: { is_default: false }
        })
      }
    }

    const method = await service.createCustomerPaymentMethods(input)
    return new StepResponse(method, method.id)
  },
  async (id, { container }) => {
    const service = container.resolve(PAYMENT_METHODS_MODULE) as PaymentMethodsModuleService
    await service.deleteCustomerPaymentMethods(id)
  }
)

const addPaymentMethodWorkflow = createWorkflow(
  "add-payment-method",
  (input: AddPaymentMethodInput) => {
    const method = createPaymentMethodStep(input)
    return new WorkflowResponse(method)
  }
)

export default addPaymentMethodWorkflow
