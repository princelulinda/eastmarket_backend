import { model } from "@medusajs/framework/utils"
import CustomerLoyalty from "./customer-loyalty"

const DailyCheckIn = model.define("daily_check_in", {
  id: model.id().primaryKey(),
  checkin_date: model.text(), // "YYYY-MM-DD"
  streak_count_at_checkin: model.number(),
  points_earned: model.number(),
  loyalty: model.belongsTo(() => CustomerLoyalty, { mappedBy: "checkins" }),
})

export default DailyCheckIn
