import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { Modules } from "@medusajs/framework/utils"
import crypto from "crypto"

/** Full container key of the provider — `pp_{identifier}_{config id}`, both "trustsend". */
const TRUSTSEND_PROVIDER_ID = "pp_trustsend_trustsend"

/** How far back we look for the session a delivery belongs to (a deposit is confirmed in minutes). */
const LOOKUP_WINDOW_HOURS = 48

/**
 * Signature over the body *as received*: TrustSend signs the raw bytes, so a re-serialised JSON
 * would not match. `preserveRawBody` is switched on for this route in src/api/middlewares.ts.
 */
function hasValidSignature(req: MedusaRequest, secret: string): boolean {
  const rawBody = (req as any).rawBody as Buffer | string | undefined
  const received = req.get("x-webhook-signature")

  if (!rawBody || !received) {
    return false
  }

  const expected = crypto
    .createHmac("sha256", secret)
    .update(typeof rawBody === "string" ? Buffer.from(rawBody, "utf8") : rawBody)
    .digest("hex")

  const receivedBuf = Buffer.from(received, "utf8")
  const expectedBuf = Buffer.from(expected, "utf8")

  return (
    receivedBuf.length === expectedBuf.length && crypto.timingSafeEqual(receivedBuf, expectedBuf)
  )
}

/**
 * Receives TrustSend's mobile money webhooks.
 *
 * The payload carries TrustSend's own transaction reference and nothing of ours, so the payment
 * session is found by the deposit id we stored on it when the deposit was initiated (see
 * src/modules/trustsend/service.ts). This is also why the delivery cannot go through Medusa's
 * generic /hooks/payment/:provider route, which only hands the provider the payload.
 *
 * Register the URL with TrustSend:
 *   POST /api/v1/business/webhooks { "url": "{MEDUSA_BACKEND_URL}/hooks/trustsend",
 *     "events": ["mobile_money_deposit.completed", "mobile_money_deposit.failed"] }
 * and put the `secret` it returns in TRUSTSEND_WEBHOOK_SECRET — it is only shown once.
 */
export async function POST(req: MedusaRequest, res: MedusaResponse) {
  const logger = req.scope.resolve("logger")
  const secret = process.env.TRUSTSEND_WEBHOOK_SECRET

  if (!secret) {
    logger.error("[TrustSend Webhook] TRUSTSEND_WEBHOOK_SECRET is not set — delivery rejected")
    return res.status(401).json({ error: "Webhook secret not configured" })
  }

  if (!hasValidSignature(req, secret)) {
    logger.warn("[TrustSend Webhook] Rejected: X-Webhook-Signature missing or mismatched")
    return res.status(401).json({ error: "Invalid signature" })
  }

  const event = (req.body ?? {}) as {
    transaction_id?: string
    type?: string
    status?: string
  }
  const eventName = req.get("x-webhook-event") || `${event.type}.${event.status}`

  // Payouts are a business-side movement (vendor payouts), not a customer payment: ignore them
  // here rather than hunting for a session that cannot exist.
  if (event.type !== "mobile_money_deposit" || !event.transaction_id) {
    logger.info(`[TrustSend Webhook] Ignored event '${eventName}'`)
    return res.status(200).json({ received: true, ignored: true })
  }

  const paymentModule = req.scope.resolve(Modules.PAYMENT)

  const since = new Date(Date.now() - LOOKUP_WINDOW_HOURS * 60 * 60 * 1000).toISOString()
  const sessions = await paymentModule.listPaymentSessions(
    { provider_id: TRUSTSEND_PROVIDER_ID, created_at: { $gte: since } },
    { select: ["id", "status", "data"], take: 1000, order: { created_at: "DESC" } }
  )

  const session = sessions.find(
    (s: any) => String(s.data?.deposit_id ?? "") === String(event.transaction_id)
  )

  if (!session) {
    // Answer 2xx anyway: retrying would not make an unknown deposit appear, and a non-2xx
    // reply makes TrustSend retry the delivery for hours.
    logger.warn(
      `[TrustSend Webhook] No payment session found for deposit ${event.transaction_id} (${eventName})`
    )
    return res.status(200).json({ received: true, matched: false })
  }

  if (event.status === "completed") {
    if (session.status === "authorized" || session.status === "captured") {
      return res.status(200).json({ received: true, already_authorized: true })
    }

    try {
      await paymentModule.authorizePaymentSession(session.id, {
        deposit_id: event.transaction_id,
      })
      logger.info(
        `[TrustSend Webhook] Session ${session.id} authorized from deposit ${event.transaction_id}`
      )
    } catch (error) {
      // 500 so the delivery is retried: the deposit did succeed, the order must follow.
      logger.error(`[TrustSend Webhook] Failed to authorize session ${session.id}: ${error}`)
      return res.status(500).json({ error: "Failed to authorize payment" })
    }
  } else {
    // Nothing to mark: the session stays pending and the storefront sees the failure on its next
    // status poll, which re-reads the deposit from TrustSend. Marking it here would mean calling
    // updatePaymentSession, and that would start a brand new deposit through updatePayment().
    logger.warn(
      `[TrustSend Webhook] Deposit ${event.transaction_id} ${event.status} for session ${session.id}`
    )
  }

  return res.status(200).json({ received: true })
}
