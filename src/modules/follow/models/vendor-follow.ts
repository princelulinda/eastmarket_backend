import { model } from "@medusajs/framework/utils"

const VendorFollow = model.define("vendor_follow", {
  id: model.id().primaryKey(),
  customer_id: model.text().index(),
  vendor_id: model.text().index(),
})

export default VendorFollow
