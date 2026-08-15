import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { FLASH_SALE_MODULE } from "../../../modules/flash-sale"
import FlashSaleModuleService from "../../../modules/flash-sale/service"

export const GET = async (req: MedusaRequest, res: MedusaResponse) => {
  const service = req.scope.resolve(FLASH_SALE_MODULE) as FlashSaleModuleService

  const sales = await service.listActive()
  res.json({ flash_sales: sales })
}
