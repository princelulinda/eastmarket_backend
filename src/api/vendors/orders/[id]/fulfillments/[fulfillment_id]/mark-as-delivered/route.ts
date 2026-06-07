import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"
import { markOrderFulfillmentAsDeliveredWorkflow, getOrderDetailWorkflow } from "@medusajs/medusa/core-flows"

async function assertOrderOwnership(req: AuthenticatedMedusaRequest, orderId: string): Promise<void> {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.orders.id"],
    filters: { id: [req.auth_context.actor_id] }
  })
  const orderIds = (vendorAdmin.vendor.orders || []).map((o: { id: string }) => o.id)
  if (!orderIds.includes(orderId)) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Order not found")
  }
}

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
