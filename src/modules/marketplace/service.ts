import { MedusaService } from "@medusajs/framework/utils"
import Vendor from "./models/vendor"
import VendorAdmin from "./models/vendor-admin"

class MarketplaceModuleService extends MedusaService({
  Vendor,
  VendorAdmin
}) {
  async addVendorBalance(vendorId: string, amount: number) {
    const vendor = await this.retrieveVendor(vendorId)
    const newBalance = Number(vendor.balance) + Number(amount)
    
    return await this.updateVendors({
      id: vendorId,
      balance: newBalance
    })
  }
}

export default MarketplaceModuleService