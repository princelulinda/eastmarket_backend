import { createStep, StepResponse } from "@medusajs/framework/workflows-sdk"
import { MARKETPLACE_MODULE } from "../../../../modules/marketplace"
import MarketplaceModuleService from "../../../../modules/marketplace/service"

type UpdateVendorStepInput = {
  id: string
  update: {
    name?: string
    logo?: string
    cover_image?: string
    description?: string
    phone?: string
    email?: string
    website?: string
    country?: string
    city?: string
    address?: string
    founded_year?: number
    business_type?: string
    main_products?: string
    employee_count?: string
    social_links?: Record<string, string>
    response_time?: string
  }
}

const updateVendorStep = createStep(
  "update-vendor-step",
  async ({ id, update }: UpdateVendorStepInput, { container }) => {
    const svc: MarketplaceModuleService = container.resolve(MARKETPLACE_MODULE)
    const before = await svc.retrieveVendor(id)
    const vendor = await svc.updateVendors({ id, ...update })
    return new StepResponse(vendor, { id, update: { name: before.name, logo: before.logo } })
  },
  async (rollback, { container }) => {
    if (!rollback) return
    const svc: MarketplaceModuleService = container.resolve(MARKETPLACE_MODULE)
    await svc.updateVendors({ id: rollback.id, ...rollback.update })
  }
)

export default updateVendorStep
