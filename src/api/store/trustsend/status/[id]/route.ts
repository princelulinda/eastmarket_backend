import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError, Modules } from "@medusajs/framework/utils"
import {
  fetchDepositStatus,
  trustSendCredentials,
  type TrustSendDepositStatus,
} from "../../../../../modules/trustsend/client"

const TRUSTSEND_PROVIDER_ID = "pp_trustsend_trustsend"

/**
 * Lets the storefront poll a payment collection while the payer confirms the TrustSend push on
 * their phone. The deposit is asynchronous: the session is created `pending` and only becomes
 * `authorized` once the money has actually moved.
 *
 * While the session is still waiting, this route asks TrustSend where the deposit stands rather
 * than reporting whatever the webhook has managed to write. Reading the database alone would
 * leave three situations stuck on `pending` until the buyer gives up: a webhook delivery that
 * never arrives, a webhook subscription that is not configured, and a refused deposit — which
 * the webhook deliberately does not mark, because marking it would start a fresh deposit (see
 * src/api/hooks/trustsend/route.ts). It also lets a late confirmation still be picked up: the
 * buyer who confirms after the storefront stopped waiting gets their order on the next check
 * instead of paying a second time.
 *
 * GET /store/trustsend/status/:payment_collection_id
 */
export async function GET(req: MedusaRequest, res: MedusaResponse) {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const logger = req.scope.resolve("logger")
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

  const depositId = session?.data?.deposit_id ?? null
  let status: string = session?.status || collection.status
  let depositStatus: TrustSendDepositStatus | null = null

  if (depositId && status === "pending") {
    try {
      depositStatus = await fetchDepositStatus(trustSendCredentials(), String(depositId))

      if (depositStatus === "completed") {
        const paymentModule = req.scope.resolve(Modules.PAYMENT)

        try {
          await paymentModule.authorizePaymentSession(session.id, { deposit_id: depositId })
          status = "authorized"
        } catch (error) {
          // The webhook may have authorized the very same session a moment earlier. Rather than
          // announcing an authorization that did not happen here, stay on `pending`: the next
          // poll re-reads the session and sees the settled state.
          logger.warn(
            `[TrustSend] Could not authorize session ${session.id} from deposit ${depositId}: ${error}`
          )
        }
      } else if (depositStatus === "failed") {
        // Reported to the storefront, not written to the session: marking it would go through
        // updatePaymentSession, which starts a brand new deposit through updatePayment().
        status = "error"
      }
    } catch (error) {
      // A failed read must not break the poll — the storefront keeps the stored status and
      // tries again a few seconds later.
      logger.error(`[TrustSend] Status refresh failed for deposit ${depositId}: ${error}`)
    }
  }

  return res.status(200).json({
    status,
    deposit_id: depositId,
    /** Raw TrustSend state when it was read on this call, `null` when the session was not polled. */
    deposit_status: depositStatus,
    // Instructions the payer may have to follow (USSD steps, quick link); null when none.
    authorization: session?.data?.authorization ?? null,
  })
}
