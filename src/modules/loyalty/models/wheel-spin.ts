import { model } from "@medusajs/framework/utils"
import CustomerLoyalty from "./customer-loyalty"

const WheelSpin = model.define("wheel_spin", {
  id: model.id().primaryKey(),
  prize_id: model.text(), // wheel_prize.id (plain FK by convention, catalog lookup only)
  spin_date: model.text(), // "YYYY-MM-DD"
  points_earned: model.number().default(0),
  coupon_id: model.text().nullable(), // loyalty_coupon.id, if the prize granted a coupon
  loyalty: model.belongsTo(() => CustomerLoyalty, { mappedBy: "spins" }),
})

export default WheelSpin
