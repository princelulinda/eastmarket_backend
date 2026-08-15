import { z } from "@medusajs/framework/zod"
import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { Modules, MedusaError } from "@medusajs/framework/utils"
import { codeMatches } from "../../../../../modules/notification-center/email-verification"

export const PostRegisterConfirmSchema = z.object({
  email: z.string().email(),
  code: z.string().min(4).max(6),
}).strict()

type PostBody = z.infer<typeof PostRegisterConfirmSchema>

type OtpEntry = { hash: string; expires_at: string; last_sent_at: string }

const otpCacheKey = (email: string) => `register_otp:${email.toLowerCase()}`
const verifiedCacheKey = (email: string) => `register_verified:${email.toLowerCase()}`

// TTL du ticket "email vérifié" — le temps de finir l'étape 3 (nom + mdp).
const VERIFIED_TICKET_TTL_SECONDS = 30 * 60

export const POST = async (req: MedusaRequest<PostBody>, res: MedusaResponse) => {
  const email = req.validatedBody.email.trim().toLowerCase()
  const cache = req.scope.resolve(Modules.CACHE)

  const entry = await cache.get<OtpEntry>(otpCacheKey(email))
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

  await cache.invalidate(otpCacheKey(email))
  await cache.set(verifiedCacheKey(email), true, VERIFIED_TICKET_TTL_SECONDS)

  res.json({ verified: true })
}
