import { model } from "@medusajs/framework/utils"

const WheelPrize = model.define("wheel_prize", {
  id: model.id().primaryKey(),
  label: model.text(), // "50 pts", "10% off", "Try again"
  prize_type: model.enum([
    "points",
    "coupon_percentage",
    "coupon_fixed",
    "free_shipping",
    "no_win",
  ]),
  points_value: model.number().nullable(),
  coupon_discount_value: model.number().nullable(),
  coupon_validity_days: model.number().nullable(),
  weight: model.number().default(1), // relative probability weight, never exposed to client
  color: model.text().nullable(),
  icon: model.text().nullable(),
  is_active: model.boolean().default(true),
  sort_order: model.number().default(0),
})

export default WheelPrize
