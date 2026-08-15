import {
  MedusaRequest,
  MedusaResponse,
  MedusaNextFunction,
} from "@medusajs/framework/http"
import { Modules } from "@medusajs/framework/utils"

const verifiedCacheKey = (email: string) => `register_verified:${email.toLowerCase()}`

/**
 * Garde-fou posé sur POST /store/customers (route par défaut de Medusa) :
 * refuse la création d'un profil client tant que l'email n'a pas été
 * confirmé via /store/auth/register/{start,confirm} (étape 2 de
 * l'inscription en 3 étapes). Laisse passer les autres flux (ex. Google,
 * qui vérifie déjà l'email lui-même) sans email dans le corps.
 */
export async function requireVerifiedEmail(
  req: MedusaRequest,
  res: MedusaResponse,
  next: MedusaNextFunction,
) {
  const email = (req.body as { email?: string } | undefined)?.email
  if (!email) return next()

  const cache = req.scope.resolve(Modules.CACHE)
  const verified = await cache.get<boolean>(verifiedCacheKey(email))

  if (!verified) {
    return res.status(400).json({
      message: "Adresse email non vérifiée. Complétez l'étape de vérification avant de créer le compte.",
    })
  }

  next()
}
