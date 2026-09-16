import { MedusaError } from "@medusajs/framework/utils"

/**
 * Sandbox default. Production lives at https://api.trustsend.africa/api/v1 — the two are
 * independent deployments, and a key from one is rejected by the other.
 */
export const TRUSTSEND_SANDBOX_URL = "https://sandbox-api.trustsend.africa/api/v1"

export interface TrustSendCredentials {
  /** Base URL, version included. */
  apiUrl: string
  /** Business API key: `ts_sandbox_…` in sandbox, `ts_live_…` in production. */
  apiKey: string
}

/** Credentials for callers outside the payment provider (store routes), straight from the env. */
export function trustSendCredentials(): TrustSendCredentials {
  return {
    apiUrl: process.env.TRUSTSEND_API_URL || TRUSTSEND_SANDBOX_URL,
    apiKey: process.env.TRUSTSEND_API_KEY || "",
  }
}

export async function trustSendRequest(
  credentials: TrustSendCredentials,
  endpoint: string,
  method: string,
  data?: unknown
) {
  const response = await fetch(`${credentials.apiUrl}${endpoint}`, {
    method,
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
      Authorization: `Bearer ${credentials.apiKey}`,
    },
    body: data ? JSON.stringify(data) : undefined,
  })

  const body = await response.json().catch(() => ({}))

  if (!response.ok) {
    console.error("[TrustSend] API error", { endpoint, status: response.status, body })
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      body?.message || `TrustSend API error: ${response.status}`
    )
  }

  return body
}
