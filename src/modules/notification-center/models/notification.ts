import { model } from "@medusajs/framework/utils"

const AppNotification = model.define("app_notification", {
  id: model.id().primaryKey(),
  recipient_id: model.text(),    // customer_id or vendor_id
  recipient_type: model.enum(["customer", "vendor"]),
  type: model.enum([
    "new_message",
    "new_order",
    "order_status",
    "order_shipped",
    "order_delivered",
    "order_cancelled",
    "new_review",
    "system"
  ]),
  title: model.text(),
  body: model.text(),
  data: model.json().nullable(),  // extra payload (order_id, conversation_id, etc.)
  is_read: model.boolean().default(false),
})

export default AppNotification
