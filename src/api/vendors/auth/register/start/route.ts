import { z } from "@medusajs/framework/zod"
import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { Modules, MedusaError } from "@medusajs/framework/utils"
import { sendEmail, getVerifyEmailTemplate } from "../../../../../modules/notification-center/email-service"
import { MARKETPLACE_MODULE } from "../../../../../modules/marketplace"
import {
  generateVerificationCode,
  hashCode,
  vendorOtpCacheKey,
  OtpCacheEntry,
  VERIFICATION_CODE_TTL_SECONDS,
  RESEND_COOLDOWN_SECONDS,
} from "../../../../../modules/notification-center/email-verification"

export const PostVendorRegisterStartSchema = z.object({
  email: z.string().email(),
}).strict()

type PostBody = z.infer<typeof PostVendorRegisterStartSchema>

/**
 * Étape 1 de l'inscription vendeur : envoi du code de confirmation.
 * Pendant de POST /store/auth/register/start côté client.
 */
export const POST = async (req: MedusaRequest<PostBody>, res: MedusaResponse) => {
  const email = req.validatedBody.email.trim().toLowerCase()
  const cache = req.scope.resolve(Modules.CACHE)
  const marketplaceModule: any = req.scope.resolve(MARKETPLACE_MODULE)

  const existing = await marketplaceModule.listVendorAdmins({ email })
  if (existing.length > 0) {
    throw new MedusaError(MedusaError.Types.NOT_ALLOWED, "Un compte vendeur existe déjà avec cet email.")
  }

  const previous = await cache.get<OtpCacheEntry>(vendorOtpCacheKey(email))
  if (previous && Date.now() - new Date(previous.last_sent_at).getTime() < RESEND_COOLDOWN_SECONDS * 1000) {
    throw new MedusaError(MedusaError.Types.NOT_ALLOWED, "Veuillez patienter avant de redemander un code.")
  }

  const code = generateVerificationCode()
  const entry: OtpCacheEntry = {
    hash: hashCode(code),
    expires_at: new Date(Date.now() + VERIFICATION_CODE_TTL_SECONDS * 1000).toISOString(),
    last_sent_at: new Date().toISOString(),
  }
  await cache.set(vendorOtpCacheKey(email), entry, VERIFICATION_CODE_TTL_SECONDS)

  await sendEmail({
    to: email,
    subject: "Confirmez votre adresse email - East Market",
    html: getVerifyEmailTemplate(email, code),
  })

  res.json({ sent: true })
}
