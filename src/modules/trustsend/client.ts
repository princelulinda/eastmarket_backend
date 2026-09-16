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

/** The three states a TrustSend deposit can be in (docs: Dépôts & retraits). */
export type TrustSendDepositStatus = "processing" | "completed" | "failed"

export function normalizeDepositStatus(status: unknown): TrustSendDepositStatus {
  const s = String(status || "").toLowerCase()
  if (s === "completed") return "completed"
  if (s === "failed") return "failed"
  return "processing"
}

/**
 * Reads the deposit TrustSend recorded, and — while it is still `processing` — asks the payment
 * network directly, which also settles the transaction on TrustSend's side when a final status
 * comes back. That call is idempotent, it never credits twice.
 *
 * Shared by the payment provider, which authorises a session from it, and by the store status
 * route the storefront polls, so the two can never disagree on what a deposit is doing.
 */
export async function fetchDepositStatus(
  credentials: TrustSendCredentials,
  depositId: string
): Promise<TrustSendDepositStatus> {
  const stored = await trustSendRequest(
    credentials,
    `/business/mobile-money/deposits/${depositId}`,
    "GET"
  )
  let status = normalizeDepositStatus(stored?.data?.status)

  if (status === "processing") {
    const live = await trustSendRequest(
      credentials,
      `/business/mobile-money/deposits/${depositId}/live-status`,
      "GET"
    ).catch(() => null)

    if (live?.data) {
      status = normalizeDepositStatus(live.data.local_status ?? live.data.live_status)
    }
  }

  return status
}
