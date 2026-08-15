import { model } from "@medusajs/framework/utils"

const UserActivity = model.define("user_activity", {
  id: model.id().primaryKey(),
  customer_id: model.text().index(),
  action_type: model.enum([
    "product_view",
    "add_to_cart",
    "remove_from_cart",
    "wishlist_add",
    "wishlist_remove",
    "search",
    "checkout_step",
    "purchase",
  ]),
  entity_type: model.text().nullable(), // "product" | "order" | "search_query" | ...
  entity_id: model.text().nullable(),
  metadata: model.json().nullable(), // free-form extra context (e.g. search query, step name, quantity)
})

export default UserActivity
