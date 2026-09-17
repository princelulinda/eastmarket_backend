import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { completeOrderWorkflow, getOrderDetailWorkflow } from "@medusajs/medusa/core-flows"
import {
  assertOrderCustomerOwnership,
  STORE_ORDER_DETAIL_FIELDS,
} from "../../order-ownership"

/** POST /store/orders/:id/complete — le client confirme avoir reçu sa commande. */
export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const orderId = req.params.id

  await assertOrderCustomerOwnership(req, orderId)

  await completeOrderWorkflow(req.scope).run({
    input: {
      orderIds: [orderId],
    },
  })

  const { result: order } = await getOrderDetailWorkflow(req.scope).run({
    input: { order_id: orderId, fields: STORE_ORDER_DETAIL_FIELDS },
  })

  res.json({ order })
}
