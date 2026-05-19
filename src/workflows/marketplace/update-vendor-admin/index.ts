import { createWorkflow, WorkflowResponse } from "@medusajs/framework/workflows-sdk"
import updateVendorAdminStep from "./steps/update-vendor-admin"

export type UpdateVendorAdminWorkflowInput = {
  id: string
  update: { first_name?: string; last_name?: string }
}

const updateVendorAdminWorkflow = createWorkflow(
  "update-vendor-admin",
  (input: UpdateVendorAdminWorkflowInput) => {
    const vendorAdmin = updateVendorAdminStep({ id: input.id, update: input.update })
    return new WorkflowResponse({ vendorAdmin })
  }
)

export default updateVendorAdminWorkflow
