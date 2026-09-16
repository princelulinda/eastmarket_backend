import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import { computeOnboarding } from "../../onboarding"

/**
 * Progression de mise en route de la boutique connectée.
 * Alimente la bannière d'onboarding du dashboard vendeur.
 */
export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const onboarding = await computeOnboarding(req)

  if (!onboarding) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Vendor not found")
  }

  res.json({ onboarding })
}
