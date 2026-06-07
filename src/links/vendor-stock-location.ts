import { defineLink } from "@medusajs/framework/utils"
import MarketplaceModule from "../modules/marketplace"
import StockLocationModule from "@medusajs/medusa/stock-location"

export default defineLink(
  MarketplaceModule.linkable.vendor,
  {
    linkable: StockLocationModule.linkable.stockLocation,
    isList: true
  }
)
