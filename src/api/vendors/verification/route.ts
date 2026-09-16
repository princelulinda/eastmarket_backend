import { z } from "@medusajs/framework/zod"
import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { MedusaError, Modules } from "@medusajs/framework/utils"
import { MARKETPLACE_MODULE } from "../../../modules/marketplace"
import MarketplaceModuleService from "../../../modules/marketplace/service"
import { requireVendorContext } from "../vendor-context"

/** Pièces acceptées. `id_back` est inutile pour un passeport, d'où l'optionnalité. */
const DOCUMENT_KINDS = ["id_front", "id_back", "registration", "proof_of_address"] as const

const DocumentSchema = z.object({
  kind: z.enum(DOCUMENT_KINDS),
  file_id: z.string().min(1),
  filename: z.string().min(1),
}).strict()

export const PostVendorVerificationSchema = z.object({
  legal_name: z.string().min(2),
  id_document_type: z.enum(["national_id", "passport", "driver_license"]),
  id_document_number: z.string().min(3),
  registration_number: z.string().min(1).optional(),
  tax_id: z.string().min(1).optional(),
  contact_phone: z.string().min(6),
  contact_address: z.string().min(5),
  documents: z.array(DocumentSchema).min(1),
}).strict()

type PostBody = z.infer<typeof PostVendorVerificationSchema>

/** Vue renvoyée au vendeur : jamais les identifiants de fichiers ni le n° de pièce. */
function toVendorView(verification: any) {
  if (!verification) return null
  return {
    id: verification.id,
    status: verification.status,
    legal_name: verification.legal_name,
    rejection_reason: verification.rejection_reason,
    submitted_at: verification.created_at,
    reviewed_at: verification.reviewed_at,
    documents: (verification.documents || []).map((d: any) => ({
      kind: d.kind,
      filename: d.filename,
    })),
  }
}

/** Dossier le plus récent du vendeur, ou null. */
async function getLatestVerification(
  marketplaceModule: MarketplaceModuleService,
  vendorId: string,
) {
  const rows = await marketplaceModule.listVendorVerifications(
    { vendor_id: vendorId },
    { order: { created_at: "DESC" }, take: 1 },
  )
  return rows[0] ?? null
}

/**
 * État du dossier de vérification de la boutique connectée. Alimente l'écran
 * « Vérifiez votre boutique » du dashboard vendeur : tant que `is_verified`
 * est faux, les nouveaux produits partent en brouillon (voir
 * middlewares/require-approved-vendor.ts).
 */
export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const vendor = await requireVendorContext(req)
  const marketplaceModule: MarketplaceModuleService = req.scope.resolve(MARKETPLACE_MODULE)

  const verification = await getLatestVerification(marketplaceModule, vendor.id)

  res.json({
    is_verified: vendor.is_verified,
    verified_at: vendor.verified_at,
    verification: toVendorView(verification),
  })
}

/**
 * Soumission (ou re-soumission après refus) du dossier KYC.
 * Une re-soumission crée une nouvelle ligne : l'historique de revue est conservé.
 */
export const POST = async (req: AuthenticatedMedusaRequest<PostBody>, res: MedusaResponse) => {
  const vendor = await requireVendorContext(req)
  const marketplaceModule: MarketplaceModuleService = req.scope.resolve(MARKETPLACE_MODULE)
  const body = req.validatedBody

  if (vendor.is_verified) {
    throw new MedusaError(
      MedusaError.Types.NOT_ALLOWED,
      "Cette boutique est déjà vérifiée.",
    )
  }

  const latest = await getLatestVerification(marketplaceModule, vendor.id)
  if (latest?.status === "pending") {
    throw new MedusaError(
      MedusaError.Types.NOT_ALLOWED,
      "Un dossier est déjà en cours d'examen. Vous serez notifié dès qu'il sera traité.",
    )
  }

  const kinds = new Set(body.documents.map((d) => d.kind))
  if (!kinds.has("id_front")) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "La photo recto de votre pièce d'identité est obligatoire.",
    )
  }
  if (body.registration_number && !kinds.has("registration")) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Joignez le document d'immatriculation correspondant au numéro fourni.",
    )
  }

  const verification: any = await marketplaceModule.createVendorVerifications({
    vendor_id: vendor.id,
    status: "pending",
    legal_name: body.legal_name,
    id_document_type: body.id_document_type,
    id_document_number: body.id_document_number,
    registration_number: body.registration_number ?? null,
    tax_id: body.tax_id ?? null,
    contact_phone: body.contact_phone,
    contact_address: body.contact_address,
    documents: body.documents,
  } as any)

  const eventBus = req.scope.resolve(Modules.EVENT_BUS)
  await eventBus.emit({
    name: "vendor.verification_submitted",
    data: { id: verification.id, vendor_id: vendor.id },
  })

  res.status(201).json({ verification: toVendorView(verification) })
}
