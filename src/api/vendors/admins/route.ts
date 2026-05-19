import { z } from "@medusajs/framework/zod"
import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError, Modules } from "@medusajs/framework/utils"
import createVendorAdminWorkflow from "../../../workflows/marketplace/create-vendor-admin"

export const PostVendorAdminSchema = z.object({
  email: z.string().email(),
  first_name: z.string().optional(),
  last_name: z.string().optional(),
  password: z.string(),
}).strict()

type PostBody = z.infer<typeof PostVendorAdminSchema>

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.admins.*"],
    filters: { id: [req.auth_context.actor_id] }
  })

  res.json({ admins: vendorAdmin.vendor.admins })
}

export const POST = async (req: AuthenticatedMedusaRequest<PostBody>, res: MedusaResponse) => {
  const { email, password, first_name, last_name } = req.validatedBody

  const authService = req.scope.resolve(Modules.AUTH)

  const { success: regSuccess, authIdentity: newIdentity, error: regError } = await authService.register("emailpass", {
    url: req.url,
    headers: req.headers as Record<string, string>,
    query: req.query as Record<string, string>,
    body: { email, password },
    authScope: "vendor",
    protocol: req.protocol,
  })

  if (!regSuccess || !newIdentity) {
    throw new MedusaError(MedusaError.Types.INVALID_DATA, regError || "Failed to register vendor admin")
  }

  const { result } = await createVendorAdminWorkflow(req.scope).run({
    input: {
      vendor_admin_id: req.auth_context.actor_id,
      admin: { email, first_name, last_name },
      authIdentityId: newIdentity.id,
    }
  })

  return res.json({ vendor_admin: result.vendorAdmin })
}
