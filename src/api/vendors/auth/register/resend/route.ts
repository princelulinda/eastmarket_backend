import { z } from "@medusajs/framework/zod"
import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { Modules, MedusaError } from "@medusajs/framework/utils"
import { sendEmail, getVerifyEmailTemplate } from "../../../../../modules/notification-center/email-service"
import {
  generateVerificationCode,
  hashCode,
  vendorOtpCacheKey,
  OtpCacheEntry,
  VERIFICATION_CODE_TTL_SECONDS,
  RESEND_COOLDOWN_SECONDS,
} from "../../../../../modules/notification-center/email-verification"

export const PostVendorRegisterResendSchema = z.object({
  email: z.string().email(),
}).strict()

type PostBody = z.infer<typeof PostVendorRegisterResendSchema>

/** Renvoi du code de l'étape 1, soumis au même cooldown. */
export const POST = async (req: MedusaRequest<PostBody>, res: MedusaResponse) => {
  const email = req.validatedBody.email.trim().toLowerCase()
  const cache = req.scope.resolve(Modules.CACHE)

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
