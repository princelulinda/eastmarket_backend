import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { trustSendCredentials, trustSendRequest } from "../../../../modules/trustsend/client"

/**
 * Mobile money operators the storefront can offer for a currency, with the code to send as
 * `provider` when the payment session is created. Proxied rather than called from the browser:
 * the TrustSend key is a server credential and must never reach the storefront.
 *
 * GET /store/trustsend/payment-methods?currency_code=CDF&operation_type=DEPOSIT
 */
export async function GET(req: MedusaRequest, res: MedusaResponse) {
  const currencyCode = (req.query.currency_code as string | undefined)?.toUpperCase()
  const operationType = (req.query.operation_type as string | undefined)?.toUpperCase() || "DEPOSIT"

  if (!currencyCode || currencyCode.length !== 3) {
    return res.status(400).json({
      error: "Le paramètre 'currency_code' est requis (code ISO 4217, par exemple CDF)",
    })
  }

  if (operationType !== "DEPOSIT" && operationType !== "PAYOUT") {
    return res.status(400).json({ error: "'operation_type' doit valoir DEPOSIT ou PAYOUT" })
  }

  try {
    const response = await trustSendRequest(
      trustSendCredentials(),
      `/business/mobile-money/payment-methods?currency_code=${currencyCode}&operation_type=${operationType}`,
      "GET"
    )

    // What a payer needs to pick an operator and pay. An operator that is not OPERATIONAL is
    // kept, with its status, so the storefront can show it as temporarily unavailable rather
    // than making it vanish from the list.
    const methods = (response?.data ?? []).map((method: any) => ({
      provider: method.provider,
      display_name: method.display_name,
      status: method.status,
      // Bounds in hundredths of the currency, the same unit the deposit is sent in.
      min_amount: method.min_amount,
      max_amount: method.max_amount,
      logo: method.logo,
      flag: method.flag,
      country: method.country,
      country_name: method.country_name,
      phone_prefix: method.phone_prefix,
      currency_symbol: method.currency_symbol,
      // Confirmation steps for this operator (USSD, quick link), in en and fr.
      authorization: method.authorization ?? null,
    }))

    return res.status(200).json({ currency_code: currencyCode, payment_methods: methods })
  } catch (error) {
    const logger = req.scope.resolve("logger")
    logger.error(`[TrustSend] payment-methods failed for ${currencyCode}: ${error}`)

    return res.status(502).json({ error: "Moyens de paiement mobile money indisponibles" })
  }
}
