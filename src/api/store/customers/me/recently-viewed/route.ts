import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { ACTIVITY_MODULE } from "../../../../../modules/activity"
import ActivityModuleService from "../../../../../modules/activity/service"

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const customerId = req.auth_context.actor_id
  const service = req.scope.resolve(ACTIVITY_MODULE) as ActivityModuleService
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const productIds = await service.getRecentlyViewedProductIds(customerId, 12)
  if (productIds.length === 0) {
    return res.json({ products: [] })
  }

  const { data: products } = await query.graph({
    entity: "product",
    fields: ["id", "title", "thumbnail", "status", "variants.*", "variants.prices.*"],
    filters: { id: productIds, status: "published" },
  })

  // Preserve most-recently-viewed-first order (query.graph doesn't guarantee it).
  const productMap = new Map(products.map((p: any) => [p.id, p]))
  const ordered = productIds.map((id) => productMap.get(id)).filter(Boolean)

  res.json({ products: ordered })
}
