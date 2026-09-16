import { model } from "@medusajs/framework/utils"
import Vendor from "./vendor"

/**
 * Dossier KYC d'une boutique. Données strictement privées : rien de ce modèle
 * n'est exposé côté vitrine. Le seul signal public est `vendor.is_verified` /
 * `vendor.verified_at`, positionné à l'approbation.
 *
 * Un vendeur peut avoir plusieurs lignes : après un refus il re-soumet, et
 * l'ancien dossier est conservé pour l'historique de revue.
 */
const VendorVerification = model.define("vendor_verification", {
  id: model.id().primaryKey(),
  status: model.enum(["pending", "approved", "rejected"]).default("pending"),

  // Identité du responsable légal
  legal_name: model.text(),
  id_document_type: model.enum(["national_id", "passport", "driver_license"]),
  id_document_number: model.text(),

  // Entreprise — nul pour un vendeur particulier
  registration_number: model.text().nullable(), // RCCM / n° d'immatriculation
  tax_id: model.text().nullable(),

  // Contact vérifiable
  contact_phone: model.text(),
  contact_address: model.text(),

  // [{ kind, file_id, filename }] — file_id est la clé du fichier privé,
  // jamais une URL : celle-ci est signée à la demande côté admin.
  documents: model.json(),

  rejection_reason: model.text().nullable(),
  reviewed_at: model.dateTime().nullable(),
  reviewed_by: model.text().nullable(), // user.id de l'admin ayant tranché

  vendor: model.belongsTo(() => Vendor, {
    mappedBy: "verifications",
  }),
})

export default VendorVerification
