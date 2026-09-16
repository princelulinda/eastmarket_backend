import { z } from "@medusajs/framework/zod"
import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"
import {
  deletePromotionsWorkflow,
  updateCampaignsWorkflow,
  updatePromotionsWorkflow,
} from "@medusajs/core-flows"

export const PostVendorPromotionUpdateSchema = z.object({
  code: z.string().optional(),
  status: z.enum(["draft", "active", "inactive"]).optional(),
  is_automatic: z.boolean().optional(),
  /** Nombre maximum d'utilisations ; null pour retirer la limite. */
  limit: z.number().int().positive().nullable().optional(),
  application_method: z.object({
    type: z.enum(["percentage", "fixed"]).optional(),
    value: z.number().positive().optional(),
    allocation: z.enum(["each", "across"]).optional(),
  }).strict().optional(),
  /** Fenêtre de validité ; null sur les deux bornes la retire. */
  starts_at: z.coerce.date().nullable().optional(),
  ends_at: z.coerce.date().nullable().optional(),
}).strict().refine(
  (d) => d.starts_at === undefined || d.ends_at === undefined ||
    d.starts_at === null || d.ends_at === null || d.ends_at > d.starts_at,
  { message: "ends_at doit suivre starts_at" },
)

type PostBody = z.infer<typeof PostVendorPromotionUpdateSchema>

/** Refuse l'accès à une promotion qui n'appartient pas au vendeur connecté. */
async function assertPromotionOwnership(req: AuthenticatedMedusaRequest, promotionId: string) {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.promotions.id"],
    filters: { id: [req.auth_context.actor_id] },
  })

  const promoIds = (vendorAdmin?.vendor?.promotions || []).map((p: any) => p.id)
  if (!promoIds.includes(promotionId)) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Promotion not found")
  }
}

/** Renvoie la promotion à jour, méthode d'application incluse. */
async function retrievePromotion(req: AuthenticatedMedusaRequest, promotionId: string) {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { data: [promotion] } = await query.graph({
    entity: "promotion",
    fields: ["*", "application_method.*", "campaign.*"],
    filters: { id: promotionId },
  })
  return promotion
}

/**
 * POST /vendors/promotions/:id — Met à jour une promotion.
 *
 * Les règles de ciblage posées à la création (restriction aux produits du
 * vendeur) ne sont pas modifiables ici : elles garantissent qu'une promotion
 * ne peut pas déborder sur le catalogue d'un autre vendeur.
 */
export const POST = async (req: AuthenticatedMedusaRequest<PostBody>, res: MedusaResponse) => {
  const { id: promotion_id } = req.params
  await assertPromotionOwnership(req, promotion_id)

  const { starts_at, ends_at, ...promotionFields } = req.validatedBody

  if (Object.keys(promotionFields).length > 0) {
    await updatePromotionsWorkflow(req.scope).run({
      input: {
        promotionsData: [{ id: promotion_id, ...promotionFields } as any],
      },
    })
  }

  // Les dates vivent sur la campagne liée, pas sur la promotion elle-même.
  if (starts_at !== undefined || ends_at !== undefined) {
    const current = await retrievePromotion(req, promotion_id)
    const campaignId = (current as any)?.campaign_id

    if (!campaignId) {
      throw new MedusaError(
        MedusaError.Types.INVALID_DATA,
        "Cette promotion n'a pas de campagne associée : sa période ne peut pas être modifiée.",
      )
    }

    await updateCampaignsWorkflow(req.scope).run({
      input: {
        campaignsData: [{
          id: campaignId,
          ...(starts_at !== undefined ? { starts_at } : {}),
          ...(ends_at !== undefined ? { ends_at } : {}),
        } as any],
      },
    })
  }

  res.json({ promotion: await retrievePromotion(req, promotion_id) })
}

export const DELETE = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const { id: promotion_id } = req.params
  await assertPromotionOwnership(req, promotion_id)

  await deletePromotionsWorkflow(req.scope).run({
    input: { ids: [promotion_id] },
  })

  res.json({ id: promotion_id, object: "promotion", deleted: true })
}
