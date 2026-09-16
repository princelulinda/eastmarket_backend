import { ExecArgs } from "@medusajs/framework/types"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { MARKETPLACE_MODULE } from "../modules/marketplace"
import MarketplaceModuleService from "../modules/marketplace/service"

/** Marqueur des dossiers créés par cette reprise, pour les distinguer d'un vrai KYC. */
const LEGACY_MARKER = "<reprise automatique — boutique antérieure au KYC>"

/**
 * Reprise unique des boutiques ouvertes avant la mise en place du KYC.
 *
 *   npx medusa exec ./src/scripts/grandfather-vendor-verifications.ts
 *
 * Volontairement hors migration : accorder le badge « Vérifié » sans avoir vu
 * la moindre pièce d'identité est une décision d'exploitation, pas un
 * changement de schéma. Elle doit être explicite et datée.
 *
 * Ne lancez ce script que si vous ne voulez pas interrompre les boutiques
 * existantes. Sinon, ne faites rien : leur catalogue déjà publié reste en
 * ligne, seuls leurs NOUVEAUX produits partiront en brouillon jusqu'à ce
 * qu'elles soumettent un dossier — la restriction n'est pas rétroactive.
 *
 * Idempotent : une boutique déjà vérifiée est ignorée.
 */
export default async function grandfatherVendorVerifications({ container }: ExecArgs) {
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER)
  const marketplaceModule: MarketplaceModuleService = container.resolve(MARKETPLACE_MODULE)

  const vendors = await marketplaceModule.listVendors({})
  const pending = vendors.filter((v: any) => !v.is_verified)

  if (pending.length === 0) {
    logger.info("Toutes les boutiques sont déjà vérifiées, rien à reprendre.")
    return
  }

  logger.info(`Reprise de ${pending.length} boutique(s) sur ${vendors.length}.`)

  const verifiedAt = new Date()
  let done = 0

  for (const vendor of pending as any[]) {
    try {
      await marketplaceModule.createVendorVerifications({
        vendor_id: vendor.id,
        status: "approved",
        legal_name: LEGACY_MARKER,
        id_document_type: "national_id",
        id_document_number: LEGACY_MARKER,
        contact_phone: vendor.phone || LEGACY_MARKER,
        contact_address: vendor.address || LEGACY_MARKER,
        documents: [],
        reviewed_at: verifiedAt,
        reviewed_by: "system:grandfather",
      } as any)

      await marketplaceModule.updateVendors({
        id: vendor.id,
        is_verified: true,
        verified_at: verifiedAt,
      } as any)

      done++
    } catch (err) {
      logger.error(`Échec de la reprise pour la boutique ${vendor.id} (${vendor.name}): ${err}`)
    }
  }

  logger.info(`${done} boutique(s) reprises et marquées vérifiées.`)
  logger.info(
    "Ces dossiers portent le marqueur de reprise : ils n'ont fait l'objet d'aucun contrôle d'identité. " +
    "Prévoyez une campagne de régularisation si le badge doit refléter un KYC réel."
  )
}
