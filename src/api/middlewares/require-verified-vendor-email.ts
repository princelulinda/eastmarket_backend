import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
  MedusaNextFunction,
} from "@medusajs/framework/http"
import { Modules } from "@medusajs/framework/utils"
import { vendorVerifiedCacheKey } from "../../modules/notification-center/email-verification"

type ProviderIdentity = {
  provider: string
  entity_id?: string
  user_metadata?: Record<string, any> | null
}

/** Providers dont l'email est déjà vérifié par le fournisseur d'identité. */
const TRUSTED_EMAIL_PROVIDERS = ["google", "google-onetap"]

async function getProviderIdentities(
  req: AuthenticatedMedusaRequest,
): Promise<ProviderIdentity[]> {
  const authIdentityId = req.auth_context?.auth_identity_id
  if (!authIdentityId) return []

  try {
    const authModule = req.scope.resolve(Modules.AUTH)
    const identity = await authModule.retrieveAuthIdentity(authIdentityId, {
      relations: ["provider_identities"],
    })
    return (identity?.provider_identities ?? []) as ProviderIdentity[]
  } catch (err) {
    console.error("Failed to resolve auth identity for vendor registration:", err)
    return []
  }
}

/**
 * Garde-fou posé sur POST /vendors : refuse la création d'une boutique tant
 * que l'email de l'admin n'a pas été confirmé via
 * /vendors/auth/register/{start,confirm}. Pendant de requireVerifiedEmail
 * côté client, avec deux contrôles supplémentaires :
 *
 *  - l'email de l'admin doit être celui de l'identité authentifiée, sinon on
 *    pourrait confirmer une adresse et en déclarer une autre ;
 *  - une identité Google est acceptée sans code, l'email étant déjà vérifié
 *    par le provider.
 */
export async function requireVerifiedVendorEmail(
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse,
  next: MedusaNextFunction,
) {
  const body = (req.validatedBody ?? req.body) as { admin?: { email?: string } } | undefined
  const email = body?.admin?.email?.trim().toLowerCase()

  // Corps invalide : laisse la validation Zod produire l'erreur.
  if (!email) return next()

  const providers = await getProviderIdentities(req)

  const trusted = providers.find(
    (p) =>
      TRUSTED_EMAIL_PROVIDERS.includes(p.provider) &&
      String(p.user_metadata?.email ?? "").toLowerCase() === email,
  )
  if (trusted) return next()

  const identityEmails = providers
    .map((p) =>
      String(p.user_metadata?.email ?? (p.provider === "emailpass" ? p.entity_id : "") ?? "").toLowerCase(),
    )
    .filter(Boolean)

  if (identityEmails.length > 0 && !identityEmails.includes(email)) {
    return res.status(400).json({
      message:
        "L'email de l'administrateur doit être celui utilisé lors de l'inscription.",
    })
  }

  const cache = req.scope.resolve(Modules.CACHE)
  const verified = await cache.get<boolean>(vendorVerifiedCacheKey(email))

  if (!verified) {
    return res.status(400).json({
      message:
        "Adresse email non vérifiée. Complétez l'étape de vérification avant de créer la boutique.",
    })
  }

  next()
}

/**
 * Garde-fou posé sur POST /vendors/admins : un admin vendeur ne peut enrôler
 * qu'une adresse dont quelqu'un a prouvé le contrôle via
 * /vendors/auth/register/{start,confirm}.
 *
 * Sans ce contrôle, un compte capable de traiter les commandes et de demander
 * des retraits pouvait être créé sur une adresse arbitraire, jamais confirmée
 * — alors que le chemin POST /vendors, lui, l'exige.
 *
 * Contrairement à requireVerifiedVendorEmail, on ne compare pas l'adresse à
 * l'identité authentifiée : ici l'invitant et l'invité sont deux personnes
 * différentes.
 */
export async function requireVerifiedInviteEmail(
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse,
  next: MedusaNextFunction,
) {
  const body = (req.validatedBody ?? req.body) as { email?: string } | undefined
  const email = body?.email?.trim().toLowerCase()

  // Corps invalide : laisse la validation Zod produire l'erreur.
  if (!email) return next()

  const cache = req.scope.resolve(Modules.CACHE)
  const verified = await cache.get<boolean>(vendorVerifiedCacheKey(email))

  if (!verified) {
    return res.status(400).json({
      message:
        "Adresse email non vérifiée. Faites confirmer cette adresse via le code envoyé par email avant d'ajouter l'administrateur.",
    })
  }

  next()
}
