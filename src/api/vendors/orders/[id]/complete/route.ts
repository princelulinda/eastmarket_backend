import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { completeOrderWorkflow, getOrderDetailWorkflow } from "@medusajs/medusa/core-flows"
import { assertOrderOwnership, ORDER_DETAIL_FIELDS } from "../../order-ownership"

/** POST /vendors/orders/:id/complete — Marque la commande comme terminée. */
export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const orderId = req.params.id
  await assertOrderOwnership(req, orderId)

  await completeOrderWorkflow(req.scope).run({
    input: { orderIds: [orderId] },
  })

  const { result: order } = await getOrderDetailWorkflow(req.scope).run({
    input: { order_id: orderId, fields: ORDER_DETAIL_FIELDS },
  })

  res.json({ order })
}
