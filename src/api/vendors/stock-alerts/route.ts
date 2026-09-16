import { z } from "@medusajs/framework/zod"
import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { STOCK_ALERT_MODULE } from "../../../modules/stock-alert"
import StockAlertModuleService from "../../../modules/stock-alert/service"
import { resolveVendorId } from "../vendor-id"

/**
 * Réglages d'alerte de stock de la boutique, et seuils par référence.
 *
 * Les deux voyagent ensemble : l'écran d'inventaire a besoin des seuils
 * personnalisés en même temps que du seuil par défaut pour afficher le bon
 * repère sur chaque ligne.
 */

export const PutStockAlertsSchema = z.object({
  enabled: z.boolean().optional(),
  default_threshold: z.number().int().min(0).max(10000).optional(),
  /** Seuils par variante ; `null` fait retomber la variante sur le défaut. */
  thresholds: z
    .array(
      z.object({
        variant_id: z.string(),
        threshold: z.number().int().min(0).max(10000).nullable(),
      })
    )
    .max(200)
    .optional(),
}).strict()

type PutBody = z.infer<typeof PutStockAlertsSchema>

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const service: StockAlertModuleService = req.scope.resolve(STOCK_ALERT_MODULE)
  const vendorId = await resolveVendorId(req)

  const settings = await service.getSettings(vendorId)
  const rules = await service.listStockAlertRules({ vendor_id: vendorId })

  res.json({
    ...settings,
    thresholds: rules
      .filter((r: any) => r.threshold !== null && r.threshold !== undefined)
      .map((r: any) => ({ variant_id: r.variant_id, threshold: r.threshold })),
  })
}

export const PUT = async (
  req: AuthenticatedMedusaRequest<PutBody>,
  res: MedusaResponse
) => {
  const service: StockAlertModuleService = req.scope.resolve(STOCK_ALERT_MODULE)
  const vendorId = await resolveVendorId(req)
  const { thresholds, ...settings } = req.validatedBody

  if (Object.keys(settings).length > 0) {
    await service.setSettings(vendorId, settings)
  }

  for (const entry of thresholds ?? []) {
    await service.setThreshold(vendorId, entry.variant_id, entry.threshold)
  }

  const updated = await service.getSettings(vendorId)
  const rules = await service.listStockAlertRules({ vendor_id: vendorId })

  res.json({
    ...updated,
    thresholds: rules
      .filter((r: any) => r.threshold !== null && r.threshold !== undefined)
      .map((r: any) => ({ variant_id: r.variant_id, threshold: r.threshold })),
  })
}
