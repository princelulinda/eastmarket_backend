import { z } from "@medusajs/framework/zod"
import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"
import { REVIEW_MODULE } from "../../../../../modules/review"
import { ReviewModuleService } from "../../../../../modules/review/service"
import { getVendorProductIds, requireVendorContext } from "../../../vendor-context"
import { notifyRecipient } from "../../../../../modules/notification-center/notify"

export const PostVendorReviewReplySchema = z.object({
  reply: z.string().trim().min(2).max(2000),
}).strict()

type PostBody = z.infer<typeof PostVendorReviewReplySchema>

/**
 * Charge l'avis en refusant l'accès s'il ne porte pas sur un produit du vendeur.
 * Renvoie « Review not found » plutôt qu'une erreur d'autorisation, pour ne pas
 * révéler l'existence des avis des autres boutiques.
 */
async function loadOwnedReview(req: AuthenticatedMedusaRequest) {
  const reviewService: ReviewModuleService = req.scope.resolve(REVIEW_MODULE)

  const [review] = await reviewService.listReviews({ id: req.params.id })
  if (!review) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Review not found")
  }

  const productIds = await getVendorProductIds(req)
  if (!productIds.includes((review as any).product_id)) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Review not found")
  }

  return review as any
}

/** Publie ou met à jour la réponse du vendeur à un avis. */
export const POST = async (req: AuthenticatedMedusaRequest<PostBody>, res: MedusaResponse) => {
  const reviewService: ReviewModuleService = req.scope.resolve(REVIEW_MODULE)
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const review = await loadOwnedReview(req)
  const vendor = await requireVendorContext(req)

  const isFirstReply = !review.vendor_reply

  const updated: any = await reviewService.updateReviews({
    id: review.id,
    vendor_reply: req.validatedBody.reply,
    vendor_replied_at: new Date(),
  } as any)

  // Le client n'est prévenu qu'à la première réponse : une correction de faute
  // de frappe ne doit pas lui renvoyer une notification.
  if (isFirstReply && review.customer_id) {
    const { data: [product] } = await query.graph({
      entity: "product",
      fields: ["id", "title"],
      filters: { id: review.product_id },
    })

    try {
      await notifyRecipient(req.scope as any, {
        recipientId: review.customer_id,
        recipientType: "customer",
        type: "review_reply",
        title: `${vendor.name} a répondu à votre avis`,
        body: req.validatedBody.reply.slice(0, 140),
        data: { review_id: review.id, product_id: review.product_id, product_title: product?.title },
        pushCategory: "messages",
      })
    } catch (err) {
      // La réponse est publiée : un échec de notification ne doit pas la annuler.
      console.error(`Failed to notify customer ${review.customer_id} of review reply:`, err)
    }
  }

  res.json({ review: Array.isArray(updated) ? updated[0] : updated })
}

/** Retire la réponse publique. L'avis du client, lui, n'est jamais touché. */
export const DELETE = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const reviewService: ReviewModuleService = req.scope.resolve(REVIEW_MODULE)
  const review = await loadOwnedReview(req)

  const updated: any = await reviewService.updateReviews({
    id: review.id,
    vendor_reply: null,
    vendor_replied_at: null,
  } as any)

  res.json({ review: Array.isArray(updated) ? updated[0] : updated })
}
