import { createStep, StepResponse } from "@medusajs/framework/workflows-sdk"
import { MARKETPLACE_MODULE } from "../../../../modules/marketplace"
import MarketplaceModuleService from "../../../../modules/marketplace/service"

type StepInput = {
  email: string
  first_name?: string
  last_name?: string
  vendor_id: string
}

const createVendorAdminStep = createStep(
  "create-vendor-admin-for-vendor-step",
  async (data: StepInput, { container }) => {
    const svc: MarketplaceModuleService = container.resolve(MARKETPLACE_MODULE)
    const vendorAdmin = await svc.createVendorAdmins(data)
    return new StepResponse(vendorAdmin, vendorAdmin.id)
  },
  async (id, { container }) => {
    if (!id) return
    const svc: MarketplaceModuleService = container.resolve(MARKETPLACE_MODULE)
    await svc.deleteVendorAdmins(id)
  }
)

export default createVendorAdminStep
