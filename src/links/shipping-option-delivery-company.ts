import { defineLink } from "@medusajs/framework/utils"
import DeliveryModule from "../modules/delivery"
import FulfillmentModule from "@medusajs/medusa/fulfillment"

export default defineLink(
  {
    linkable: DeliveryModule.linkable.deliveryCompany,
    isList: true,
  },
  {
    linkable: FulfillmentModule.linkable.shippingOption,
    isList: true,
  }
)
