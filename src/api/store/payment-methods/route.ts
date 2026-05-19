import { 
  AuthenticatedMedusaRequest, 
  MedusaResponse 
} from "@medusajs/framework"
import { z } from "zod"
import addPaymentMethodWorkflow from "../../../workflows/payment-methods/add-payment-method"
import { PAYMENT_METHODS_MODULE } from "../../../modules/payment-methods"
import PaymentMethodsModuleService from "../../../modules/payment-methods/service"

export const PostPaymentMethodSchema = z.object({
  provider_id: z.string(),
  data: z.record(z.any()).optional(),
  label: z.string().optional(),
  is_default: z.boolean().optional(),
})

export const GET = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const customerId = req.auth_context.actor_id
  const service = req.scope.resolve(PAYMENT_METHODS_MODULE) as PaymentMethodsModuleService

  const [paymentMethods, count] = await service.listAndCountCustomerPaymentMethods({
    customer_id: customerId,
  })

  res.json({
    payment_methods: paymentMethods,
    count,
  })
}

export const POST = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const customerId = req.auth_context.actor_id
  const validated = PostPaymentMethodSchema.parse(req.body)

  const { result } = await addPaymentMethodWorkflow(req.scope)
    .run({
      input: {
        customer_id: customerId,
        ...validated
      }
    })

  res.json({
    payment_method: result
  })
}
