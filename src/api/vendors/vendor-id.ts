import { AuthenticatedMedusaRequest } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"

/**
 * Identifiant de la boutique du vendeur connecté.
 *
 * `req.auth_context.actor_id` désigne l'administrateur, pas la boutique. La
 * distinction compte : les notifications, les jetons push et les préférences
 * sont tous rangés sous l'identifiant de boutique, si bien qu'écrire sous
 * l'identifiant d'administrateur revient à écrire dans le vide.
 */
export async function resolveVendorId(req: AuthenticatedMedusaRequest): Promise<string> {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id"],
    filters: { id: [req.auth_context.actor_id] },
  })

  const vendorId = vendorAdmin?.vendor?.id
  if (!vendorId) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Vendor not found")
  }

  return vendorId
}
