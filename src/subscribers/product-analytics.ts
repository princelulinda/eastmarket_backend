import { SubscriberArgs, SubscriberConfig } from "@medusajs/framework"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import AnalyticsService from "../modules/analytics/service"

// Completes the existing click-tracking analytics (see middlewares/analytics.ts)
// by recording a "conversion" event per purchased unit — this is what powers
// real "sold N times" social-proof counters, and also feeds the vendor
// analytics dashboard (vendors/analytics), which already aggregates
// conversion events but had nothing creating them until now.
export default async function productAnalyticsHandler({
  event: { data },
  container,
}: SubscriberArgs<{ id: string }>) {
  const query = container.resolve(ContainerRegistrationKeys.QUERY)
  const analyticsService = container.resolve("analytics") as AnalyticsService

  const { data: [order] } = await query.graph({
    entity: "order",
    fields: ["id", "items.*", "vendor.id"],
    filters: { id: data.id },
  })

  if (!order) return

  const vendorId = (order as any).vendor?.id
  if (!vendorId) return

  const items = (order.items ?? []).filter((item: any) => item.product_id)

  await Promise.all(
    items.map((item: any) => {
      const qty = Math.round(Number(item.quantity)) || 1
      return Promise.all(
        Array.from({ length: qty }).map(() =>
          analyticsService.createAnalyticsEvents({
            product_id: item.product_id,
            vendor_id: vendorId,
            source: "order",
            campaign: null,
            event_type: "conversion",
            order_id: order.id,
          })
        )
      )
    })
  )
}

export const config: SubscriberConfig = {
  event: "order.placed",
}
