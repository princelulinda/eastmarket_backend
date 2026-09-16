import { model } from "@medusajs/framework/utils"

/**
 * Réglage d'alerte de stock pour une boutique.
 *
 * Une ligne par vendeur ; l'absence de ligne vaut « réglages par défaut ».
 */
const StockAlertSetting = model.define("stock_alert_setting", {
  id: model.id().primaryKey(),
  vendor_id: model.text().unique(),
  enabled: model.boolean().default(true),
  /** Seuil appliqué aux variantes sans réglage propre. */
  default_threshold: model.number().default(5),
})

export default StockAlertSetting
