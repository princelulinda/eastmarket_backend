import { model } from "@medusajs/framework/utils"

const NotificationPreference = model.define("notification_preference", {
  id: model.id().primaryKey(),
  recipient_id: model.text().index(),
  recipient_type: model.enum(["customer", "vendor"]),
  // { messages: true, reminders: true, broadcasts: true, orders: true,
  //   quiet_hours: { start: "22:00", end: "07:00" } | null }
  prefs: model.json(),
})

export default NotificationPreference
