import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { IMarketplaceModuleService } from "../../../modules/marketplace"
import { Modules } from "@medusajs/framework/utils"
import bcrypt from "bcryptjs"

export async function POST(req: MedusaRequest, res: MedusaResponse) {
  const { email, password } = req.body
  const marketplaceModule: IMarketplaceModuleService = req.scope.resolve(Modules.MARKETPLACE)

  // 1. Trouver l'admin vendeur par email
  const admins = await marketplaceModule.listVendorAdmins({ email })
  if (!admins || admins.length === 0) {
    return res.status(401).json({ message: "Invalid credentials" })
  }

  const admin = admins[0]

  // 2. Vérifier le mot de passe
  const isMatch = await bcrypt.compare(password, (admin as any).password)
  if (!isMatch) {
    return res.status(401).json({ message: "Invalid credentials" })
  }

  // 3. Réponse de succès (Session à gérer via middleware dans une étape ultérieure)
  res.status(200).json({ 
    message: "Logged in successfully",
    vendor_admin: { id: admin.id, email: admin.email }
  })
}
