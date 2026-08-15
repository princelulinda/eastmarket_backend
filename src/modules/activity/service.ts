import { MedusaService } from "@medusajs/framework/utils"
import UserActivity from "./models/user-activity"

type TrackInput = {
  customer_id: string
  action_type:
    | "product_view"
    | "add_to_cart"
    | "remove_from_cart"
    | "wishlist_add"
    | "wishlist_remove"
    | "search"
    | "checkout_step"
    | "purchase"
  entity_type?: string
  entity_id?: string
  metadata?: Record<string, any>
}

class ActivityModuleService extends MedusaService({ UserActivity }) {
  async track(input: TrackInput) {
    return await this.createUserActivities({
      customer_id: input.customer_id,
      action_type: input.action_type,
      entity_type: input.entity_type ?? null,
      entity_id: input.entity_id ?? null,
      metadata: input.metadata ?? null,
    })
  }

  async listForCustomer(customerId: string, limit = 50, offset = 0) {
    return await this.listUserActivities(
      { customer_id: customerId } as any,
      { take: limit, skip: offset, order: { created_at: "DESC" } }
    )
  }

  /** Deduplicated, most-recently-viewed-first list of product ids. */
  async getRecentlyViewedProductIds(customerId: string, limit = 12) {
    const views = await this.listUserActivities(
      { customer_id: customerId, action_type: "product_view", entity_type: "product" } as any,
      { take: 60, order: { created_at: "DESC" } }
    )

    const seen = new Set<string>()
    const ordered: string[] = []
    for (const v of views) {
      const productId = (v as any).entity_id
      if (!productId || seen.has(productId)) continue
      seen.add(productId)
      ordered.push(productId)
      if (ordered.length >= limit) break
    }
    return ordered
  }
}

export default ActivityModuleService
