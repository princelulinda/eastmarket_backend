import { model } from "@medusajs/framework/utils"
import DeliveryCompany from "./delivery-company"

const DeliveryDriver = model.define("delivery_driver", {
  id: model.id().primaryKey(),
  name: model.text(),
  phone: model.text(),
  vehicle_details: model.text().nullable(), // Ex. plaque d'immatriculation, type de véhicule
  is_active: model.boolean().default(true),
  metadata: model.json().nullable(), // Pour stocker le token push, etc.
  delivery_company: model.belongsTo(() => DeliveryCompany, {
    mappedBy: "drivers",
  }),
})

export default DeliveryDriver
