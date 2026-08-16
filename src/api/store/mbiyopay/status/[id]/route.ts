import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"

/**
 * Lets the storefront poll for a payment collection's session status while
 * it waits for the customer to confirm the MBIYOPAY push on their phone —
 * the collection completes asynchronously via the /hooks/mbiyopay webhook,
 * so the storefront can't just call complete-vendor right after creating
 * the session.
 */
export async function GET(req: MedusaRequest, res: MedusaResponse) {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { id } = req.params

  const { data: [collection] } = await query.graph({
    entity: "payment_collection",
    fields: [
      "id",
      "status",
      "payment_sessions.id",
      "payment_sessions.status",
      "payment_sessions.provider_id",
    ],
    filters: { id },
  })

  if (!collection) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Payment collection not found")
  }

  const sessions = (collection as any).payment_sessions || []
  const session =
    sessions.find((s: any) => s.provider_id === "pp_mbiyopay_mbiyopay") || sessions[0]

  return res.status(200).json({
    status: session?.status || collection.status,
  })
}
