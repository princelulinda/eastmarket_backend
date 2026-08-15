import { MedusaError, MedusaService } from "@medusajs/framework/utils"
import CustomerLoyalty from "./models/customer-loyalty"
import DailyCheckIn from "./models/daily-check-in"
import WheelPrize from "./models/wheel-prize"
import WheelSpin from "./models/wheel-spin"
import LoyaltyCoupon from "./models/loyalty-coupon"
import LoyaltyTransaction from "./models/loyalty-transaction"
import Referral from "./models/referral"

// Fixed reference timezone for all "today"/streak computations — never trust
// a client-supplied date, and never use server-local time (which may not be
// this offset in every deployment environment).
const LOYALTY_TZ_OFFSET_HOURS = 1 // WAT / Africa (matches primary market)

const TIER_THRESHOLDS: Array<{ tier: "bronze" | "silver" | "gold" | "platinum"; min: number }> = [
  { tier: "platinum", min: 5000 },
  { tier: "gold", min: 2000 },
  { tier: "silver", min: 500 },
  { tier: "bronze", min: 0 },
]

const CHECKIN_BASE_POINTS = 10
const CHECKIN_STREAK_BONUS_PER_DAY = 2
const CHECKIN_STREAK_BONUS_CAP_DAYS = 7
const MILESTONE_STREAK_DAYS = [7, 30]

function dateKeyWithOffset(daysAgo: number): string {
  const now = new Date(Date.now() + LOYALTY_TZ_OFFSET_HOURS * 60 * 60 * 1000)
  now.setUTCDate(now.getUTCDate() - daysAgo)
  return now.toISOString().slice(0, 10)
}

function isMilestoneStreak(streak: number): boolean {
  return MILESTONE_STREAK_DAYS.includes(streak) || (streak > 30 && streak % 30 === 0)
}

class LoyaltyModuleService extends MedusaService({
  CustomerLoyalty,
  DailyCheckIn,
  WheelPrize,
  WheelSpin,
  LoyaltyCoupon,
  LoyaltyTransaction,
  Referral,
}) {
  todayKey(): string {
    return dateKeyWithOffset(0)
  }

  computeTier(lifetimePoints: number): "bronze" | "silver" | "gold" | "platinum" {
    const match = TIER_THRESHOLDS.find((t) => lifetimePoints >= t.min)
    return match?.tier ?? "bronze"
  }

  getTierProgress(lifetimePoints: number) {
    // ascending order for this computation
    const ascending = [...TIER_THRESHOLDS].reverse()
    const currentIndex = ascending.findIndex((t) => t.tier === this.computeTier(lifetimePoints))
    const current = ascending[currentIndex]
    const next = ascending[currentIndex + 1]

    if (!next) {
      return { next_tier: current.tier, points_to_next_tier: 0, tier_progress_pct: 100 }
    }

    const span = next.min - current.min
    const progressed = lifetimePoints - current.min
    const pct = span > 0 ? Math.min(100, Math.max(0, Math.round((progressed / span) * 100))) : 100

    return {
      next_tier: next.tier,
      points_to_next_tier: Math.max(0, next.min - lifetimePoints),
      tier_progress_pct: pct,
    }
  }

  async getOrCreateLoyalty(customerId: string) {
    const existing = await this.listCustomerLoyalties({ customer_id: customerId })
    if (existing.length > 0) {
      return existing[0]
    }
    return await this.createCustomerLoyalties({ customer_id: customerId })
  }

  /** Single choke-point for every points balance mutation — writes the audit ledger. */
  async addPoints(
    customerId: string,
    delta: number,
    type: "checkin" | "wheel_spin" | "redeem_adjustment" | "admin_adjust" | "chat_engagement",
    refId?: string,
    description?: string
  ) {
    const loyalty = await this.getOrCreateLoyalty(customerId)
    const newBalance = Number(loyalty.points_balance) + delta
    const newLifetime = delta > 0 ? Number(loyalty.lifetime_points) + delta : Number(loyalty.lifetime_points)
    const newTier = this.computeTier(newLifetime)

    const updated = await this.updateCustomerLoyalties({
      id: loyalty.id,
      points_balance: newBalance,
      lifetime_points: newLifetime,
      tier: newTier,
    })

    await this.createLoyaltyTransactions({
      customer_id: customerId,
      type,
      points_delta: delta,
      balance_after: newBalance,
      ref_id: refId ?? null,
      description: description ?? null,
    })

    return updated
  }

  async getStatus(customerId: string) {
    const loyalty = await this.getOrCreateLoyalty(customerId)
    const today = this.todayKey()
    return {
      loyalty,
      checked_in_today: loyalty.last_checkin_date === today,
      can_spin_today: loyalty.last_wheel_spin_date !== today,
    }
  }

  /**
   * Performs today's check-in. All streak/day logic is computed here,
   * server-side, from the fixed-offset "today" — never from client input.
   */
  async checkIn(customerId: string) {
    const loyalty = await this.getOrCreateLoyalty(customerId)
    const today = this.todayKey()

    if (loyalty.last_checkin_date === today) {
      throw new MedusaError(MedusaError.Types.NOT_ALLOWED, "Already checked in today")
    }

    const yesterday = dateKeyWithOffset(1)
    const newStreak = loyalty.last_checkin_date === yesterday ? Number(loyalty.current_streak) + 1 : 1
    const newLongest = Math.max(Number(loyalty.longest_streak), newStreak)
    const bonusDays = Math.min(newStreak, CHECKIN_STREAK_BONUS_CAP_DAYS)
    const pointsEarned = CHECKIN_BASE_POINTS + bonusDays * CHECKIN_STREAK_BONUS_PER_DAY

    await this.updateCustomerLoyalties({
      id: loyalty.id,
      current_streak: newStreak,
      longest_streak: newLongest,
      last_checkin_date: today,
    })

    const checkin = await this.createDailyCheckIns({
      loyalty_id: loyalty.id,
      checkin_date: today,
      streak_count_at_checkin: newStreak,
      points_earned: pointsEarned,
    })

    const updatedLoyalty = await this.addPoints(customerId, pointsEarned, "checkin", checkin.id, `Daily check-in (day ${newStreak})`)

    return {
      loyalty: updatedLoyalty,
      checkin,
      streak: newStreak,
      points_earned: pointsEarned,
      milestone_reached: isMilestoneStreak(newStreak),
      milestone_streak: newStreak,
    }
  }

  async getActiveWheelPrizes() {
    return await this.listWheelPrizes({ is_active: true }, { order: { sort_order: "ASC" } })
  }

  /**
   * Executes one spin server-side: weighted-random prize pick + cooldown
   * enforcement. The client never influences which prize is chosen — the
   * spin animation on the frontend is purely cosmetic, driven by this result.
   */
  async spinWheel(customerId: string) {
    const loyalty = await this.getOrCreateLoyalty(customerId)
    const today = this.todayKey()

    if (loyalty.last_wheel_spin_date === today) {
      throw new MedusaError(MedusaError.Types.NOT_ALLOWED, "Already spun the wheel today")
    }

    const prizes = await this.getActiveWheelPrizes()
    if (prizes.length === 0) {
      throw new MedusaError(MedusaError.Types.NOT_FOUND, "No active wheel prizes configured")
    }

    const totalWeight = prizes.reduce((sum, p) => sum + Number(p.weight), 0)
    let roll = Math.random() * totalWeight
    let chosen = prizes[prizes.length - 1]
    for (const prize of prizes) {
      roll -= Number(prize.weight)
      if (roll <= 0) {
        chosen = prize
        break
      }
    }

    await this.updateCustomerLoyalties({ id: loyalty.id, last_wheel_spin_date: today })

    const pointsEarned = chosen.prize_type === "points" ? Number(chosen.points_value ?? 0) : 0

    const spin = await this.createWheelSpins({
      loyalty_id: loyalty.id,
      prize_id: chosen.id,
      spin_date: today,
      points_earned: pointsEarned,
    })

    let updatedLoyalty = loyalty
    if (pointsEarned > 0) {
      updatedLoyalty = await this.addPoints(customerId, pointsEarned, "wheel_spin", spin.id, `Wheel prize: ${chosen.label}`)
    }

    return { loyalty: updatedLoyalty, spin, prize: chosen }
  }

  async attachCouponToSpin(spinId: string, couponId: string) {
    return await this.updateWheelSpins({ id: spinId, coupon_id: couponId })
  }

  async listCustomerCoupons(customerId: string) {
    const coupons = await this.listLoyaltyCoupons({ customer_id: customerId }, { order: { created_at: "DESC" } })
    const today = new Date()
    const toExpire = coupons.filter((c) => c.status === "issued" && c.expires_at && new Date(c.expires_at) < today)
    if (toExpire.length > 0) {
      await Promise.all(toExpire.map((c) => this.updateLoyaltyCoupons({ id: c.id, status: "expired" })))
      toExpire.forEach((c) => (c.status = "expired"))
    }
    return coupons
  }

  async markCouponRedeemed(couponId: string, orderId: string) {
    return await this.updateLoyaltyCoupons({
      id: couponId,
      status: "redeemed",
      redeemed_at: new Date(),
      redeemed_order_id: orderId,
    })
  }

  async findCouponByCode(code: string) {
    const coupons = await this.listLoyaltyCoupons({ code })
    return coupons[0] ?? null
  }

  async getOrCreateReferralCode(customerId: string): Promise<string> {
    const loyalty = await this.getOrCreateLoyalty(customerId)
    if (loyalty.referral_code) return loyalty.referral_code

    // Retry on the rare collision since the code column is unique.
    for (let attempt = 0; attempt < 5; attempt++) {
      const code = `EM${Math.random().toString(36).slice(2, 7).toUpperCase()}`
      const existing = await this.listCustomerLoyalties({ referral_code: code })
      if (existing.length > 0) continue
      await this.updateCustomerLoyalties({ id: loyalty.id, referral_code: code })
      return code
    }
    throw new MedusaError(MedusaError.Types.UNEXPECTED_STATE, "Could not generate a unique referral code")
  }

  async findReferrerByCode(code: string) {
    const rows = await this.listCustomerLoyalties({ referral_code: code })
    return rows[0] ?? null
  }

  async getReferralLink(referredCustomerId: string) {
    const rows = await this.listReferrals({ referred_customer_id: referredCustomerId })
    return rows[0] ?? null
  }

  /**
   * Links a referred customer to their referrer. Does NOT check order
   * history — that requires the core order module and is enforced by the
   * caller (route layer) before this is invoked. Rejects self-referral and
   * customers who already redeemed a referral code.
   */
  async applyReferralCode(referredCustomerId: string, code: string) {
    const referrer = await this.findReferrerByCode(code)
    if (!referrer) {
      throw new MedusaError(MedusaError.Types.NOT_FOUND, "Invalid referral code")
    }
    if (referrer.customer_id === referredCustomerId) {
      throw new MedusaError(MedusaError.Types.NOT_ALLOWED, "You can't use your own referral code")
    }
    const existingLink = await this.getReferralLink(referredCustomerId)
    if (existingLink) {
      throw new MedusaError(MedusaError.Types.NOT_ALLOWED, "A referral code has already been applied to this account")
    }

    return await this.createReferrals({
      referrer_customer_id: referrer.customer_id,
      referred_customer_id: referredCustomerId,
      code_used: code,
      status: "pending",
    })
  }

  async markReferralRewarded(referralId: string, referrerCouponId: string, referredCouponId: string) {
    return await this.updateReferrals({
      id: referralId,
      status: "rewarded",
      rewarded_at: new Date(),
      referrer_coupon_id: referrerCouponId,
      referred_coupon_id: referredCouponId,
    })
  }

  async getReferralStats(customerId: string) {
    const referrals = await this.listReferrals({ referrer_customer_id: customerId })
    return {
      total_referred: referrals.length,
      total_rewarded: referrals.filter((r) => r.status === "rewarded").length,
    }
  }
}

export default LoyaltyModuleService
