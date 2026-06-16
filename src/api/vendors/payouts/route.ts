import { z } from "@medusajs/framework/zod"
import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"
import { MARKETPLACE_MODULE } from "../../../modules/marketplace"
import MarketplaceModuleService from "../../../modules/marketplace/service"

export const PostVendorPayoutSchema = z.object({
  amount: z.number().int().positive(), // Montant en centimes
  payment_method: z.string(), // ex: "mobile_money", "bank_transfer"
  payment_details: z.record(z.any()), // ex: { phone: "+...", provider: "..." }
}).strict()

type PostBody = z.infer<typeof PostVendorPayoutSchema>

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  // 1. Récupérer le vendor de l'admin connecté
  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id"],
    filters: { id: [req.auth_context.actor_id] }
  })

  if (!vendorAdmin?.vendor?.id) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Vendor not found")
  }

  // 2. Récupérer l'historique des payouts pour ce vendor
  const { data: payouts } = await query.graph({
    entity: "vendor_payout",
    fields: ["id", "amount", "status", "payment_method", "payment_details", "rejection_reason", "created_at"],
    filters: { vendor_id: vendorAdmin.vendor.id }
  })

  res.json({ payouts })
}

export const POST = async (req: AuthenticatedMedusaRequest<PostBody>, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const marketplaceModule: MarketplaceModuleService = req.scope.resolve(MARKETPLACE_MODULE)
  const { amount, payment_method, payment_details } = req.validatedBody

  // 1. Récupérer le vendor de l'admin connecté
  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id", "vendor.balance"],
    filters: { id: [req.auth_context.actor_id] }
  })

  const vendor = vendorAdmin?.vendor
  if (!vendor) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Vendor not found")
  }

  // 2. Vérifier si le solde est suffisant
  if (Number(vendor.balance) < amount) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      `Insuffisant balance. Votre solde actuel est de ${vendor.balance} centimes.`
    )
  }

  // 3. Déduire le solde du vendeur
  await marketplaceModule.deductVendorBalance(vendor.id, amount)

  // 4. Créer la demande de payout
  const payout = await marketplaceModule.createVendorPayouts({
    amount,
    payment_method,
    payment_details,
    status: "pending",
    vendor: { id: vendor.id }
  })

  res.status(201).json({ payout })
}
