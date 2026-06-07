import { z } from "@medusajs/framework/zod"
import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, Modules } from "@medusajs/framework/utils"
import { 
  createPromotionsWorkflow,
  createRemoteLinkStep
} from "@medusajs/core-flows"
import { 
  createWorkflow, 
  transform, 
  WorkflowResponse
} from "@medusajs/framework/workflows-sdk"
import { MARKETPLACE_MODULE } from "../../../modules/marketplace"
import { PromotionType } from "@medusajs/framework/utils"

export const PostVendorPromotionSchema = z.object({
  code: z.string(),
  type: z.nativeEnum(PromotionType),
  is_automatic: z.boolean().optional().default(false),
  application_method: z.object({
    type: z.enum(["percentage", "fixed", "buyget"]),
    value: z.number(),
    allocation: z.enum(["each", "across"]).optional().default("each"),
    target_type: z.enum(["order", "items"]).optional().default("items"),
  }),
}).strict()

type PostBody = z.infer<typeof PostVendorPromotionSchema>

const createVendorPromotionWorkflow = createWorkflow(
  "create-vendor-promotion",
  (input: { vendor_id: string; promotion: PostBody }) => {
    const promotions = createPromotionsWorkflow.runAsStep({
      input: {
        promotionsData: [{
          code: input.promotion.code,
          type: input.promotion.type,
          is_automatic: input.promotion.is_automatic,
          application_method: {
            ...input.promotion.application_method,
            target_rules: [
              {
                attribute: "items.vendor_id", 
                operator: "eq",
                values: [input.vendor_id]
              }
            ]
          }
        }]
      }
    })

    const linkDef = transform({ input, promotions }, (data) => {
      return [{
        [MARKETPLACE_MODULE]: {
          vendor_id: data.input.vendor_id
        },
        [Modules.PROMOTION]: {
          promotion_id: data.promotions[0].id
        }
      }]
    })

    createRemoteLinkStep(linkDef)

    return new WorkflowResponse(promotions[0])
  }
)

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id"],
    filters: { id: [req.auth_context.actor_id] }
  })

  const { data: promotions } = await query.graph({
    entity: "vendor",
    fields: ["promotions.*", "promotions.application_method.*"],
    filters: { id: vendorAdmin.vendor.id }
  })

  res.json({ promotions: promotions[0]?.promotions || [] })
}

export const POST = async (req: AuthenticatedMedusaRequest<PostBody>, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  
  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id"],
    filters: { id: [req.auth_context.actor_id] }
  })

  const { result: promotion } = await createVendorPromotionWorkflow(req.scope).run({
    input: {
      vendor_id: vendorAdmin.vendor.id,
      promotion: req.validatedBody
    }
  })

  res.json({ promotion })
}
