import { model } from "@medusajs/framework/utils"

const LoyaltyCoupon = model.define("loyalty_coupon", {
  id: model.id().primaryKey(),
  customer_id: model.text().index(),
  promotion_id: model.text(), // id of the linked core Medusa Promotion (usage_limit: 1)
  code: model.text().unique(),
  source: model.enum(["wheel", "checkin_milestone", "referral", "manual"]),
  discount_type: model.enum(["percentage", "fixed", "free_shipping"]),
  discount_value: model.number().nullable(),
  status: model.enum(["issued", "redeemed", "expired"]).default("issued"),
  expires_at: model.dateTime().nullable(),
  redeemed_at: model.dateTime().nullable(),
  redeemed_order_id: model.text().nullable(),
  source_ref_id: model.text().nullable(), // wheel_spin.id or daily_check_in.id that produced it
})

export default LoyaltyCoupon
