import { defineLink } from "@medusajs/framework/utils"
import MarketplaceModule from "../modules/marketplace"
import PromotionModule from "@medusajs/medusa/promotion"

export default defineLink(
  MarketplaceModule.linkable.vendor,
  {
    linkable: PromotionModule.linkable.promotion,
    isList: true
  }
)
