import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { REVIEW_MODULE } from "../../../modules/review"
import { ReviewModuleService } from "../../../modules/review/service"
import { getVendorProductIds } from "../vendor-context"
import { parseListParams, paginationMeta } from "../list-params"

const SORTABLE = ["created_at", "rating"]

/**
 * Avis déposés sur les produits de la boutique connectée.
 *
 * Le vendeur ne pouvait jusqu'ici ni les lire depuis son espace, ni y répondre.
 * `?replied=false` donne directement la file de travail — les avis en attente
 * de réponse —, `?rating=1,2` isole les mécontents à traiter en priorité.
 */
export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const reviewService: ReviewModuleService = req.scope.resolve(REVIEW_MODULE)
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const params = parseListParams(req, { sortable: SORTABLE, defaultOrder: "-created_at" })
  const { replied, rating } = req.query as Record<string, string | undefined>

  const productIds = await getVendorProductIds(req)
  if (productIds.length === 0) {
    return res.json({ reviews: [], ...paginationMeta(params, 0) })
  }

  const filters: Record<string, any> = { product_id: productIds }

  if (replied === "true") {
    filters.vendor_reply = { $ne: null }
  } else if (replied === "false") {
    filters.vendor_reply = null
  }

  if (rating) {
    const ratings = rating.split(",").map((r) => Number.parseInt(r, 10)).filter(Number.isFinite)
    if (ratings.length) filters.rating = ratings
  }

  const [reviews, count] = await reviewService.listAndCountReviews(filters, {
    skip: params.offset,
    take: params.limit,
    order: params.order,
  })

  // Le vendeur a besoin de savoir de quel produit et de quel client il s'agit :
  // un avis sans contexte ne se traite pas.
  const rows = reviews as any[]
  const customerIds = [...new Set(rows.map((r) => r.customer_id).filter(Boolean))] as string[]
  const reviewedProductIds = [...new Set(rows.map((r) => r.product_id).filter(Boolean))] as string[]

  const [{ data: customers }, { data: products }] = await Promise.all([
    customerIds.length
      ? query.graph({ entity: "customer", fields: ["id", "first_name", "last_name"], filters: { id: customerIds } })
      : Promise.resolve({ data: [] as any[] }),
    reviewedProductIds.length
      ? query.graph({ entity: "product", fields: ["id", "title", "handle", "thumbnail"], filters: { id: reviewedProductIds } })
      : Promise.resolve({ data: [] as any[] }),
  ])

  const customerById = new Map<string, any>(customers.map((c: any) => [c.id, c] as [string, any]))
  const productById = new Map<string, any>(products.map((p: any) => [p.id, p] as [string, any]))

  for (const review of rows) {
    review.customer = customerById.get(review.customer_id) ?? null
    review.product = productById.get(review.product_id) ?? null
  }

  res.json({ reviews: rows, ...paginationMeta(params, count) })
}
