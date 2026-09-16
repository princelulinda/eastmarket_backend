import { z } from "@medusajs/framework/zod"
import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, Modules } from "@medusajs/framework/utils"
import { 
  createCampaignsWorkflow,
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
  /**
   * Fenêtre de validité. Les deux bornes vont ensemble : fournies, elles
   * créent une campagne Medusa qui fait respecter les dates nativement ;
   * omises, la promotion reste valable sans limite dans le temps.
   */
  starts_at: z.coerce.date().optional(),
  ends_at: z.coerce.date().optional(),
}).strict().refine(
  (d) => (!d.starts_at && !d.ends_at) || (!!d.starts_at && !!d.ends_at),
  { message: "starts_at et ends_at doivent être fournis ensemble" },
).refine(
  (d) => !d.starts_at || !d.ends_at || d.ends_at > d.starts_at,
  { message: "ends_at doit suivre starts_at" },
)

type PostBody = z.infer<typeof PostVendorPromotionSchema>

function generateCampaignIdentifier(): string {
  return `PROMO-${Math.random().toString(36).slice(2, 8).toUpperCase()}`
}

const createVendorPromotionWorkflow = createWorkflow(
  "create-vendor-promotion",
  (input: { vendor_id: string; promotion: PostBody }) => {
    // Sans dates, on crée quand même une campagne mais aux bornes nulles :
    // le workflow n'accepte pas de tableau vide conditionnel, et une campagne
    // sans fenêtre n'impose aucune contrainte.
    const campaignPayload = transform({ input }, (data) => ({
      name: data.input.promotion.code,
      campaign_identifier: generateCampaignIdentifier(),
      starts_at: data.input.promotion.starts_at ?? null,
      ends_at: data.input.promotion.ends_at ?? null,
    }))

    const campaigns = createCampaignsWorkflow.runAsStep({
      input: { campaignsData: [campaignPayload] as any },
    })

    const promotionPayload = transform({ input, campaigns }, (data) => ({
      code: data.input.promotion.code,
      type: data.input.promotion.type,
      is_automatic: data.input.promotion.is_automatic,
      status: "active",
      campaign_id: data.campaigns[0].id,
      application_method: {
        ...data.input.promotion.application_method,
        target_rules: [
          {
            attribute: "items.vendor_id",
            operator: "eq",
            values: [data.input.vendor_id],
          },
        ],
      },
    }))

    const promotions = createPromotionsWorkflow.runAsStep({
      input: { promotionsData: [promotionPayload] as any }
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
