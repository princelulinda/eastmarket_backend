import {
  AbstractPaymentProvider,
  PaymentSessionStatus,
  PaymentActions,
  MedusaError
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
  WebhookActionResult
} from "@medusajs/framework/types"
import crypto from "crypto"

export interface MbiyoPayOptions extends Record<string, unknown> {
  apiUrl: string;
  apiKey: string;
}

/** Normalises MBIYOPAY's transaction status strings (case + synonyms vary between endpoints). */
function normalizeStatus(status: unknown): "AUTHORIZED" | "FAILED" | "PENDING" {
  const s = String(status || "").toUpperCase()
  if (s === "SUCCESS" || s === "SUCCESSFUL" || s === "COMPLETED") return "AUTHORIZED"
  if (s === "FAILED" || s === "FAILURE" || s === "CANCELED" || s === "CANCELLED") return "FAILED"
  return "PENDING"
}

class MbiyoPayService extends AbstractPaymentProvider {
  static identifier = "mbiyopay"
  protected options_: MbiyoPayOptions

  constructor(container: any, options?: MbiyoPayOptions) {
    super(container, options)
    this.options_ = {
      apiUrl: options?.apiUrl || process.env.MBIYOPAY_API_URL || "https://dashboard.mbiyo.africa/api/v1/merchant",
      apiKey: options?.apiKey || process.env.MBIYOPAY_API_KEY || "",
    }
  }

  private callbackUrl() {
    // Medusa's own generic webhook route — NOT a custom one. It resolves the
    // provider by the URL segment ("mbiyopay") and routes the payload straight
    // into getWebhookActionAndData() below, with the raw body already preserved
    // for signature verification.
    const backendUrl = process.env.MEDUSA_BACKEND_URL || process.env.BACKEND_URL || ""
    return `${backendUrl}/hooks/payment/mbiyopay`
  }

  public async mbiyopayRequest(endpoint: string, method: string, data?: any) {
    const url = `${this.options_.apiUrl}${endpoint}`

    const response = await fetch(url, {
      method,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": `Bearer ${this.options_.apiKey}`,
      },
      body: data ? JSON.stringify(data) : undefined,
    })

    const body = await response.json().catch(() => ({}))

    if (!response.ok) {
      console.error("MbiyoPay API Error:", body)
      throw new MedusaError(
        MedusaError.Types.INVALID_DATA,
        body.message || `MbiyoPay API Error: ${response.status}`
      )
    }

    return body
  }

  async initiatePayment(input: InitiatePaymentInput): Promise<InitiatePaymentOutput> {
    // Medusa injects the *Medusa* payment session id into input.data.session_id
    // right before calling this method (see @medusajs/payment's createPaymentSession).
    // We send it to MBIYOPAY as order_id and echo it in metadata too, so that
    // whichever field their webhook actually round-trips, we can map it back to
    // the right session in getWebhookActionAndData() below.
    const sessionId = input.data?.session_id as string | undefined

    const payload = {
      amount: input.amount,
      currency: String(input.currency_code).toUpperCase(),
      payment_method: "mobile_money",
      order_id: sessionId || "unknown",
      callback_url: this.callbackUrl(),
      metadata: {
        phone_number: input.data?.phone_number,
        network: input.data?.network,
        country_code: input.data?.country_code,
        session_id: sessionId,
      },
    }

    const mbiyopayResponse = await this.mbiyopayRequest("/payin", "POST", payload)
    // The real transaction id lives nested under `.data`, not at the top level.
    const transactionId = mbiyopayResponse?.data?.transaction_id

    return {
      id: transactionId || `mbp_${Date.now()}`,
      data: {
        transaction_id: transactionId,
        session_id: sessionId,
        ...mbiyopayResponse,
      },
    }
  }

  async authorizePayment(input: AuthorizePaymentInput): Promise<AuthorizePaymentOutput> {
    const { status } = await this.getPaymentStatus({ data: input.data })

    return {
      data: input.data,
      status,
    }
  }

  async getPaymentStatus(input: GetPaymentStatusInput): Promise<GetPaymentStatusOutput> {
      console.log("ID???????");

    try {
      const transactionId = input.data?.transaction_id
      console.log(transactionId, "ID???????");
      
      if (!transactionId) {
        return { status: PaymentSessionStatus.PENDING }
      }

      const response = await this.mbiyopayRequest(`/transactions/${transactionId}`, "GET")
      const status = normalizeStatus(response?.data?.status || response?.status)
      console.log(status)

      if (status === "AUTHORIZED") {
        return { status: PaymentSessionStatus.AUTHORIZED }
      } else if (status === "FAILED") {
        return { status: PaymentSessionStatus.ERROR }
      }

      return { status: PaymentSessionStatus.PENDING }
    } catch (error) {
      return { status: PaymentSessionStatus.ERROR }
    }
  }

  async capturePayment(input: CapturePaymentInput): Promise<CapturePaymentOutput> {
    return {
      data: input.data
    }
  }

  async cancelPayment(input: CancelPaymentInput): Promise<CancelPaymentOutput> {
    return {
      data: input.data
    }
  }

  async refundPayment(input: RefundPaymentInput): Promise<RefundPaymentOutput> {
    return {
      data: input.data
    }
  }

  async updatePayment(input: UpdatePaymentInput): Promise<UpdatePaymentOutput> {
    const sessionId = (input.data?.session_id || input.context?.session_id) as string | undefined

    const payload = {
      amount: input.amount,
      currency: String(input.currency_code).toUpperCase(),
      payment_method: "mobile_money",
      order_id: sessionId || "unknown",
      callback_url: this.callbackUrl(),
      metadata: {
        phone_number: input.data?.phone_number || input.context?.phone_number,
        network: input.data?.network || input.context?.network,
        country_code: input.data?.country_code || input.context?.country_code,
        session_id: sessionId,
      },
    }

    const mbiyopayResponse = await this.mbiyopayRequest("/payin", "POST", payload)
    const transactionId = mbiyopayResponse?.data?.transaction_id

    return {
      data: {
        transaction_id: transactionId || `mbp_${Date.now()}`,
        session_id: sessionId,
        ...mbiyopayResponse,
      },
    }
  }

  async retrievePayment(input: RetrievePaymentInput): Promise<RetrievePaymentOutput> {
    return {
      data: input.data,
    }
  }

  async deletePayment(input: DeletePaymentInput): Promise<DeletePaymentOutput> {
    return {
      data: input.data,
    }
  }

  async createAccountHolder(input: CreateAccountHolderInput): Promise<CreateAccountHolderOutput> {
    return {
      id: input.context?.customer?.id || `mbp_holder_${Date.now()}`,
      data: {
        customer_id: input.context?.customer?.id,
      },
    }
  }

  async retrieveAccountHolder(input: RetrieveAccountHolderInput): Promise<RetrieveAccountHolderOutput> {
    return {
      id: input.context?.customer?.id || "unknown",
      data: {
        customer_id: input.context?.customer?.id,
      },
    }
  }

  async deleteAccountHolder(input: DeleteAccountHolderInput): Promise<DeleteAccountHolderOutput> {
    return {
      data: {},
    }
  }

  /**
   * MBIYOPAY signs every webhook with HMAC-SHA256 over the raw body, in the
   * `Signature` header. `rawData`/`headers` are only populated here because
   * Medusa's core /hooks/payment/:provider route registers this path with
   * bodyParser: { preserveRawBody: true } (see @medusajs/medusa's hooks
   * middlewares) — nothing extra to configure on our side.
   */
  private isValidWebhookSignature(webhookData: ProviderWebhookPayload["payload"]): boolean {
    const secret = process.env.MBIYOPAY_WEBHOOK_SECRET
    const rawBody = webhookData.rawData as Buffer | undefined
    const headers = webhookData.headers as Record<string, string | string[] | undefined> | undefined
    const signature = headers?.["signature"]

    if (!secret || !signature || !rawBody) {
      return false
    }

    const expected = crypto.createHmac("sha256", secret).update(rawBody).digest("hex")
    const expectedBuf = Buffer.from(expected, "utf8")
    const signatureBuf = Buffer.from(String(signature), "utf8")

    if (expectedBuf.length !== signatureBuf.length) {
      return false
    }

    return crypto.timingSafeEqual(expectedBuf, signatureBuf)
  }

  async getWebhookActionAndData(
    webhookData: ProviderWebhookPayload["payload"]
  ): Promise<WebhookActionResult> {
    if (!this.isValidWebhookSignature(webhookData)) {
      return { action: PaymentActions.NOT_SUPPORTED }
    }

    const body = webhookData.data as any
    // MBIYOPAY uses a flat shape for merchant payin/payout events and a
    // wrapped { event, data } shape for platform features — normalise both,
    // and tolerate the transaction details being nested under `.data` the way
    // the /payin response is (confirmed against a real sandbox response).
    const payload = body?.event && body?.data ? body.data : body
    const inner = payload?.data ?? payload

    // We sent our own session_id as both `order_id` and `metadata.session_id`
    // at initiation — recover whichever one comes back.
    const sessionId =
      payload?.order_id ||
      inner?.order_id ||
      payload?.metadata?.session_id ||
      inner?.metadata?.session_id

    if (!sessionId || sessionId === "unknown") {
      return { action: PaymentActions.NOT_SUPPORTED }
    }

    const status = normalizeStatus(payload?.status || inner?.status)
    const amount = Number(inner?.charged_amount ?? inner?.amount ?? payload?.amount ?? 0)

    if (status === "AUTHORIZED") {
      return {
        action: PaymentActions.AUTHORIZED,
        data: { session_id: String(sessionId), amount },
      }
    }

    if (status === "FAILED") {
      return { action: PaymentActions.FAILED }
    }

    return { action: PaymentActions.NOT_SUPPORTED }
  }
}

export default MbiyoPayService
