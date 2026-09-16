import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { REVIEW_MODULE } from "../../../../../modules/review"
import { ReviewModuleService } from "../../../../../modules/review/service"

/**
 * GET /store/products/:id/reviews
 *
 * Les avis sont renvoyés avec l'auteur résolu (`customer.first_name`). Sans
 * cette jointure la fiche produit n'avait aucun nom à afficher et repliait sur
 * un libellé générique — « Acheteur vérifié » — attribué à des avis dont rien,
 * côté données, n'atteste l'achat. Un avis dont le client a été supprimé garde
 * `customer: null` : au client de dire « anonyme », pas d'inventer un auteur.
 *
 * `vendor_reply` / `vendor_replied_at` sont renvoyés tels quels : la réponse du
 * vendeur s'affiche sous l'avis, c'est un signal de sérieux pour l'acheteur.
 */
export async function GET(req: MedusaRequest, res: MedusaResponse) {
  const reviewService: ReviewModuleService = req.scope.resolve(REVIEW_MODULE)
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const product_id = req.params.id

  const reviews = await reviewService.listReviews({
    product_id,
  })

  const customerIds = Array.from(
    new Set(reviews.map((r: any) => r.customer_id).filter(Boolean))
  ) as string[]

  if (customerIds.length > 0) {
    const { data: customers } = await query.graph({
      entity: "customer",
      fields: ["id", "first_name", "last_name"],
      filters: { id: customerIds },
    })

    const byId = new Map(customers.map((c: any) => [c.id, c]))
    for (const review of reviews as any[]) {
      review.customer = byId.get(review.customer_id) ?? null
    }
  }

  res.json({ reviews, count: reviews.length })
}
