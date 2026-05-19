import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { Modules } from "@medusajs/framework/utils"

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const { variant_id } = req.params
  const productModule = req.scope.resolve(Modules.PRODUCT)
  
  const variant = await productModule.retrieveProductVariant(variant_id)
  
  res.json({ variant })
}

export const PUT = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const { variant_id } = req.params
  const productModule = req.scope.resolve(Modules.PRODUCT)
  
  const variant = await productModule.updateProductVariants([
    {
      id: variant_id,
      ...req.body,
    },
  ])
  
  res.json({ variant: variant[0] })
}

export const DELETE = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const { variant_id } = req.params
  const productModule = req.scope.resolve(Modules.PRODUCT)
  
  await productModule.deleteProductVariants([variant_id])
  
  res.json({ message: "Variant deleted successfully" })
}
