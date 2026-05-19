import { createStep, StepResponse } from "@medusajs/framework/workflows-sdk"
import { MARKETPLACE_MODULE } from "../../../../modules/marketplace"
import MarketplaceModuleService from "../../../../modules/marketplace/service"

type StepInput = {
  id: string
  update: { first_name?: string; last_name?: string }
}

const updateVendorAdminStep = createStep(
  "update-vendor-admin-step",
  async ({ id, update }: StepInput, { container }) => {
    const svc: MarketplaceModuleService = container.resolve(MARKETPLACE_MODULE)
    const before = await svc.retrieveVendorAdmin(id)
    const vendorAdmin = await svc.updateVendorAdmins({ id, ...update })
    return new StepResponse(vendorAdmin, { id, update: { first_name: before.first_name, last_name: before.last_name } })
  },
  async (rollback, { container }) => {
    if (!rollback) return
    const svc: MarketplaceModuleService = container.resolve(MARKETPLACE_MODULE)
    await svc.updateVendorAdmins({ id: rollback.id, ...rollback.update })
  }
)

export default updateVendorAdminStep
