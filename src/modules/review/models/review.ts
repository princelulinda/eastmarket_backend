import { model } from "@medusajs/framework/utils"

const Review = model.define("review", {
  id: model.id().primaryKey(),
  product_id: model.text(),
  customer_id: model.text(),
  rating: model.number(), // 1 to 5
  content: model.text().nullable(),
})

export default Review
