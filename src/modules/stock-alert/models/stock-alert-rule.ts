import { model } from "@medusajs/framework/utils"

/**
 * Réglage et état d'alerte pour une variante.
 *
 * La ligne porte deux choses : le seuil propre à la référence (`threshold`,
 * null = seuil par défaut de la boutique) et l'état de la dernière alerte
 * envoyée. Les réunir évite une seconde table dont le seul rôle serait de
 * retenir « on a déjà prévenu » — et c'est cet état qui empêche le job de
 * renvoyer la même alerte toutes les heures.
 */
const StockAlertRule = model.define("stock_alert_rule", {
  id: model.id().primaryKey(),
  vendor_id: model.text().index(),
  variant_id: model.text().index(),
  /** Seuil propre à cette référence ; null = seuil de la boutique. */
  threshold: model.number().nullable(),
  /** Niveau lors de la dernière alerte : "low" ou "out". */
  last_level: model.text().nullable(),
  last_notified_at: model.dateTime().nullable(),
})

export default StockAlertRule
