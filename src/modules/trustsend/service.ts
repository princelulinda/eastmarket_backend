import {
  AbstractPaymentProvider,
  PaymentSessionStatus,
  PaymentActions,
  MedusaError,
} from "@medusajs/framework/utils"
import type {
  InitiatePaymentInput,
  InitiatePaymentOutput,
  AuthorizePaymentInput,
  AuthorizePaymentOutput,
  GetPaymentStatusInput,
  GetPaymentStatusOutput,
  CapturePaymentInput,
  CapturePaymentOutput,
  CancelPaymentInput,
  CancelPaymentOutput,
  RefundPaymentInput,
  RefundPaymentOutput,
  UpdatePaymentInput,
  UpdatePaymentOutput,
  RetrievePaymentInput,
  RetrievePaymentOutput,
  DeletePaymentInput,
  DeletePaymentOutput,
  CreateAccountHolderInput,
  CreateAccountHolderOutput,
  RetrieveAccountHolderInput,
  RetrieveAccountHolderOutput,
  DeleteAccountHolderInput,
  DeleteAccountHolderOutput,
  ProviderWebhookPayload,
  WebhookActionResult,
} from "@medusajs/framework/types"
import crypto from "crypto"
import {
  TRUSTSEND_SANDBOX_URL,
  trustSendRequest,
  type TrustSendCredentials,
} from "./client"

export interface TrustSendOptions extends Record<string, unknown>, TrustSendCredentials {
  /**
   * Unité dans laquelle Medusa passe les montants à ce provider.
   *
   * - `"major"` (défaut) — la convention documentée de Medusa v2 : `10.5` vaut 10,50 USD.
   *   Le montant est multiplié par 100 pour TrustSend, qui compte en centièmes.
   * - `"minor"` — la boutique enregistre déjà ses prix en centièmes. C'est le cas d'East Market
   *   (table `price` : `2020` s'affiche « 20,20 $ », et `formatAmount()` du storefront divise
   *   par 100). Le montant est alors transmis tel quel : c'est déjà l'unité de TrustSend.
   *
   * Se tromper ici facture 100 fois trop ou 100 fois trop peu — d'où un réglage explicite
   * plutôt qu'une détection automatique.
   */
  amountUnit?: "major" | "minor"
}

/** The three states a TrustSend deposit can be in (docs: Dépôts & retraits). */
export type TrustSendStatus = "processing" | "completed" | "failed"

function normalizeStatus(status: unknown): TrustSendStatus {
  const s = String(status || "").toLowerCase()
  if (s === "completed") return "completed"
  if (s === "failed") return "failed"
  return "processing"
}

/**
 * Mobile money payments through TrustSend (trustsend.africa).
 *
 * A payment session initiates a *deposit*: TrustSend pushes the charge to the payer's mobile
 * money account and credits the business wallet once the payer confirms. The API answers 202
 * immediately with a `processing` transaction, so the session only becomes authorized later —
 * either through the webhook handled in `src/api/hooks/trustsend/route.ts`, or through this
 * provider polling the deposit (getPaymentStatus below), whichever happens first.
 */
class TrustSendService extends AbstractPaymentProvider<TrustSendOptions> {
  static identifier = "trustsend"
  protected options_: TrustSendOptions

  constructor(container: any, options?: TrustSendOptions) {
    super(container, options as TrustSendOptions)
    this.options_ = {
      apiUrl: options?.apiUrl || process.env.TRUSTSEND_API_URL || TRUSTSEND_SANDBOX_URL,
      apiKey: options?.apiKey || process.env.TRUSTSEND_API_KEY || "",
      amountUnit: options?.amountUnit ?? "major",
    }
  }

  /**
   * TrustSend prend les montants en centièmes de la devise, sous forme d'entier positif sans
   * zéro initial — y compris pour les devises écrites sans décimales, où la valeur doit tomber
   * sur un multiple de 100. L'unité d'entrée dépend de la boutique, voir `amountUnit`.
   */
  private toHundredths(amount: unknown): string {
    const value = Number(amount)

    if (!Number.isFinite(value) || value <= 0) {
      throw new MedusaError(MedusaError.Types.INVALID_DATA, `TrustSend: invalid amount ${amount}`)
    }

    const hundredths = Math.round(this.options_.amountUnit === "minor" ? value : value * 100)

    if (hundredths <= 0) {
      throw new MedusaError(
        MedusaError.Types.INVALID_DATA,
        `TrustSend: amount ${amount} rounds to zero in hundredths of the currency`
      )
    }

    return String(hundredths)
  }

  /** MSISDN as TrustSend wants it: digits only, no `+`, no leading zero. */
  private toMsisdn(phone: unknown): string {
    const digits = String(phone ?? "").replace(/\D/g, "").replace(/^0+/, "")

    if (digits.length < 8 || digits.length > 15) {
      throw new MedusaError(
        MedusaError.Types.INVALID_DATA,
        "TrustSend: phone_number must be an international MSISDN of 8 to 15 digits, without the leading +"
      )
    }

    return digits
  }

  public async trustSendRequest(endpoint: string, method: string, data?: any) {
    return trustSendRequest(this.options_, endpoint, method, data)
  }

  /**
   * Collects what the storefront put on the payment session. `provider` is a TrustSend operator
   * code (`VODACOM_MPESA_COD`, …) listed by GET /store/trustsend/payment-methods — `network` and
   * `provider_code` are accepted as aliases so a storefront written for another gateway keeps working.
   */
  private depositPayload(input: InitiatePaymentInput | UpdatePaymentInput) {
    const ctx = (input.context || {}) as any
    const data = (input.data || {}) as any

    const currencyCode = String(input.currency_code).toUpperCase()
    const provider = data.provider || data.provider_code || data.network || ctx.provider
    const countryCode = data.country_code || ctx.country_code

    if (!provider) {
      throw new MedusaError(
        MedusaError.Types.INVALID_DATA,
        "TrustSend: a `provider` (mobile money operator code) is required on the payment session"
      )
    }

    return {
      amount: this.toHundredths(input.amount),
      currency_code: currencyCode,
      phone_number: this.toMsisdn(data.phone_number || ctx.phone_number),
      provider: String(provider).toUpperCase(),
      // Expected by the request format, never checked for an API-key call (docs: Dépôts & retraits).
      pin: "0000",
      // A fresh key per attempt: replaying one returns the first response instead of charging twice.
      idempotency_key: crypto.randomUUID(),
      ...(countryCode ? { country_code: String(countryCode).toUpperCase() } : {}),
    }
  }

  async initiatePayment(input: InitiatePaymentInput): Promise<InitiatePaymentOutput> {
    // Medusa writes the payment session id into input.data right before calling this.
    const sessionId = (input.data as any)?.session_id as string | undefined
    const payload = this.depositPayload(input)

    const response = await this.trustSendRequest("/business/mobile-money/deposits", "POST", payload)
    const deposit = response?.data ?? {}

    if (!deposit.deposit_id) {
      throw new MedusaError(
        MedusaError.Types.UNEXPECTED_STATE,
        "TrustSend: deposit accepted but no deposit_id returned"
      )
    }

    return {
      id: String(deposit.deposit_id),
      data: {
        deposit_id: String(deposit.deposit_id),
        session_id: sessionId,
        status: normalizeStatus(deposit.status),
        // What the payer must do to confirm (USSD steps, quick link) — null when nothing is needed.
        authorization: deposit.authorization ?? null,
        created_at: deposit.created_at,
        phone_number: payload.phone_number,
        provider: payload.provider,
      },
    }
  }

  async authorizePayment(input: AuthorizePaymentInput): Promise<AuthorizePaymentOutput> {
    const { status } = await this.getPaymentStatus({ data: input.data })

    return { data: input.data, status }
  }

  /**
   * Reads the deposit TrustSend recorded, and — while it is still `processing` — asks the
   * payment network directly, which also settles the transaction on TrustSend's side when a
   * final status comes back. That call is idempotent, it never credits twice.
   */
  async getPaymentStatus(input: GetPaymentStatusInput): Promise<GetPaymentStatusOutput> {
    const depositId = (input.data as any)?.deposit_id

    if (!depositId) {
      return { status: PaymentSessionStatus.PENDING }
    }

    try {
      const stored = await this.trustSendRequest(
        `/business/mobile-money/deposits/${depositId}`,
        "GET"
      )
      let status = normalizeStatus(stored?.data?.status)

      if (status === "processing") {
        const live = await this.trustSendRequest(
          `/business/mobile-money/deposits/${depositId}/live-status`,
          "GET"
        ).catch(() => null)

        if (live?.data) {
          status = normalizeStatus(live.data.local_status ?? live.data.live_status)
        }
      }

      if (status === "completed") {
        return { status: PaymentSessionStatus.AUTHORIZED, data: input.data }
      }
      if (status === "failed") {
        return { status: PaymentSessionStatus.ERROR, data: input.data }
      }

      return { status: PaymentSessionStatus.PENDING, data: input.data }
    } catch (error) {
      console.error("[TrustSend] status check failed", { depositId, error })
      return { status: PaymentSessionStatus.PENDING, data: input.data }
    }
  }

  /**
   * Nothing to call: a completed deposit has already moved the money into the business wallet,
   * there is no separate capture step on TrustSend.
   */
  async capturePayment(input: CapturePaymentInput): Promise<CapturePaymentOutput> {
    return { data: input.data }
  }

  /**
   * A deposit cannot be called back once the payer has been prompted — it simply expires if it
   * is never confirmed. Cancelling here only drops the Medusa session.
   */
  async cancelPayment(input: CancelPaymentInput): Promise<CancelPaymentOutput> {
    return { data: input.data }
  }

  /**
   * TrustSend has no refund endpoint for a deposit: money goes back to a customer through a
   * mobile money payout, which is a separate business decision (and a separate debit of the
   * wallet), so it is deliberately not triggered automatically from here.
   */
  async refundPayment(input: RefundPaymentInput): Promise<RefundPaymentOutput> {
    throw new MedusaError(
      MedusaError.Types.NOT_ALLOWED,
      "TrustSend: a mobile money deposit cannot be refunded through the payment API — issue a payout instead"
    )
  }

  /** The payer changed the amount, the operator or the phone number: start a new deposit. */
  async updatePayment(input: UpdatePaymentInput): Promise<UpdatePaymentOutput> {
    const sessionId = (input.data as any)?.session_id as string | undefined
    const payload = this.depositPayload(input)

    const response = await this.trustSendRequest("/business/mobile-money/deposits", "POST", payload)
    const deposit = response?.data ?? {}

    return {
      data: {
        deposit_id: deposit.deposit_id ? String(deposit.deposit_id) : undefined,
        session_id: sessionId,
        status: normalizeStatus(deposit.status),
        authorization: deposit.authorization ?? null,
        created_at: deposit.created_at,
        phone_number: payload.phone_number,
        provider: payload.provider,
      },
    }
  }

  async retrievePayment(input: RetrievePaymentInput): Promise<RetrievePaymentOutput> {
    const depositId = (input.data as any)?.deposit_id

    if (!depositId) {
      return { data: input.data }
    }

    const response = await this.trustSendRequest(
      `/business/mobile-money/deposits/${depositId}`,
      "GET"
    ).catch(() => null)

    return { data: { ...(input.data as any), ...(response?.data ?? {}) } }
  }

  async deletePayment(input: DeletePaymentInput): Promise<DeletePaymentOutput> {
    return { data: input.data }
  }

  /** TrustSend has no customer vault: the payer is identified by the phone number of each deposit. */
  async createAccountHolder(input: CreateAccountHolderInput): Promise<CreateAccountHolderOutput> {
    return {
      id: input.context?.customer?.id || `ts_holder_${Date.now()}`,
      data: { customer_id: input.context?.customer?.id },
    }
  }

  async retrieveAccountHolder(
    input: RetrieveAccountHolderInput
  ): Promise<RetrieveAccountHolderOutput> {
    return {
      id: input.context?.customer?.id || "unknown",
      data: { customer_id: input.context?.customer?.id },
    }
  }

  async deleteAccountHolder(input: DeleteAccountHolderInput): Promise<DeleteAccountHolderOutput> {
    return { data: {} }
  }

  /**
   * TrustSend's webhook carries its own transaction reference and nothing of ours, so the
   * payment session cannot be resolved from the payload alone — which is all Medusa's generic
   * /hooks/payment/:provider route gives a provider. The delivery is therefore handled by our
   * own route, `src/api/hooks/trustsend/route.ts`, where the session can be looked up by
   * deposit id. Anything reaching this method is ignored on purpose.
   */
  async getWebhookActionAndData(
    _webhookData: ProviderWebhookPayload["payload"]
  ): Promise<WebhookActionResult> {
    return { action: PaymentActions.NOT_SUPPORTED }
  }
}

export default TrustSendService
