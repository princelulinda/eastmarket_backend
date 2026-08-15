import { model } from "@medusajs/framework/utils"

const Referral = model.define("referral", {
  id: model.id().primaryKey(),
  referrer_customer_id: model.text().index(),
  referred_customer_id: model.text().unique(), // one referral link per referred customer
  code_used: model.text(),
  status: model.enum(["pending", "rewarded"]).default("pending"),
  rewarded_at: model.dateTime().nullable(),
  referrer_coupon_id: model.text().nullable(),
  referred_coupon_id: model.text().nullable(),
})

export default Referral
