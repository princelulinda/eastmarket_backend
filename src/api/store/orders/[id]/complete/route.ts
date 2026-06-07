import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"
import { completeOrderWorkflow, getOrderDetailWorkflow } from "@medusajs/medusa/core-flows"

async function assertOrderCustomerOwnership(req: AuthenticatedMedusaRequest, orderId: string): Promise<void> {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { data: [order] } = await query.graph({
    entity: "order",
    fields: ["customer_id"],
    filters: { id: orderId }
  })
  if (!order) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Order not found")
  }
  if (order.customer_id !== req.auth_context.actor_id) {
    throw new MedusaError(MedusaError.Types.UNAUTHORIZED, "Unauthorized access to order")
  }
}

export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const orderId = req.params.id

  await assertOrderCustomerOwnership(req, orderId)

  await completeOrderWorkflow(req.scope).run({
    input: {
      orderIds: [orderId],
    }
  })

  const { result: order } = await getOrderDetailWorkflow(req.scope).run({
    input: {
      order_id: orderId,
      fields: [
        "id", "status", "total", "subtotal",
        "items.*", "items.detail",
        "fulfillments.*", "fulfillments.items.*",
        "payment_collections.*"
      ]
    }
  })

  res.json({ order })
}
