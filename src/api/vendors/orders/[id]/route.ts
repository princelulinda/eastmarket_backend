import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"
import { getOrderDetailWorkflow } from "@medusajs/medusa/core-flows"

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

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  await assertOrderOwnership(req, req.params.id)

  const { result: order } = await getOrderDetailWorkflow(req.scope).run({
    input: {
      order_id: req.params.id,
      fields: [
        "id",
        "status",
        "metadata",
        "total",
        "subtotal",
        "shipping_total",
        "tax_total",
        "currency_code",
        "email",
        "customer_id",
        "items.*",
        "items.tax_lines",
        "items.adjustments",
        "items.variant.*",
        "items.variant.product.*",
        "items.detail",
        "shipping_address.*",
        "billing_address.*",
        "shipping_methods.*",
        "payment_collections.*",
        "fulfillments.*",
        "fulfillments.items.*",
      ]
    }
  })

  res.json({ order })
}
