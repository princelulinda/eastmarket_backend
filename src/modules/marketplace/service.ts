import { MedusaService } from "@medusajs/framework/utils"
import Vendor from "./models/vendor"
import VendorAdmin from "./models/vendor-admin"
import VendorPayout from "./models/vendor-payout"

class MarketplaceModuleService extends MedusaService({
  Vendor,
  VendorAdmin,
  VendorPayout
}) {
  async addVendorBalance(vendorId: string, amount: number) {
    const vendor = await this.retrieveVendor(vendorId)
    const newBalance = Number(vendor.balance) + Number(amount)
    
    return await this.updateVendors({
      id: vendorId,
      balance: newBalance
    })
  }

  async deductVendorBalance(vendorId: string, amount: number) {
    const vendor = await this.retrieveVendor(vendorId)
    if (Number(vendor.balance) < Number(amount)) {
      throw new Error("Insufficient balance")
    }
    const newBalance = Number(vendor.balance) - Number(amount)
    
    return await this.updateVendors({
      id: vendorId,
      balance: newBalance
    })
  }
}

export default MarketplaceModuleService