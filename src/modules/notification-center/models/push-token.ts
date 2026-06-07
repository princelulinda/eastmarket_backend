import { model } from "@medusajs/framework/utils"

const PushToken = model.define("push_token", {
  id: model.id().primaryKey(),
  recipient_id: model.text().index(), // customer_id or vendor_id
  recipient_type: model.enum(["customer", "vendor"]),
  token: model.text(),
  device_type: model.text().nullable(),
})

export default PushToken
