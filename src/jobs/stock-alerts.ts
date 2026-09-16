import { MedusaContainer } from "@medusajs/framework/types"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { STOCK_ALERT_MODULE } from "../modules/stock-alert"
import StockAlertModuleService, { levelFor, StockLevel } from "../modules/stock-alert/service"
import { notifyVendor } from "../modules/notification-center/notify"

/** Au-delà, on cite un échantillon plutôt que d'énumérer. */
const NAMED_IN_MESSAGE = 3

/**
 * Alerte de stock bas et de rupture.
 *
 * Le tableau de bord comptait déjà les ruptures, mais personne ne regarde un
 * compteur : le vendeur découvrait la rupture en lisant la réclamation d'un
 * client. Ce job prévient au moment du basculement.
 *
 * Deux garde-fous contre le harcèlement :
 *  — l'alerte n'est émise qu'au changement de niveau (ok → bas → rupture) ;
 *  — une seule notification par boutique et par passage, quel que soit le
 *    nombre de références concernées.
 */
export default async function stockAlertsJob(container: MedusaContainer) {
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER)
  const query = container.resolve(ContainerRegistrationKeys.QUERY)
  const stockAlerts: StockAlertModuleService = container.resolve(STOCK_ALERT_MODULE)

  const { data: vendors } = await query.graph({
    entity: "vendor",
    fields: ["id", "name", "products.id"],
  })

  for (const vendor of vendors as any[]) {
    try {
      const settings = await stockAlerts.getSettings(vendor.id)
      if (!settings.enabled) continue

      const productIds = (vendor.products || []).map((p: any) => p?.id).filter(Boolean)
      if (productIds.length === 0) continue

      const { data: products } = await query.graph({
        entity: "product",
        fields: [
          "id",
          "title",
          "status",
          "variants.id",
          "variants.title",
          "variants.sku",
          "variants.inventory.location_levels.available_quantity",
        ],
        filters: { id: productIds },
      })

      const rules = await stockAlerts.rulesByVariant(vendor.id)
      const newlyLow: { label: string; quantity: number; variantId: string; level: StockLevel }[] = []

      for (const product of products as any[]) {
        // Un brouillon n'est pas en vente : alerter dessus serait du bruit.
        if (product.status !== "published") continue

        for (const variant of product.variants || []) {
          const inventories = variant.inventory || []
          // Variante sans inventaire suivi : rien à comparer.
          if (inventories.length === 0) continue

          const quantity = inventories.reduce(
            (sum: number, inv: any) =>
              sum +
              (inv.location_levels || []).reduce(
                (s: number, l: any) => s + (Number(l?.available_quantity) || 0),
                0
              ),
            0
          )

          const rule = rules.get(variant.id)
          const threshold = rule?.threshold ?? settings.default_threshold
          const level = levelFor(quantity, threshold)
          const previous = (rule?.last_level ?? null) as StockLevel | null

          if (level === "ok") {
            // Réapprovisionné : on oublie l'alerte précédente pour que la
            // prochaine descente déclenche à nouveau.
            if (previous) await stockAlerts.recordLevel(vendor.id, variant.id, null)
            continue
          }

          // Même niveau qu'au dernier passage : déjà signalé.
          if (previous === level) continue
          // De "rupture" à "bas" : la situation s'améliore, pas d'alerte.
          if (previous === "out" && level === "low") {
            await stockAlerts.recordLevel(vendor.id, variant.id, level)
            continue
          }

          const isDefault = !variant.title || variant.title === "Default variant"
          newlyLow.push({
            variantId: variant.id,
            level,
            quantity,
            label: isDefault ? product.title : `${product.title} — ${variant.title}`,
          })
        }
      }

      if (newlyLow.length === 0) continue

      // L'état est enregistré avant l'envoi : si la notification échoue, le
      // job ne réessaiera pas indéfiniment à chaque heure.
      for (const item of newlyLow) {
        await stockAlerts.recordLevel(vendor.id, item.variantId, item.level)
      }

      const outCount = newlyLow.filter((i) => i.level === "out").length
      const named = newlyLow.slice(0, NAMED_IN_MESSAGE).map((i) => i.label).join(", ")
      const rest = newlyLow.length - NAMED_IN_MESSAGE

      const title =
        outCount > 0
          ? outCount === newlyLow.length
            ? "Rupture de stock"
            : "Stock épuisé ou faible"
          : "Stock faible"

      const body =
        newlyLow.length === 1
          ? newlyLow[0].level === "out"
            ? `${newlyLow[0].label} est en rupture.`
            : `Il reste ${newlyLow[0].quantity} unité(s) de ${newlyLow[0].label}.`
          : rest > 0
            ? `${named} et ${rest} autre(s) référence(s) à réapprovisionner.`
            : `${named} : à réapprovisionner.`

      await notifyVendor(container, {
        vendorId: vendor.id,
        type: "low_stock",
        title,
        body,
        data: {
          screen: "/store/inventory",
          count: newlyLow.length,
          out_of_stock: outCount,
        },
        pushCategory: "reminders",
      })
    } catch (err) {
      // Une boutique en échec ne doit pas priver les autres de leurs alertes.
      logger.error(`[stock-alerts] boutique ${vendor.id} : ${err}`)
    }
  }
}

export const config = {
  name: "stock-alerts",
  // Toutes les deux heures : assez réactif pour agir dans la journée, assez
  // espacé pour ne pas peser sur la base.
  schedule: "0 */2 * * *",
}
