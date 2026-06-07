import { z } from "@medusajs/framework/zod"
import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"
import { createOrderShipmentWorkflow, getOrderDetailWorkflow } from "@medusajs/medusa/core-flows"

export const PostShipmentOrderSchema = z.object({
  items: z.array(z.object({
    id: z.string(),
    quantity: z.number(),
  })),
  labels: z.array(z.object({
    tracking_number: z.string(),
    tracking_url: z.string().optional(),
    label_url: z.string().optional(),
  })).optional(),
  no_notification: z.boolean().optional(),
  metadata: z.record(z.unknown()).nullish(),
}).strict()

type PostBody = z.infer<typeof PostShipmentOrderSchema>

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

export const POST = async (req: AuthenticatedMedusaRequest<PostBody>, res: MedusaResponse) => {
  const orderId = req.params.id
  const fulfillmentId = req.params.fulfillment_id

  await assertOrderOwnership(req, orderId)

  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { data: [fulfillment] } = await query.graph({
    entity: "fulfillment",
    fields: ["id", "items.*"],
    filters: { id: fulfillmentId }
  })

  if (!fulfillment) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Fulfillment not found")
  }

  // Create a map from fulfillment item ID (e.g. fulit_...) to the order line item ID (line_item_id)
  const itemsMap = new Map<string, string>()
  for (const item of (fulfillment.items || [])) {
    if (item.id && item.line_item_id) {
      itemsMap.set(item.id, item.line_item_id)
    }
  }

  // Map the input item IDs to the expected order line item IDs
  const mappedItems = req.validatedBody.items.map((item) => {
    const orderLineItemId = itemsMap.get(item.id) || item.id
    return {
      id: orderLineItemId,
      quantity: item.quantity,
    }
  })

  await createOrderShipmentWorkflow(req.scope).run({
    input: {
      ...req.validatedBody,
      order_id: orderId,
      fulfillment_id: fulfillmentId,
      items: mappedItems,
      labels: req.validatedBody.labels ?? [],
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
