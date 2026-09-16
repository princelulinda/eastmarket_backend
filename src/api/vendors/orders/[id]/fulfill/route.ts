import { z } from "@medusajs/framework/zod"
import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { createOrderFulfillmentWorkflow, getOrderDetailWorkflow } from "@medusajs/medusa/core-flows"
import { assertOrderOwnership, ORDER_DETAIL_FIELDS } from "../../order-ownership"

export const PostFulfillOrderSchema = z.object({
  location_id: z.string(),
  items: z.array(z.object({
    id: z.string(),
    quantity: z.number().int().positive(),
  })),
}).strict()

type PostBody = z.infer<typeof PostFulfillOrderSchema>


export const POST = async (req: AuthenticatedMedusaRequest<PostBody>, res: MedusaResponse) => {
  const orderId = req.params.id
  await assertOrderOwnership(req, orderId)

  await createOrderFulfillmentWorkflow(req.scope).run({
    input: {
      order_id: orderId,
      location_id: req.validatedBody.location_id,
      items: req.validatedBody.items as any,
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
