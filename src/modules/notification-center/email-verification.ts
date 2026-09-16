import crypto from "crypto"

const CODE_LENGTH = 6
const EXPIRY_MINUTES = 15
const RESEND_COOLDOWN_SECONDS = 30

export function generateVerificationCode(): string {
  return crypto.randomInt(0, 1_000_000).toString().padStart(CODE_LENGTH, "0")
}

export function hashCode(code: string): string {
  return crypto.createHash("sha256").update(code).digest("hex")
}

export const VERIFICATION_CODE_TTL_SECONDS = EXPIRY_MINUTES * 60
export { RESEND_COOLDOWN_SECONDS }

/** Vrai si le hash + l'expiration correspondent au code soumis. Partagé entre
 * le flux post-inscription (metadata client) et le flux pré-inscription (cache). */
export function codeMatches(hash: string, expiresAt: string | number, submittedCode: string): boolean {
  if (new Date(expiresAt).getTime() < Date.now()) return false
  return hashCode(submittedCode) === hash
}

export type VerificationMetadata = {
  email_verified?: boolean
  verification_code_hash?: string | null
  verification_code_expires_at?: string | null
  verification_last_sent_at?: string | null
}

/** Nouveau code + métadonnées à écrire sur customer.metadata (hash uniquement, jamais le code en clair). */
export function buildVerificationMetadata(code: string): VerificationMetadata {
  return {
    email_verified: false,
    verification_code_hash: hashCode(code),
    verification_code_expires_at: new Date(Date.now() + EXPIRY_MINUTES * 60 * 1000).toISOString(),
    verification_last_sent_at: new Date().toISOString(),
  }
}

export function canResend(metadata: VerificationMetadata | null | undefined): boolean {
  const lastSent = metadata?.verification_last_sent_at
  if (!lastSent) return true
  return Date.now() - new Date(lastSent).getTime() > RESEND_COOLDOWN_SECONDS * 1000
}

export function checkVerificationCode(
  metadata: VerificationMetadata | null | undefined,
  code: string
): { valid: true } | { valid: false; reason: "no_pending_code" | "expired" | "mismatch" } {
  if (!metadata?.verification_code_hash || !metadata?.verification_code_expires_at) {
    return { valid: false, reason: "no_pending_code" }
  }
  if (new Date(metadata.verification_code_expires_at).getTime() < Date.now()) {
    return { valid: false, reason: "expired" }
  }
  if (hashCode(code) !== metadata.verification_code_hash) {
    return { valid: false, reason: "mismatch" }
  }
  return { valid: true }
}

// ── Flux d'inscription vendeur (pré-inscription, stocké en cache) ───────

/** Entrée OTP conservée en cache pendant l'inscription (jamais le code en clair). */
export type OtpCacheEntry = {
  hash: string
  expires_at: string
  last_sent_at: string
}

/** Code en attente de confirmation pour un email vendeur. */
export const vendorOtpCacheKey = (email: string) =>
  `vendor_register_otp:${email.toLowerCase()}`

/** Ticket "email vendeur vérifié", consommé par POST /vendors. */
export const vendorVerifiedCacheKey = (email: string) =>
  `vendor_register_verified:${email.toLowerCase()}`

/** TTL du ticket "email vérifié" — le temps de finir la création de la boutique. */
export const VERIFIED_TICKET_TTL_SECONDS = 30 * 60
