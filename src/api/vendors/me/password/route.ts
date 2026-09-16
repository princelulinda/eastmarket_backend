import { z } from "@medusajs/framework/zod"
import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError, Modules } from "@medusajs/framework/utils"

export const PostVendorPasswordSchema = z.object({
  current_password: z.string().min(1),
  password: z.string().min(8),
}).strict()

type PostBody = z.infer<typeof PostVendorPasswordSchema>

/**
 * POST /vendors/me/password — Change le mot de passe du compte connecté.
 *
 * La route native de Medusa (/auth/:actor/:provider/update) attend un jeton de
 * réinitialisation reçu par email, pas un jeton de session : elle ne convient
 * donc pas à un changement depuis l'application. Ici on repasse par le provider
 * emailpass, après avoir revérifié le mot de passe actuel — sans quoi un
 * téléphone déverrouillé suffirait à prendre la main sur le compte.
 */
export const POST = async (req: AuthenticatedMedusaRequest<PostBody>, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const authService = req.scope.resolve(Modules.AUTH)

  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["id", "email"],
    filters: { id: [req.auth_context.actor_id] },
  })

  if (!vendorAdmin?.email) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Vendor admin not found")
  }

  const { current_password, password } = req.validatedBody

  const check = await authService.authenticate("emailpass", {
    url: req.url,
    headers: req.headers as Record<string, string>,
    query: {},
    body: { email: vendorAdmin.email, password: current_password },
    protocol: req.protocol,
  } as any)

  if (!check.success) {
    throw new MedusaError(MedusaError.Types.UNAUTHORIZED, "Mot de passe actuel incorrect.")
  }

  const { success, error } = await authService.updateProvider("emailpass", {
    entity_id: vendorAdmin.email,
    password,
  } as any)

  if (!success) {
    throw new MedusaError(MedusaError.Types.INVALID_DATA, error || "Impossible de modifier le mot de passe.")
  }

  res.json({ success: true })
}
