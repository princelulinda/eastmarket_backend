import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"

/**
 * GET /vendors/shipping-profiles
 *
 * Profils d'expédition sélectionnables à la création d'un produit. Le profil
 * "default" est renvoyé en premier : c'est celui appliqué automatiquement quand
 * le vendeur n'en choisit aucun.
 */
export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const { data: shippingProfiles } = await query.graph({
    entity: "shipping_profile",
    fields: ["id", "name", "type"],
  })

  const profiles = [...(shippingProfiles || [])]
  profiles.sort((a: any, b: any) =>
    a.type === "default" ? -1 : b.type === "default" ? 1 : 0,
  )

  res.json({ shipping_profiles: profiles })
}
