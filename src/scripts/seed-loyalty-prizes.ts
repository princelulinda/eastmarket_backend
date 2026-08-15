import { ExecArgs } from "@medusajs/framework/types"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { LOYALTY_MODULE } from "../modules/loyalty"
import LoyaltyModuleService from "../modules/loyalty/service"

const PRIZES = [
  { label: "20 pts", prize_type: "points" as const, points_value: 20, weight: 30, color: "#FFD9C2", icon: "star", sort_order: 0 },
  { label: "50 pts", prize_type: "points" as const, points_value: 50, weight: 20, color: "#FFB088", icon: "star", sort_order: 1 },
  { label: "Try again", prize_type: "no_win" as const, weight: 20, color: "#F0F0F0", icon: "refresh", sort_order: 2 },
  { label: "100 pts", prize_type: "points" as const, points_value: 100, weight: 12, color: "#FF9E66", icon: "star", sort_order: 3 },
  { label: "5% off", prize_type: "coupon_percentage" as const, coupon_discount_value: 5, coupon_validity_days: 5, weight: 10, color: "#FF7A3D", icon: "pricetag", sort_order: 4 },
  { label: "Free shipping", prize_type: "free_shipping" as const, coupon_validity_days: 7, weight: 5, color: "#FF6420", icon: "cube", sort_order: 5 },
  { label: "10% off", prize_type: "coupon_percentage" as const, coupon_discount_value: 10, coupon_validity_days: 7, weight: 3, color: "#FF5000", icon: "pricetag", sort_order: 6 },
  { label: "Jackpot 300 pts", prize_type: "points" as const, points_value: 300, weight: 0.5, color: "#E64400", icon: "trophy", sort_order: 7 },
]

export default async function seedLoyaltyPrizes({ container }: ExecArgs) {
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER)
  const service = container.resolve(LOYALTY_MODULE) as LoyaltyModuleService

  const existing = await service.listWheelPrizes({})
  if (existing.length > 0) {
    logger.info(`Loyalty wheel already has ${existing.length} prizes configured, skipping seed.`)
    return
  }

  await Promise.all(
    PRIZES.map((p) =>
      service.createWheelPrizes({
        label: p.label,
        prize_type: p.prize_type,
        points_value: "points_value" in p ? p.points_value : null,
        coupon_discount_value: "coupon_discount_value" in p ? p.coupon_discount_value : null,
        coupon_validity_days: "coupon_validity_days" in p ? p.coupon_validity_days : null,
        weight: p.weight,
        color: p.color,
        icon: p.icon,
        is_active: true,
        sort_order: p.sort_order,
      })
    )
  )

  logger.info(`Seeded ${PRIZES.length} wheel prizes.`)
}
