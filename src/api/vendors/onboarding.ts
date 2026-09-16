import { AuthenticatedMedusaRequest } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { MARKETPLACE_MODULE } from "../../modules/marketplace"
import MarketplaceModuleService from "../../modules/marketplace/service"

export type OnboardingStep = {
  key: string
  label: string
  /** Pourquoi cette étape compte, à afficher sous le libellé. */
  hint: string
  done: boolean
  /** Vrai quand l'action est engagée mais pas encore aboutie (dossier KYC en cours). */
  pending?: boolean
  /** Route de l'app vendeur vers laquelle envoyer le vendeur. */
  cta: { label: string; path: string }
}

export type Onboarding = {
  completion: number
  completed_steps: number
  total_steps: number
  steps: OnboardingStep[]
  /** Première étape non faite — celle à mettre en avant. */
  next_step: OnboardingStep | null
}

/**
 * Progression de mise en route d'une boutique.
 *
 * Un tableau de bord vide ne dit pas au vendeur quoi faire ; cette checklist
 * transforme le démarrage en parcours et donne au front un pourcentage à
 * afficher. L'ordre des étapes est celui dans lequel elles ont du sens : on ne
 * demande pas de créer un produit avant d'avoir une boutique présentable.
 */
export async function computeOnboarding(
  req: AuthenticatedMedusaRequest,
): Promise<Onboarding | null> {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const marketplaceModule: MarketplaceModuleService = req.scope.resolve(MARKETPLACE_MODULE)

  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: [
      "vendor.id",
      "vendor.logo", "vendor.description",
      "vendor.phone", "vendor.city", "vendor.country",
      "vendor.opening_hours",
      "vendor.is_verified",
      "vendor.products.id", "vendor.products.status",
      "vendor.stock_locations.id",
    ],
    filters: { id: [req.auth_context.actor_id] },
  })

  const vendor = vendorAdmin?.vendor as any
  if (!vendor) return null

  // Un dossier en cours d'examen n'est pas un échec : l'étape est « engagée ».
  const verifications = await marketplaceModule.listVendorVerifications(
    { vendor_id: vendor.id },
    { order: { created_at: "DESC" }, take: 1 },
  )
  const latestVerification = verifications[0] as any

  const products = (vendor.products || []) as { id: string; status: string }[]

  const steps: OnboardingStep[] = [
    {
      key: "profile",
      label: "Habillez votre boutique",
      hint: "Un logo et une description : c'est ce que l'acheteur voit en premier.",
      done: Boolean(vendor.logo && vendor.description),
      cta: { label: "Compléter le profil", path: "/store/settings" },
    },
    {
      key: "contact",
      label: "Renseignez vos coordonnées",
      hint: "Téléphone et localisation rassurent l'acheteur et facilitent la livraison.",
      done: Boolean(vendor.phone && vendor.city && vendor.country),
      cta: { label: "Ajouter mes coordonnées", path: "/store/settings" },
    },
    {
      key: "opening_hours",
      label: "Indiquez vos horaires",
      hint: "L'acheteur sait quand vous êtes joignable, vous recevez moins de messages hors horaires.",
      done: Boolean(vendor.opening_hours),
      cta: { label: "Définir mes horaires", path: "/store/hours" },
    },
    {
      key: "verification",
      label: "Faites vérifier votre boutique",
      hint: vendor.is_verified
        ? "Votre boutique porte le badge « Vérifié »."
        : latestVerification?.status === "pending"
          ? "Votre dossier est en cours d'examen, réponse sous 48 h."
          : latestVerification?.status === "rejected"
            ? `Dossier à corriger : ${latestVerification.rejection_reason}`
            : "Sans vérification, vos produits restent en brouillon et n'apparaissent pas en vitrine.",
      done: Boolean(vendor.is_verified),
      pending: !vendor.is_verified && latestVerification?.status === "pending",
      cta: { label: "Envoyer mon dossier", path: "/store/verification" },
    },
    {
      key: "stock_location",
      label: "Créez un entrepôt",
      hint: "Sans lieu de stock, vous ne pouvez pas suivre vos quantités disponibles.",
      done: (vendor.stock_locations || []).length > 0,
      cta: { label: "Créer un entrepôt", path: "/store/locations" },
    },
    {
      key: "first_product",
      label: "Ajoutez votre premier produit",
      hint: "Une boutique sans produit n'apparaît nulle part dans le catalogue.",
      done: products.length > 0,
      cta: { label: "Créer un produit", path: "/add-product" },
    },
  ]

  const completedSteps = steps.filter((s) => s.done).length

  return {
    completion: Math.round((completedSteps / steps.length) * 100),
    completed_steps: completedSteps,
    total_steps: steps.length,
    steps,
    // Une étape engagée mais pas finie ne doit pas être proposée comme action :
    // le vendeur n'a rien à y faire tant que l'admin n'a pas tranché.
    next_step: steps.find((s) => !s.done && !s.pending) ?? null,
  }
}
