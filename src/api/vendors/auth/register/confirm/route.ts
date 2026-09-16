import { z } from "@medusajs/framework/zod"
import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { Modules, MedusaError } from "@medusajs/framework/utils"
import {
  codeMatches,
  vendorOtpCacheKey,
  vendorVerifiedCacheKey,
  OtpCacheEntry,
  VERIFIED_TICKET_TTL_SECONDS,
} from "../../../../../modules/notification-center/email-verification"

export const PostVendorRegisterConfirmSchema = z.object({
  email: z.string().email(),
  code: z.string().min(4).max(6),
}).strict()

type PostBody = z.infer<typeof PostVendorRegisterConfirmSchema>

/**
 * Étape 2 de l'inscription vendeur : validation du code. Pose le ticket
 * consommé par le garde-fou de POST /vendors (création de la boutique).
 */
export const POST = async (req: MedusaRequest<PostBody>, res: MedusaResponse) => {
  const email = req.validatedBody.email.trim().toLowerCase()
  const cache = req.scope.resolve(Modules.CACHE)

  const entry = await cache.get<OtpCacheEntry>(vendorOtpCacheKey(email))
  if (!entry) {
    throw new MedusaError(MedusaError.Types.INVALID_DATA, "Aucune vérification en attente. Demandez un nouveau code.")
  }
  if (!codeMatches(entry.hash, entry.expires_at, req.validatedBody.code.trim())) {
    const expired = new Date(entry.expires_at).getTime() < Date.now()
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      expired ? "Ce code a expiré. Demandez un nouveau code." : "Code incorrect.",
    )
  }

  await cache.invalidate(vendorOtpCacheKey(email))
  await cache.set(vendorVerifiedCacheKey(email), true, VERIFIED_TICKET_TTL_SECONDS)

  res.json({ verified: true })
}
