import { Module } from "@medusajs/framework/utils"
import DeliveryModuleService from "./service"
import DeliveryCompany from "./models/delivery-company"
import DeliveryDriver from "./models/delivery-driver"


export const DELIVERY_MODULE = "delivery"

export default Module(DELIVERY_MODULE, {
  service: DeliveryModuleService,
})

export const linkable = {
  deliveryCompany: {
    linkable: DeliveryCompany,
    meta: {
      module: DELIVERY_MODULE,
    },
  },
}
