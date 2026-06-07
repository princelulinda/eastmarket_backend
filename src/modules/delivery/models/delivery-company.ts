import { model } from "@medusajs/framework/utils"
import DeliveryDriver from "./delivery-driver"

const DeliveryCompany = model.define("delivery_company", {
  id: model.id().primaryKey(),
  name: model.text(),
  logo: model.text().nullable(),
  phone: model.text().nullable(),
  email: model.text().unique(),
  website: model.text().nullable(),
  is_active: model.boolean().default(true),
  metadata: model.json().nullable(), // Pour stocker les clés API ou configurations spécifiques
  drivers: model.hasMany(() => DeliveryDriver, {
    mappedBy: "delivery_company",
  }),
})

export default DeliveryCompany
