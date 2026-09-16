import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
  MedusaNextFunction,
} from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { getVendorContext } from "../vendors/vendor-context"

/**
 * Marqueur posé sur les produits mis en brouillon d'office faute de
 * vérification. Le subscriber d'approbation ne publie que ceux-là : un
 * brouillon que le vendeur a délibérément laissé en brouillon doit le rester.
 */
export const PENDING_VERIFICATION_FLAG = "pending_vendor_verification"

/**
 * Tant que la boutique n'est pas vérifiée (KYC approuvé), ses produits restent
 * en brouillon et n'apparaissent donc pas en vitrine — /store/products et
 * /store/vendors/:id/products filtrent déjà sur `status === "published"`.
 *
 * On force le brouillon au lieu de refuser la requête : le vendeur peut monter
 * tout son catalogue pendant l'examen de son dossier, et la boutique s'ouvre
 * d'un coup à l'approbation. Un 403 sur la création de produit ferait
 * abandonner l'onboarding.
 *
 * La règle exacte est « pas de passage à publié », pas « tout en brouillon » :
 * un produit déjà en ligne n'est jamais dépublié par une simple modification.
 * Sans cette nuance, une boutique antérieure au KYC verrait son catalogue
 * disparaître de la vitrine à la première correction de prix.
 *
 * À poser APRÈS validateAndTransformBody : c'est `validatedBody` qui est
 * transmis au workflow.
 */
export async function forceDraftUntilApproved(
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse,
  next: MedusaNextFunction,
) {
  try {
    const vendor = await getVendorContext(req)

    // Boutique introuvable : laisse le handler produire son propre 404.
    if (!vendor || vendor.is_verified) {
      return next()
    }

    const body = (req.validatedBody ?? req.body) as Record<string, any> | undefined
    if (!body) return next()

    // Modification d'un produit existant : on ne touche pas à ce qui est déjà
    // en ligne, et on repart de ses métadonnées réelles plutôt que de celles
    // du corps de requête — `metadata` est remplacé en bloc par le workflow,
    // un corps sans métadonnées effacerait tout.
    let existingMetadata: Record<string, any> = {}
    const productId = req.params?.id
    if (productId) {
      const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
      const { data: [product] } = await query.graph({
        entity: "product",
        fields: ["id", "status", "metadata"],
        filters: { id: productId },
      })

      if (product?.status === "published") {
        return next()
      }
      existingMetadata = (product?.metadata as Record<string, any>) ?? {}
    }

    body.status = "draft"
    body.metadata = {
      ...existingMetadata,
      ...(body.metadata ?? {}),
      [PENDING_VERIFICATION_FLAG]: true,
    }

    // Lu par le handler pour signaler l'état au dashboard vendeur.
    ;(req as any).pending_vendor_verification = true

    next()
  } catch (err) {
    next(err)
  }
}
