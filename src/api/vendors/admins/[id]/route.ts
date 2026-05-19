import { z } from "@medusajs/framework/zod"
import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"
import { deleteVendorAdminWorkflow } from "../../../../workflows/marketplace/delete-vendor-admin"
import updateVendorAdminWorkflow from "../../../../workflows/marketplace/update-vendor-admin"

export const PutVendorAdminSchema = z.object({
  first_name: z.string().optional(),
  last_name: z.string().optional(),
}).strict()

type PutBody = z.infer<typeof PutVendorAdminSchema>

async function getVendorAdminIds(req: AuthenticatedMedusaRequest): Promise<string[]> {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.admins.id"],
    filters: { id: [req.auth_context.actor_id] }
  })
  return (vendorAdmin.vendor.admins || []).map((a: { id: string }) => a.id)
}

export const PUT = async (req: AuthenticatedMedusaRequest<PutBody>, res: MedusaResponse) => {
  const adminIds = await getVendorAdminIds(req)
  if (!adminIds.includes(req.params.id)) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Vendor admin not found")
  }

  const { result } = await updateVendorAdminWorkflow(req.scope).run({
    input: {
      id: req.params.id,
      update: req.validatedBody
    }
  })

  res.json({ vendor_admin: result.vendorAdmin })
}

export const DELETE = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const adminIds = await getVendorAdminIds(req)
  if (!adminIds.includes(req.params.id)) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Vendor admin not found")
  }

  await deleteVendorAdminWorkflow(req.scope).run({
    input: { id: req.params.id }
  })

  res.json({ message: "success" })
}
