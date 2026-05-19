import { model } from "@medusajs/framework/utils"

const OpeninaryAsset = model.define("openinary_asset", {
  id: model.id().primaryKey(),
  // Référence à l'identifiant unique sur Openinary
  public_id: model.text().unique(),
  // URL de base de l'asset sur Openinary (peut être source ou transformé)
  url: model.text(),
  // Optionnel : pour lier l'asset à un autre modèle Medusa (ex: Product, Vendor)
  resource_type: model.text().nullable(), // 'image', 'video', etc.
  // Champs pour les images optimisées (si différents de l'URL principale)
  // On peut générer ces URLs dynamiquement, donc pas forcément à stocker
})

export default OpeninaryAsset
