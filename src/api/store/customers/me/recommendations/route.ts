import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { FOLLOW_MODULE } from "../../../../../modules/follow"
import FollowModuleService from "../../../../../modules/follow/service"

const RECOMMENDATION_LIMIT = 12
const CANDIDATE_POOL_SIZE = 80

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const customerId = req.auth_context.actor_id
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const followService = req.scope.resolve(FOLLOW_MODULE) as FollowModuleService

  const [followedVendorIds, { data: orders }] = await Promise.all([
    followService.listFollowedVendorIds(customerId),
    query.graph({
      entity: "order",
      fields: ["items.*"],
      filters: { customer_id: customerId },
    }),
  ])

  const purchasedProductIds = new Set<string>()
  for (const order of orders) {
    for (const item of (order as any).items || []) {
      if (item.product_id) purchasedProductIds.add(item.product_id)
    }
  }

  const purchasedCategoryIds = new Set<string>()
  if (purchasedProductIds.size > 0) {
    const { data: purchasedProducts } = await query.graph({
      entity: "product",
      fields: ["id", "categories.id"],
      filters: { id: Array.from(purchasedProductIds) },
    })
    for (const p of purchasedProducts) {
      for (const c of (p as any).categories || []) {
        purchasedCategoryIds.add(c.id)
      }
    }
  }

  const hasSignals = purchasedCategoryIds.size > 0 || followedVendorIds.length > 0

  const { data: candidates } = await query.graph({
    entity: "product",
    fields: ["id", "title", "thumbnail", "status", "categories.id", "vendor.id", "variants.*", "variants.prices.*"],
    filters: { status: "published" },
    pagination: { take: CANDIDATE_POOL_SIZE, order: { created_at: "DESC" } } as any,
  })

  const scored = candidates
    .filter((p: any) => !purchasedProductIds.has(p.id))
    .map((p: any, idx: number) => {
      let score = CANDIDATE_POOL_SIZE - idx // recency baseline
      const categoryMatch = (p.categories || []).some((c: any) => purchasedCategoryIds.has(c.id))
      if (categoryMatch) score += CANDIDATE_POOL_SIZE
      if (p.vendor?.id && followedVendorIds.includes(p.vendor.id)) score += CANDIDATE_POOL_SIZE * 2
      return { product: p, score }
    })

  scored.sort((a, b) => b.score - a.score)

  res.json({
    products: scored.slice(0, RECOMMENDATION_LIMIT).map((s) => s.product),
    personalized: hasSignals,
  })
}
