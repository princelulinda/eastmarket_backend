import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"
import { FLASH_SALE_MODULE } from "../../../../../modules/flash-sale"
import FlashSaleModuleService from "../../../../../modules/flash-sale/service"

/**
 * POST /vendors/flash-sales/:id/end
 *
 * Arrête immédiatement une vente flash via l'interrupteur `is_active` du modèle,
 * sans toucher à la fenêtre de dates ni supprimer l'historique. La promotion
 * Medusa liée cesse de s'appliquer puisque listActive() filtre sur ce drapeau.
 */
export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const service = req.scope.resolve(FLASH_SALE_MODULE) as FlashSaleModuleService

  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id"],
    filters: { id: [req.auth_context.actor_id] },
  })

  let sale
  try {
    sale = await service.retrieveFlashSale(req.params.id)
  } catch {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Flash sale not found")
  }

  if (sale.vendor_id !== vendorAdmin?.vendor?.id) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Flash sale not found")
  }

  if (!sale.is_active) {
    throw new MedusaError(MedusaError.Types.NOT_ALLOWED, "Cette vente flash est déjà arrêtée.")
  }

  const [updated] = await service.updateFlashSales([{ id: sale.id, is_active: false }])

  res.json({ flash_sale: updated })
}
