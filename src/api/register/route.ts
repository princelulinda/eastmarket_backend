import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { IMarketplaceModuleService } from "../../modules/marketplace"
import { MARKETPLACE_MODULE } from "../../modules/marketplace"
import bcrypt from "bcryptjs"

export async function POST(req: MedusaRequest, res: MedusaResponse) {
  const { email, password, first_name, last_name, vendor_id } = req.body
  const marketplaceModule: IMarketplaceModuleService = req.scope.resolve(MARKETPLACE_MODULE)

  // 1. Vérifier si l'admin existe déjà
  const existing = await marketplaceModule.listVendorAdmins({ email })
  if (existing && existing.length > 0) {
    return res.status(400).json({ message: "Email already registered" })
  }

  // 2. Hasher le mot de passe
  const salt = await bcrypt.genSalt(10)
  const hashedPassword = await bcrypt.hash(password, salt)

  // 3. Créer l'admin vendeur
  const newAdmin = await marketplaceModule.createVendorAdmins({
    email,
    password: hashedPassword,
    first_name,
    last_name,
    vendor: { id: vendor_id }
  })

  res.status(201).json({ 
    message: "Vendor admin registered successfully",
    vendor_admin: { id: newAdmin.id, email: newAdmin.email }
  })
}
