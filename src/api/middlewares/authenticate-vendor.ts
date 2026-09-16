import {
  authenticate,
  MedusaRequest,
  MedusaResponse,
  MedusaNextFunction,
} from "@medusajs/framework/http"

/**
 * Routes sous /vendors accessibles sans être authentifié : les étapes
 * d'inscription (envoi / validation du code de confirmation) précèdent
 * forcément l'existence du compte vendeur.
 */
const VENDOR_PUBLIC_PATHS = [
  "/vendors/auth/register/start",
  "/vendors/auth/register/confirm",
  "/vendors/auth/register/resend",
]

const authenticateVendor = authenticate("vendor", ["session", "bearer"])

/**
 * Variante de authenticate("vendor") posée sur le wildcard /vendors/* :
 * laisse passer les routes d'inscription publiques, authentifie tout le reste.
 */
export function authenticateVendorExceptPublic(
  req: MedusaRequest,
  res: MedusaResponse,
  next: MedusaNextFunction,
) {
  // originalUrl et pas path : sur un middleware monté, req.url est relatif au point de montage.
  const path = (req.originalUrl || req.path || "").split("?")[0].replace(/\/+$/, "")

  if (VENDOR_PUBLIC_PATHS.some((p) => path === p || path.endsWith(p))) {
    return next()
  }

  return authenticateVendor(req, res, next)
}
