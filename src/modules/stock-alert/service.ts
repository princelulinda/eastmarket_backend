import { MedusaService } from "@medusajs/framework/utils"
import StockAlertSetting from "./models/stock-alert-setting"
import StockAlertRule from "./models/stock-alert-rule"

/** Seuil retenu quand la boutique n'a jamais rien réglé. */
export const DEFAULT_THRESHOLD = 5

export type StockLevel = "ok" | "low" | "out"

export function levelFor(quantity: number, threshold: number): StockLevel {
  if (quantity <= 0) return "out"
  if (quantity <= threshold) return "low"
  return "ok"
}

class StockAlertModuleService extends MedusaService({
  StockAlertSetting,
  StockAlertRule,
}) {
  /** Réglages d'une boutique, valeurs par défaut comprises. */
  async getSettings(vendorId: string) {
    const [existing] = await this.listStockAlertSettings({ vendor_id: vendorId })
    return {
      vendor_id: vendorId,
      enabled: existing?.enabled ?? true,
      default_threshold: existing?.default_threshold ?? DEFAULT_THRESHOLD,
    }
  }

  async setSettings(
    vendorId: string,
    input: { enabled?: boolean; default_threshold?: number }
  ) {
    const [existing] = await this.listStockAlertSettings({ vendor_id: vendorId })

    if (existing) {
      await this.updateStockAlertSettings({ id: existing.id, ...input })
    } else {
      await this.createStockAlertSettings({
        vendor_id: vendorId,
        enabled: input.enabled ?? true,
        default_threshold: input.default_threshold ?? DEFAULT_THRESHOLD,
      })
    }

    return this.getSettings(vendorId)
  }

  /** Règles d'une boutique, indexées par variante. */
  async rulesByVariant(vendorId: string): Promise<Map<string, any>> {
    const rules = await this.listStockAlertRules({ vendor_id: vendorId })
    return new Map(rules.map((r: any) => [r.variant_id, r]))
  }

  /**
   * Fixe le seuil d'une variante. `null` la fait retomber sur le seuil de la
   * boutique sans perdre l'état d'alerte déjà enregistré.
   */
  async setThreshold(vendorId: string, variantId: string, threshold: number | null) {
    const [existing] = await this.listStockAlertRules({
      vendor_id: vendorId,
      variant_id: variantId,
    })

    if (existing) {
      await this.updateStockAlertRules({ id: existing.id, threshold })
      return
    }

    await this.createStockAlertRules({
      vendor_id: vendorId,
      variant_id: variantId,
      threshold,
    })
  }

  /**
   * Enregistre le niveau notifié pour une variante.
   *
   * C'est ce qui rend le job idempotent : tant que le niveau ne change pas,
   * aucune nouvelle alerte n'est émise, même si le job tourne toutes les heures.
   */
  async recordLevel(vendorId: string, variantId: string, level: StockLevel | null) {
    const [existing] = await this.listStockAlertRules({
      vendor_id: vendorId,
      variant_id: variantId,
    })

    const patch = {
      last_level: level,
      last_notified_at: level ? new Date() : null,
    }

    if (existing) {
      await this.updateStockAlertRules({ id: existing.id, ...patch })
      return
    }

    await this.createStockAlertRules({
      vendor_id: vendorId,
      variant_id: variantId,
      threshold: null,
      ...patch,
    })
  }
}

export default StockAlertModuleService
