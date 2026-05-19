import { 
  createWorkflow,
  transform,
  WorkflowResponse
} from "@medusajs/framework/workflows-sdk"
import { 
  setAuthAppMetadataStep,
  useQueryGraphStep,
} from "@medusajs/medusa/core-flows"
import createVendorAdminStep from "./steps/create-vendor-admin"
import createVendorStep from "./steps/create-vendor"

export type CreateVendorWorkflowInput = {
  name: string
  handle?: string
  logo?: string
  admin: {
    email: string
    first_name?: string
    last_name?: string
  }
  authIdentityId: string
}

const createVendorWorkflow = createWorkflow(
  "create-vendor",
  function (input: CreateVendorWorkflowInput) {
    const vendor = createVendorStep({
      name: input.name,
      handle: input.handle || input.name.toLowerCase().replace(/[^a-z0-9]/g, "-"),
      logo: input.logo,
    })

    const vendorAdminData = transform({
      input,
      vendor
    }, (data) => {
      return {
        ...data.input.admin,
        vendor_id: data.vendor.id,
      }
    })

    const vendorAdmin = createVendorAdminStep(vendorAdminData)

    setAuthAppMetadataStep({
      authIdentityId: input.authIdentityId,
      actorType: "vendor",
      value: vendorAdmin.id,
    })

    const { data: vendorWithAdmin } = useQueryGraphStep({
      entity: "vendor",
      fields: ["id", "name", "handle", "logo", "admins.id", "admins.email", "admins.first_name", "admins.last_name"],
      filters: {
        id: vendor.id,
      },
    })

    return new WorkflowResponse({
      vendor: vendorWithAdmin[0],
    })
  }
)

export default createVendorWorkflow
