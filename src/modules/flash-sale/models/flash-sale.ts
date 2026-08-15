import { model } from "@medusajs/framework/utils"

const FlashSale = model.define("flash_sale", {
  id: model.id().primaryKey(),
  vendor_id: model.text().nullable(), // also used as the target when product_ids is empty (whole-catalog sale)
  title: model.text(),
  banner_color: model.text().nullable(),
  product_ids: model.json().nullable(), // string[] of targeted product ids; null/empty = whole vendor_id catalog
  promotion_id: model.text(), // linked core Medusa Promotion (is_automatic: true)
  campaign_id: model.text(), // linked core Medusa Campaign (enforces the date window natively)
  discount_type: model.enum(["percentage", "fixed"]),
  discount_value: model.number(),
  starts_at: model.dateTime(),
  ends_at: model.dateTime(),
  is_active: model.boolean().default(true), // manual kill switch, independent of the date window
})

export default FlashSale
