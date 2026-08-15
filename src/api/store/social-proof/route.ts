import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import AnalyticsService from "../../../modules/analytics/service"

export const GET = async (req: MedusaRequest, res: MedusaResponse) => {
  const analyticsService = req.scope.resolve("analytics") as AnalyticsService

  const rawIds = req.query["ids[]"] ?? req.query.ids
  const productIds = Array.isArray(rawIds) ? rawIds : rawIds ? [rawIds] : []

  if (productIds.length === 0) {
    return res.json({ counts: {} })
  }

  const events = await analyticsService.listAnalyticsEvents({
    product_id: productIds as string[],
  })

  const counts: Record<string, { views: number; sales: number }> = {}
  for (const id of productIds as string[]) {
    counts[id] = { views: 0, sales: 0 }
  }

  for (const event of events) {
    const bucket = counts[event.product_id]
    if (!bucket) continue
    if (event.event_type === "click") bucket.views += 1
    if (event.event_type === "conversion") bucket.sales += 1
  }

  res.json({ counts })
}
