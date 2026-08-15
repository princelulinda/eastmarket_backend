import { model } from "@medusajs/framework/utils"

const LoyaltyTransaction = model.define("loyalty_transaction", {
  id: model.id().primaryKey(),
  customer_id: model.text().index(),
  type: model.enum(["checkin", "wheel_spin", "redeem_adjustment", "admin_adjust", "chat_engagement"]),
  points_delta: model.number(),
  balance_after: model.number(),
  description: model.text().nullable(),
  ref_id: model.text().nullable(), // daily_check_in.id / wheel_spin.id
})

export default LoyaltyTransaction
