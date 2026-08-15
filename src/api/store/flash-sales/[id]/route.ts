import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import { FLASH_SALE_MODULE } from "../../../../modules/flash-sale"
import FlashSaleModuleService from "../../../../modules/flash-sale/service"

export const GET = async (req: MedusaRequest, res: MedusaResponse) => {
  const service = req.scope.resolve(FLASH_SALE_MODULE) as FlashSaleModuleService

  const sale = await service.retrieveFlashSale(req.params.id).catch(() => null)
  if (!sale) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Flash sale not found")
  }

  res.json({ flash_sale: sale })
}
