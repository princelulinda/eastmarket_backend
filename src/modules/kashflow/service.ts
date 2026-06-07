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

export interface KashFlowOptions extends Record<string, unknown> {
  apiUrl: string;
  apiKey: string;
  secretKey:string;
}

class KashFlowPaymentService extends AbstractPaymentProvider {
  static identifier = "kashflow"
  protected options_: KashFlowOptions

  constructor(container: any, options?: KashFlowOptions) {
    super(container, options)
    // Fallback on env variables if options are missing from medusa-config.ts
    this.options_ = {
      apiUrl: options?.apiUrl || process.env.KASHFLOW_API_URL || "https://api.kashflow-service.com",
      apiKey: options?.apiKey || process.env.KASHFLOW_APP_KEY || "",
      secretKey:process.env.KASHFLOW_SECRET_KEY || ''
    }
  }

  public async kashflowRequest(endpoint: string, method: string, data?: any, isPublic = false) {
    const url = `${this.options_.apiUrl}/api/v1${endpoint}`
    
    const headers: Record<string, string> = {
      "Content-Type": "application/json",
    }

    if (!isPublic) {
      headers["X-API-Key"] = `${this.options_.apiKey}`
      headers["X-Secret"] = this.options_.secretKey
    }

    const response = await fetch(url, {
      method,
      headers,
      body: data ? JSON.stringify(data) : undefined,
    })

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}))
      console.error("KashFlow API Error:", errorData)
      throw new MedusaError(
        MedusaError.Types.INVALID_DATA,
        errorData.message || `API Error: ${response.status}`
      )
    }

    return await response.json()
  }

  async requestOtp(data: { mobile: string; payment_method: string }) {
    return await this.kashflowRequest("/payments/request-otp", "POST", data)
  }

  // 0. Configuration: Récupérer les devises et méthodes supportées (Public Access)
  async getSupportedCurrencies() {
    try {
      return await this.kashflowRequest("/currencies", "GET", undefined, true)
    } catch (e: any) {
      console.error("Erreur lors de la récupération des devises KashFlow:", e.message)
      return []

    }
  }

  async getPaymentMethods() {
    try {
      return await this.kashflowRequest("/payment-methods", "GET", undefined, true)
    } catch (e: any) {
      console.error("Erreur lors de la récupération des méthodes KashFlow:", e.message)
      return []
    }
  }
async initiatePayment(input: InitiatePaymentInput): Promise<InitiatePaymentOutput> {
  const payload = {
    amount: input.amount,
    currency: "bif",
    payment_method: input.data?.payment_method,
    initiator: input.data?.initiator,
    vendor_email: input.data?.vendor_email,
    otp: input.data?.otp,
    reference: input.context?.customer?.id || "unknown",
    app_reference: input.context?.order_id || input.context?.cart_id || "unknown",
  }

  const kashflowResponse = await this.kashflowRequest("/payments/initialize", "POST", payload)

  return {
    id: kashflowResponse.transaction_id || `kf_${Date.now()}`,
    data: {
      id: kashflowResponse.transaction_id,
      ...kashflowResponse,
    },
  }
}


  async authorizePayment(input: AuthorizePaymentInput): Promise<AuthorizePaymentOutput> {
    try {
      // Mobile money often stays pending until callback
      return {
        data: input.data,
        status: PaymentSessionStatus.PENDING,
      }
    } catch (e: any) {
      return {
        data: input.data,
        status: PaymentSessionStatus.ERROR,
      }
    }
  }

  async getPaymentStatus(input: GetPaymentStatusInput): Promise<GetPaymentStatusOutput> {
    try {
      const transactionId = input.data?.id;
      if (!transactionId) {
        return { status: PaymentSessionStatus.PENDING }
      }

      const response = await this.kashflowRequest(`/payments/${transactionId}/status`, "GET")

      if (response.status === "SUCCESS" || response.status === "COMPLETED") {
        return { status: PaymentSessionStatus.AUTHORIZED }
      } else if (response.status === "FAILED") {
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
    const payload = {
      amount: input.amount,
      currency: input.currency_code,
      payment_method: input.data?.payment_method || input.context?.payment_method,
      initiator: input.data?.initiator || input.context?.initiator,
      vendor_email: input.data?.vendor_email || input.context?.vendor_email,
      otp: input.data?.otp || input.context?.otp,
      reference: input.context?.customer?.id || "unknown",
      app_reference: input.context?.order_id || input.context?.cart_id || "unknown",
    }

    const kashflowResponse = await this.kashflowRequest("/payments/initialize", "POST", payload)

    return {
      data: {
        id: kashflowResponse.transaction_id || `kf_${Date.now()}`,
        ...kashflowResponse,
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
    // Pour KashFlow, nous retournons simplement un account holder basique
    // Vous pouvez l'étendre selon vos besoins
    return {
      id: input.context?.customer?.id || `kf_holder_${Date.now()}`,
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

  async getWebhookActionAndData(
    webhookData: ProviderWebhookPayload["payload"]
  ): Promise<WebhookActionResult> {
    // Handle KashFlow webhook data
    const data = webhookData.data

    // Check if payment was successful
    if (data.status === "SUCCESS" || data.status === "COMPLETED") {
      return {
        action: PaymentActions.AUTHORIZED,
        data: {
          session_id: String(data.transaction_id),
          amount: Number(data.amount),
        },
      }
    }

    return {
      action: PaymentActions.NOT_SUPPORTED,
    }
  }
}

export default KashFlowPaymentService
