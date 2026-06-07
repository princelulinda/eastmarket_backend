import { z } from "@medusajs/framework/zod"
import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, Modules } from "@medusajs/framework/utils"
import { createStockLocationsWorkflow, createRemoteLinkStep } from "@medusajs/medusa/core-flows"
import { 
  createWorkflow, 
  transform, 
  WorkflowResponse,
  useQueryGraphStep
} from "@medusajs/framework/workflows-sdk"
import { MARKETPLACE_MODULE } from "../../../modules/marketplace"

export const PostVendorStockLocationSchema = z.object({
  name: z.string(),
  address: z.object({
    address_1: z.string(),
    address_2: z.string().optional(),
    city: z.string(),
    country_code: z.string(),
    postal_code: z.string().optional(),
    province: z.string().optional(),
    phone: z.string().optional(),
  }).optional(),
}).strict()

type PostBody = z.infer<typeof PostVendorStockLocationSchema>

// Define a workflow to create a stock location and link it to the vendor
const createVendorStockLocationWorkflow = createWorkflow(
  "create-vendor-stock-location",
  (input: { vendor_id: string; location: any }) => {
    // 1. Create the stock location
    const locations = createStockLocationsWorkflow.runAsStep({
      input: {
        locations: [input.location]
      }
    })

    // 2. Link it to the vendor
    const linkDef = transform({ input, locations }, (data) => {
      return [{
        [MARKETPLACE_MODULE]: {
          vendor_id: data.input.vendor_id
        },
        [Modules.STOCK_LOCATION]: {
          stock_location_id: data.locations[0].id
        }
      }]
    })

    createRemoteLinkStep(linkDef)

    return new WorkflowResponse(locations[0])
  }
)

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  // Fetch only locations linked to this vendor
  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id"],
    filters: { id: [req.auth_context.actor_id] }
  })

  const { data: stock_locations } = await query.graph({
    entity: "vendor",
    fields: ["stock_locations.*", "stock_locations.address.*"],
    filters: { id: vendorAdmin.vendor.id }
  })

  res.json({ stock_locations: stock_locations[0]?.stock_locations || [] })
}

export const POST = async (req: AuthenticatedMedusaRequest<PostBody>, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  
  // Get vendor ID
  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id"],
    filters: { id: [req.auth_context.actor_id] }
  })

  const { result: location } = await createVendorStockLocationWorkflow(req.scope).run({
    input: {
      vendor_id: vendorAdmin.vendor.id,
      location: req.validatedBody
    }
  })

  res.json({ stock_location: location })
}
