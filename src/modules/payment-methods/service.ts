import { MedusaService } from "@medusajs/framework/utils"
import CustomerPaymentMethod from "./models/customer-payment-method"

class PaymentMethodsModuleService extends MedusaService({
  CustomerPaymentMethod,
}) {
}

export default PaymentMethodsModuleService
