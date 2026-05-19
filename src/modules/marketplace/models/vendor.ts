import { model } from "@medusajs/framework/utils"
import VendorAdmin from "./vendor-admin"

const Vendor = model.define("vendor", {
  id: model.id().primaryKey(),
  handle: model.text().unique().nullable(),
  name: model.text(),
  logo: model.text().nullable(),
  cover_image: model.text().nullable(),
  description: model.text().nullable(),
  phone: model.text().nullable(),
  email: model.text().nullable(),
  website: model.text().nullable(),
  // Localisation
  country: model.text().nullable(),
  city: model.text().nullable(),
  address: model.text().nullable(),
  // Business info
  founded_year: model.number().nullable(),
  business_type: model.text().nullable(), // manufacturer | trader | wholesaler | retailer | other
  main_products: model.text().nullable(),
  employee_count: model.text().nullable(), // "1-10" | "11-50" | "51-200" | "201-500" | "500+"
  // Social links (JSON)
  social_links: model.json().nullable(),
  // Credibility
  is_verified: model.boolean().default(false),
  response_rate: model.number().nullable(),   // percentage 0-100
  response_time: model.text().nullable(),     // "within 1 hour" | "within 24 hours" etc.
  admins: model.hasMany(() => VendorAdmin, {
    mappedBy: "vendor",
  })
})

export default Vendor
