import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { cancelOrderFulfillmentWorkflow, getOrderDetailWorkflow } from "@medusajs/medusa/core-flows"
import { assertOrderOwnership, ORDER_DETAIL_FIELDS } from "../../../../order-ownership"

/** POST /vendors/orders/:id/fulfillments/:fulfillment_id/cancel */
export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const orderId = req.params.id
  const fulfillmentId = req.params.fulfillment_id

  await assertOrderOwnership(req, orderId)

  await cancelOrderFulfillmentWorkflow(req.scope).run({
    input: { order_id: orderId, fulfillment_id: fulfillmentId },
  })

  const { result: order } = await getOrderDetailWorkflow(req.scope).run({
    input: { order_id: orderId, fields: ORDER_DETAIL_FIELDS },
  })

  res.json({ order })
}
