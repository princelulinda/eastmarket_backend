import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { REVIEW_MODULE } from "../../../../modules/review"
import { ReviewModuleService } from "../../../../modules/review/service"

/**
 * GET /store/reviews/ratings?ids[]=prod_1&ids[]=prod_2
 *
 * Agrégat de notes pour un lot de produits. Les grilles produit (recherche,
 * profil vendeur, recommandations) affichent une note par carte : sans cette
 * route il faudrait un appel `/store/products/:id/reviews` par produit.
 *
 * Un produit sans avis est renvoyé avec `count: 0` et `average: null`, pour que
 * le client distingue « pas encore noté » de « noté 0 » — et n'invente pas
 * d'étoiles.
 */
type RatingSummary = { average: number | null; count: number }

export async function GET(req: MedusaRequest, res: MedusaResponse) {
  const reviewService: ReviewModuleService = req.scope.resolve(REVIEW_MODULE)

  const rawIds = req.query["ids[]"] ?? req.query.ids
  const productIds = (
    Array.isArray(rawIds) ? rawIds : rawIds ? [rawIds] : []
  ) as string[]

  if (productIds.length === 0) {
    return res.json({ ratings: {} })
  }

  const reviews = await reviewService.listReviews({
    product_id: productIds,
  })

  const totals: Record<string, { sum: number; count: number }> = {}
  for (const id of productIds) {
    totals[id] = { sum: 0, count: 0 }
  }

  for (const review of reviews as { product_id: string; rating: number }[]) {
    const bucket = totals[review.product_id]
    if (!bucket) continue
    // Une note hors 1–5 (donnée héritée, saisie erronée) fausserait la moyenne.
    if (typeof review.rating !== "number" || review.rating < 1 || review.rating > 5) {
      continue
    }
    bucket.sum += review.rating
    bucket.count += 1
  }

  const ratings: Record<string, RatingSummary> = {}
  for (const id of productIds) {
    const { sum, count } = totals[id]
    ratings[id] = {
      average: count > 0 ? Math.round((sum / count) * 10) / 10 : null,
      count,
    }
  }

  res.json({ ratings })
}
