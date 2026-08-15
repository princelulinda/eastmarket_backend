import { MedusaService } from "@medusajs/framework/utils"
import VendorFollow from "./models/vendor-follow"

class FollowModuleService extends MedusaService({ VendorFollow }) {
  async isFollowing(customerId: string, vendorId: string) {
    const rows = await this.listVendorFollows({ customer_id: customerId, vendor_id: vendorId })
    return rows.length > 0
  }

  async follow(customerId: string, vendorId: string) {
    const already = await this.isFollowing(customerId, vendorId)
    if (already) return
    return await this.createVendorFollows({ customer_id: customerId, vendor_id: vendorId })
  }

  async unfollow(customerId: string, vendorId: string) {
    const rows = await this.listVendorFollows({ customer_id: customerId, vendor_id: vendorId })
    if (rows.length === 0) return
    await Promise.all(rows.map((r) => this.deleteVendorFollows(r.id)))
  }

  async countFollowers(vendorId: string) {
    const rows = await this.listVendorFollows({ vendor_id: vendorId })
    return rows.length
  }

  async listFollowerCustomerIds(vendorId: string) {
    const rows = await this.listVendorFollows({ vendor_id: vendorId })
    return rows.map((r) => r.customer_id)
  }

  async listFollowedVendorIds(customerId: string) {
    const rows = await this.listVendorFollows({ customer_id: customerId })
    return rows.map((r) => r.vendor_id)
  }
}

export default FollowModuleService
