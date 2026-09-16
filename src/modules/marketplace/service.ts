import { MedusaService } from "@medusajs/framework/utils"
import Vendor from "./models/vendor"
import VendorAdmin from "./models/vendor-admin"
import VendorPayout from "./models/vendor-payout"
import VendorVerification from "./models/vendor-verification"

class MarketplaceModuleService extends MedusaService({
  Vendor,
  VendorAdmin,
  VendorPayout,
  VendorVerification
}) {
  async addVendorBalance(vendorId: string, amount: number) {
    const vendor = await this.retrieveVendor(vendorId)
    const newBalance = Number(vendor.balance) + Number(amount)
    
    return await this.updateVendors({
      id: vendorId,
      balance: newBalance
    })
  }

  /**
   * Débit qui peut rendre la balance négative — contrairement à
   * deductVendorBalance, qui protège les demandes de retrait.
   *
   * Un remboursement client ne doit jamais être bloqué parce que le vendeur a
   * déjà retiré son argent : la dette est portée par la balance, et le
   * prochain versement l'apure.
   */
  async debitVendorBalance(vendorId: string, amount: number) {
    const vendor = await this.retrieveVendor(vendorId)
    return await this.updateVendors({
      id: vendorId,
      balance: Number(vendor.balance) - Number(amount),
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