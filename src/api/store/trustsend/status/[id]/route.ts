import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"

const TRUSTSEND_PROVIDER_ID = "pp_trustsend_trustsend"

/**
 * Lets the storefront poll a payment collection while the payer confirms the TrustSend push on
 * their phone. The deposit is asynchronous: the session only turns `authorized` once the webhook
 * arrives (src/api/hooks/trustsend/route.ts) or once the session is re-read from TrustSend, so
 * the cart cannot be completed right after the session is created.
 *
 * GET /store/trustsend/status/:payment_collection_id
 */
export async function GET(req: MedusaRequest, res: MedusaResponse) {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { id } = req.params

  const {
    data: [collection],
  } = await query.graph({
    entity: "payment_collection",
    fields: [
      "id",
      "status",
      "payment_sessions.id",
      "payment_sessions.status",
      "payment_sessions.provider_id",
      "payment_sessions.data",
    ],
    filters: { id },
  })

  if (!collection) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Payment collection not found")
  }

  const sessions = (collection as any).payment_sessions || []
  const session = sessions.find((s: any) => s.provider_id === TRUSTSEND_PROVIDER_ID) || sessions[0]

  return res.status(200).json({
    status: session?.status || collection.status,
    deposit_id: session?.data?.deposit_id ?? null,
    // Instructions the payer may have to follow (USSD steps, quick link); null when none.
    authorization: session?.data?.authorization ?? null,
  })
}
