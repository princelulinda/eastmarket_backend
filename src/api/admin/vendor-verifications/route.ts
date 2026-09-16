import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { MARKETPLACE_MODULE } from "../../../modules/marketplace"
import MarketplaceModuleService from "../../../modules/marketplace/service"

const VALID_STATUSES = ["pending", "approved", "rejected"]

/**
 * File d'attente des dossiers KYC. `?status=pending` par défaut : c'est la vue
 * de travail de l'admin. Les documents ne sont pas résolus ici (une URL signée
 * par pièce et par ligne coûterait cher) — voir la route de détail.
 */
export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const marketplaceModule: MarketplaceModuleService = req.scope.resolve(MARKETPLACE_MODULE)
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const { status = "pending", limit = 50, offset = 0 } = req.query as Record<string, any>

  const filters: Record<string, any> = {}
  if (status !== "all") {
    filters.status = VALID_STATUSES.includes(status) ? status : "pending"
  }

  const verifications = await marketplaceModule.listVendorVerifications(filters, {
    order: { created_at: "DESC" },
    take: Number(limit),
    skip: Number(offset),
  })

  // Le nom de la boutique est ce que l'admin lit en premier dans la liste.
  const vendorIds = [...new Set(verifications.map((v: any) => v.vendor_id))]
  const { data: vendors } = vendorIds.length
    ? await query.graph({
        entity: "vendor",
        fields: ["id", "name", "handle", "logo", "is_verified"],
        filters: { id: vendorIds },
      })
    : { data: [] as any[] }

  const vendorById = new Map<string, any>(vendors.map((v: any) => [v.id, v] as [string, any]))

  res.json({
    vendor_verifications: verifications.map((v: any) => ({
      id: v.id,
      status: v.status,
      legal_name: v.legal_name,
      registration_number: v.registration_number,
      contact_phone: v.contact_phone,
      submitted_at: v.created_at,
      reviewed_at: v.reviewed_at,
      rejection_reason: v.rejection_reason,
      document_count: (v.documents || []).length,
      vendor: vendorById.get(v.vendor_id) ?? { id: v.vendor_id },
    })),
  })
}
