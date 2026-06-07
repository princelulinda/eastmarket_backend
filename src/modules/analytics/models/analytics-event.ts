import { model } from "@medusajs/framework/utils"

const AnalyticsEvent = model.define("analytics_event", {
  id: model.id().primaryKey(),
  product_id: model.text(),
  vendor_id: model.text(),
  source: model.text(), // facebook, tiktok, etc.
  campaign: model.text().nullable(),
  event_type: model.enum(["click", "conversion"]),
  order_id: model.text().nullable(),
})

export default AnalyticsEvent
