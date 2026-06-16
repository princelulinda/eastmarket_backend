import { model } from "@medusajs/framework/utils"
import Vendor from "./vendor"

const VendorPayout = model.define("vendor_payout", {
  id: model.id().primaryKey(),
  amount: model.number(), // Montant en centimes
  status: model.enum(["pending", "approved", "rejected"]).default("pending"),
  payment_method: model.text(), // ex: "mobile_money", "bank_transfer"
  payment_details: model.json(), // ex: { phone: "+...", provider: "..." } or { bank: "...", iban: "..." }
  rejection_reason: model.text().nullable(),
  vendor: model.belongsTo(() => Vendor, {
    mappedBy: "payouts"
  })
})

export default VendorPayout
