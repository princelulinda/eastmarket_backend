import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { Modules } from "@medusajs/framework/utils"

export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const { id } = req.params
  const productModule = req.scope.resolve(Modules.PRODUCT)
  
  // Essayer de passer l'objet directement au lieu d'un tableau enveloppé
  const variant = await productModule.createProductVariants({
    ...req.body,
    product_id: id,
  })
  
  res.json({ variant })
}
