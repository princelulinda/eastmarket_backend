import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { markOrderFulfillmentAsDeliveredWorkflow, getOrderDetailWorkflow } from "@medusajs/medusa/core-flows"
import { assertOrderOwnership, ORDER_DETAIL_FIELDS } from "../../../../order-ownership"


export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const orderId = req.params.id
  const fulfillmentId = req.params.fulfillment_id

  await assertOrderOwnership(req, orderId)

  await markOrderFulfillmentAsDeliveredWorkflow(req.scope).run({
    input: {
      orderId,
      fulfillmentId,
    }
  })

  const { result: order } = await getOrderDetailWorkflow(req.scope).run({
    input: {
      order_id: orderId,
      fields: ORDER_DETAIL_FIELDS
    }
  })

  res.json({ order })
}
