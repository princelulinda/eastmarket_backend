import { AuthenticatedMedusaRequest } from "@medusajs/framework/http"
import { MedusaRequest } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"

export type VendorContext = {
  id: string
  name: string
  is_verified: boolean
  verified_at: string | null
}

/**
 * Résout la boutique du vendeur connecté à partir de l'actor_id (qui est un
 * vendor_admin.id, pas un vendor.id). Utilisé par tout ce qui doit connaître
 * l'état de vérification de la boutique.
 */
export async function getVendorContext(
  req: AuthenticatedMedusaRequest | MedusaRequest,
): Promise<VendorContext | null> {
  const actorId = (req as AuthenticatedMedusaRequest).auth_context?.actor_id
  if (!actorId) return null

  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id", "vendor.name", "vendor.is_verified", "vendor.verified_at"],
    filters: { id: [actorId] },
  })

  return (vendorAdmin?.vendor as VendorContext) ?? null
}

/** Variante qui échoue plutôt que de renvoyer null — pour les handlers de route. */
export async function requireVendorContext(
  req: AuthenticatedMedusaRequest,
): Promise<VendorContext> {
  const vendor = await getVendorContext(req)
  if (!vendor) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Vendor not found")
  }
  return vendor
}

/**
 * Identifiants des produits de la boutique connectée. Partagé par la liste
 * produits et la liste d'avis, qui doivent toutes deux borner leurs requêtes
 * au catalogue du vendeur.
 */
export async function getVendorProductIds(
  req: AuthenticatedMedusaRequest,
): Promise<string[]> {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.products.id"],
    filters: { id: [req.auth_context.actor_id] },
  })

  return (vendorAdmin?.vendor?.products || [])
    .map((p: { id: string } | null) => p?.id)
    .filter(Boolean) as string[]
}
