import { model } from "@medusajs/framework/utils"
import DailyCheckIn from "./daily-check-in"
import WheelSpin from "./wheel-spin"

const CustomerLoyalty = model.define("customer_loyalty", {
  id: model.id().primaryKey(),
  customer_id: model.text().unique(),
  points_balance: model.number().default(0),
  lifetime_points: model.number().default(0),
  tier: model.enum(["bronze", "silver", "gold", "platinum"]).default("bronze"),
  current_streak: model.number().default(0),
  longest_streak: model.number().default(0),
  last_checkin_date: model.text().nullable(), // "YYYY-MM-DD"
  last_wheel_spin_date: model.text().nullable(), // "YYYY-MM-DD"
  referral_code: model.text().unique().nullable(), // lazily generated on first read
  checkins: model.hasMany(() => DailyCheckIn, { mappedBy: "loyalty" }),
  spins: model.hasMany(() => WheelSpin, { mappedBy: "loyalty" }),
})

export default CustomerLoyalty
