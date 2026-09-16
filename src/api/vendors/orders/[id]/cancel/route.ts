import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { cancelOrderWorkflow, getOrderDetailWorkflow } from "@medusajs/medusa/core-flows"
import { assertOrderOwnership, ORDER_DETAIL_FIELDS } from "../../order-ownership"

/** POST /vendors/orders/:id/cancel — Annule la commande. */
export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const orderId = req.params.id
  await assertOrderOwnership(req, orderId)

  await cancelOrderWorkflow(req.scope).run({
    input: {
      order_id: orderId,
      canceled_by: req.auth_context.actor_id,
    },
  })

  const { result: order } = await getOrderDetailWorkflow(req.scope).run({
    input: { order_id: orderId, fields: ORDER_DETAIL_FIELDS },
  })

  res.json({ order })
}
