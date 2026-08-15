import { MedusaService } from "@medusajs/framework/utils"
import FlashSale from "./models/flash-sale"

class FlashSaleModuleService extends MedusaService({ FlashSale }) {
  async listActive() {
    const now = new Date()
    const sales = await this.listFlashSales({ is_active: true }, { order: { ends_at: "ASC" } })
    return sales.filter((s) => new Date(s.starts_at) <= now && new Date(s.ends_at) >= now)
  }

  async listForVendor(vendorId: string) {
    return await this.listFlashSales({ vendor_id: vendorId }, { order: { created_at: "DESC" } })
  }
}

export default FlashSaleModuleService
