import { z } from "@medusajs/framework/zod"
import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { Modules, MedusaError } from "@medusajs/framework/utils"
import { sendEmail, getVerifyEmailTemplate } from "../../../../../modules/notification-center/email-service"
import {
  generateVerificationCode,
  hashCode,
  VERIFICATION_CODE_TTL_SECONDS,
  RESEND_COOLDOWN_SECONDS,
} from "../../../../../modules/notification-center/email-verification"

export const PostRegisterResendSchema = z.object({
  email: z.string().email(),
}).strict()

type PostBody = z.infer<typeof PostRegisterResendSchema>

type OtpEntry = { hash: string; expires_at: string; last_sent_at: string }

const otpCacheKey = (email: string) => `register_otp:${email.toLowerCase()}`

export const POST = async (req: MedusaRequest<PostBody>, res: MedusaResponse) => {
  const email = req.validatedBody.email.trim().toLowerCase()
  const cache = req.scope.resolve(Modules.CACHE)

  const previous = await cache.get<OtpEntry>(otpCacheKey(email))
  if (previous && Date.now() - new Date(previous.last_sent_at).getTime() < RESEND_COOLDOWN_SECONDS * 1000) {
    throw new MedusaError(MedusaError.Types.NOT_ALLOWED, "Veuillez patienter avant de redemander un code.")
  }

  const code = generateVerificationCode()
  const entry: OtpEntry = {
    hash: hashCode(code),
    expires_at: new Date(Date.now() + VERIFICATION_CODE_TTL_SECONDS * 1000).toISOString(),
    last_sent_at: new Date().toISOString(),
  }
  await cache.set(otpCacheKey(email), entry, VERIFICATION_CODE_TTL_SECONDS)

  await sendEmail({
    to: email,
    subject: "Confirmez votre adresse email - East Market",
    html: getVerifyEmailTemplate(email, code),
  })

  res.json({ sent: true })
}
