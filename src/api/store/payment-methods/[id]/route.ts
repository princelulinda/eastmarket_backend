import { 
  AuthenticatedMedusaRequest, 
  MedusaResponse 
} from "@medusajs/framework"
import { PAYMENT_METHODS_MODULE } from "../../../../modules/payment-methods"
import PaymentMethodsModuleService from "../../../../modules/payment-methods/service"

export const DELETE = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const customerId = req.auth_context.actor_id
  const { id } = req.params
  const service = req.scope.resolve(PAYMENT_METHODS_MODULE) as PaymentMethodsModuleService

  const method = await service.retrieveCustomerPaymentMethod(id)
  if (method.customer_id !== customerId) {
    return res.status(403).json({ message: "Forbidden" })
  }

  await service.deleteCustomerPaymentMethods(id)

  res.json({
    id,
    object: "customer_payment_method",
    deleted: true,
  })
}

export const POST = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const customerId = req.auth_context.actor_id
  const { id } = req.params
  const service = req.scope.resolve(PAYMENT_METHODS_MODULE) as PaymentMethodsModuleService

  const method = await service.retrieveCustomerPaymentMethod(id)
  if (method.customer_id !== customerId) {
    return res.status(403).json({ message: "Forbidden" })
  }

  // Unset previous default
  const existing = await service.listCustomerPaymentMethods({
    customer_id: customerId,
    is_default: true
  })
  if (existing.length > 0) {
    await service.updateCustomerPaymentMethods({
      selector: { customer_id: customerId, is_default: true },
      update: { is_default: false }
    })
  }

  // Set this one as default
  const updated = await service.updateCustomerPaymentMethods({
    selector: { id },
    update: { is_default: true }
  })

  res.json({
    payment_method: updated[0]
  })
}
