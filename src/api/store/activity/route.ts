import { z } from "@medusajs/framework/zod"
import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ACTIVITY_MODULE } from "../../../modules/activity"
import ActivityModuleService from "../../../modules/activity/service"

export const PostActivitySchema = z.object({
  action_type: z.enum([
    "product_view",
    "add_to_cart",
    "remove_from_cart",
    "wishlist_add",
    "wishlist_remove",
    "search",
    "checkout_step",
    "purchase",
  ]),
  entity_type: z.string().optional(),
  entity_id: z.string().optional(),
  metadata: z.record(z.any()).optional(),
}).strict()

type PostBody = z.infer<typeof PostActivitySchema>

export const POST = async (req: AuthenticatedMedusaRequest<PostBody>, res: MedusaResponse) => {
  const customerId = req.auth_context.actor_id
  const service = req.scope.resolve(ACTIVITY_MODULE) as ActivityModuleService

  await service.track({
    customer_id: customerId,
    ...req.validatedBody,
  } as any)

  // Fire-and-forget from the client's perspective — no payload needed back.
  res.status(204).send()
}
