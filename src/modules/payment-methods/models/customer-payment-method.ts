import { model } from "@medusajs/framework/utils"

const CustomerPaymentMethod = model.define("customer_payment_method", {
  id: model.id().primaryKey(),
  customer_id: model.text().index(),
  provider_id: model.text(), // e.g., "stripe", "paypal"
  data: model.json().nullable(), // Store card details (last4, brand, expiry) and provider-specific IDs
  is_default: model.boolean().default(false),
  label: model.text().nullable(), // User-defined name like "My Visa Card"
})

export default CustomerPaymentMethod
