import { model } from "@medusajs/framework/utils"
import Message from "./message"

const Conversation = model.define("conversation", {
  id: model.id().primaryKey(),
  customer_id: model.text().nullable(),
  vendor_id: model.text().nullable(),
  last_message_at: model.dateTime().nullable(),
  messages: model.hasMany(() => Message, { mappedBy: "conversation" }),
})

export default Conversation
