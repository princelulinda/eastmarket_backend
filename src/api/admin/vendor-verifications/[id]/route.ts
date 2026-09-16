import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError, Modules } from "@medusajs/framework/utils"
import { MARKETPLACE_MODULE } from "../../../../modules/marketplace"
import MarketplaceModuleService from "../../../../modules/marketplace/service"

/**
 * Détail d'un dossier, avec les pièces jointes.
 *
 * Les documents sont stockés en privé : on échange ici chaque clé contre une
 * URL signée à durée limitée, générée à la demande pour l'admin connecté. Rien
 * n'est jamais servi depuis une URL publique.
 */
export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const marketplaceModule: MarketplaceModuleService = req.scope.resolve(MARKETPLACE_MODULE)
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const fileService = req.scope.resolve(Modules.FILE)

  const [verification] = await marketplaceModule.listVendorVerifications({ id: req.params.id })
  if (!verification) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Verification request not found")
  }

  const { data: [vendor] } = await query.graph({
    entity: "vendor",
    fields: [
      "id", "name", "handle", "logo", "email", "phone",
      "country", "city", "address", "business_type",
      "is_verified", "verified_at", "created_at",
      "admins.email", "admins.first_name", "admins.last_name",
    ],
    filters: { id: (verification as any).vendor_id },
  })

  const documents = await Promise.all(
    ((verification as any).documents || []).map(async (doc: any) => {
      try {
        const file = await fileService.retrieveFile(doc.file_id)
        return { kind: doc.kind, filename: doc.filename, url: file.url }
      } catch (err) {
        // Fichier supprimé côté stockage : on affiche la ligne sans lien
        // plutôt que de faire échouer toute la revue.
        console.error(`Failed to sign verification document ${doc.file_id}:`, err)
        return { kind: doc.kind, filename: doc.filename, url: null }
      }
    })
  )

  res.json({
    vendor_verification: {
      id: (verification as any).id,
      status: (verification as any).status,
      legal_name: (verification as any).legal_name,
      id_document_type: (verification as any).id_document_type,
      id_document_number: (verification as any).id_document_number,
      registration_number: (verification as any).registration_number,
      tax_id: (verification as any).tax_id,
      contact_phone: (verification as any).contact_phone,
      contact_address: (verification as any).contact_address,
      rejection_reason: (verification as any).rejection_reason,
      submitted_at: (verification as any).created_at,
      reviewed_at: (verification as any).reviewed_at,
      reviewed_by: (verification as any).reviewed_by,
      documents,
      vendor,
    },
  })
}
