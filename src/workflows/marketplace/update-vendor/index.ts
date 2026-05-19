import { createWorkflow, transform, WorkflowResponse } from "@medusajs/framework/workflows-sdk"
import { useQueryGraphStep } from "@medusajs/medusa/core-flows"
import updateVendorStep from "./steps/update-vendor"

export type UpdateVendorWorkflowInput = {
  vendor_admin_id: string
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

const updateVendorWorkflow = createWorkflow(
  "update-vendor",
  (input: UpdateVendorWorkflowInput) => {
    const { data: admins } = useQueryGraphStep({
      entity: "vendor_admin",
      fields: ["vendor.id"],
      filters: { id: input.vendor_admin_id },
      options: { throwIfKeyNotFound: true }
    })

    const vendorId = transform({ admins }, ({ admins }) => admins[0].vendor.id)

    const vendor = updateVendorStep({
      id: vendorId,
      update: input.update
    })

    return new WorkflowResponse({ vendor })
  }
)

export default updateVendorWorkflow
