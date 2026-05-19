import { z } from "@medusajs/framework/zod"
import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"
import { createOrderFulfillmentWorkflow, getOrderDetailWorkflow } from "@medusajs/medusa/core-flows"

export const PostFulfillOrderSchema = z.object({
  location_id: z.string(),
  items: z.array(z.object({
    id: z.string(),
    quantity: z.number().int().positive(),
  })),
}).strict()

type PostBody = z.infer<typeof PostFulfillOrderSchema>

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
  await assertOrderOwnership(req, orderId)

  await createOrderFulfillmentWorkflow(req.scope).run({
    input: {
      order_id: orderId,
      location_id: req.validatedBody.location_id,
      items: req.validatedBody.items,
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
