import { createWorkflow, transform, WorkflowResponse } from "@medusajs/framework/workflows-sdk"
import { useQueryGraphStep, setAuthAppMetadataStep } from "@medusajs/medusa/core-flows"
import createVendorAdminStep from "./steps/create-vendor-admin"

export type CreateVendorAdminWorkflowInput = {
  vendor_admin_id: string
  admin: {
    email: string
    first_name?: string
    last_name?: string
  }
  authIdentityId: string
}

const createVendorAdminWorkflow = createWorkflow(
  "create-vendor-admin-for-vendor",
  (input: CreateVendorAdminWorkflowInput) => {
    const { data: admins } = useQueryGraphStep({
      entity: "vendor_admin",
      fields: ["vendor.id"],
      filters: { id: input.vendor_admin_id },
      options: { throwIfKeyNotFound: true }
    })

    const vendorId = transform({ admins }, ({ admins }) => admins[0].vendor.id)

    const adminData = transform({ input, vendorId }, ({ input, vendorId }) => ({
      ...input.admin,
      vendor_id: vendorId
    }))

    const vendorAdmin = createVendorAdminStep(adminData)

    setAuthAppMetadataStep({
      authIdentityId: input.authIdentityId,
      actorType: "vendor",
      value: vendorAdmin.id,
    })

    return new WorkflowResponse({ vendorAdmin })
  }
)

export default createVendorAdminWorkflow
