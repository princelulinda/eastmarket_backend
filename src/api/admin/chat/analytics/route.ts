import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { CHAT_MODULE } from "../../../../modules/chat"
import ChatModuleService from "../../../../modules/chat/service"
import { LOYALTY_MODULE } from "../../../../modules/loyalty"

const HOUR_MS = 60 * 60 * 1000
const DAY_MS = 24 * HOUR_MS

/**
 * Métriques d'engagement du chat, calculées à la demande depuis les messages
 * (les messages sont le journal d'événements — pas de table dédiée).
 */
export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const chatService: ChatModuleService = req.scope.resolve(CHAT_MODULE)
  const now = Date.now()

  const conversations = await chatService.listConversations({}, { take: null } as any)
  const direct = conversations.filter((c: any) => c.type !== "broadcast")

  let answered = 0
  let answeredWithinHour = 0
  const firstResponseDelays: number[] = []
  let messagesLast7d = 0
  let activeConversationsLast7d = 0

  for (const conv of direct) {
    const messages = await chatService.listMessages(
      { conversation_id: conv.id } as any,
      { take: 200, order: { created_at: "ASC" } } as any
    )

    const recent = messages.filter(
      (m: any) => now - new Date(m.created_at).getTime() < 7 * DAY_MS
    )
    messagesLast7d += recent.length
    if (recent.length > 0) activeConversationsLast7d += 1

    const firstCustomerMsg = messages.find((m: any) => m.sender_type === "customer")
    if (!firstCustomerMsg) continue

    const firstVendorReply = messages.find(
      (m: any) =>
        m.sender_type === "vendor" &&
        !["order_update", "system", "flash_sale"].includes(m.type) &&
        new Date(m.created_at) > new Date(firstCustomerMsg.created_at)
    )
    if (firstVendorReply) {
      answered += 1
      const delay =
        new Date(firstVendorReply.created_at).getTime() -
        new Date(firstCustomerMsg.created_at).getTime()
      firstResponseDelays.push(delay)
      if (delay < HOUR_MS) answeredWithinHour += 1
    }
  }

  const sortedDelays = [...firstResponseDelays].sort((a, b) => a - b)
  const medianDelayMs =
    sortedDelays.length > 0 ? sortedDelays[Math.floor(sortedDelays.length / 2)] : null

  // Conversion chat → commande : transactions loyalty "chat_engagement"
  // liées à une commande (attribuées quand une commande suit un échange < 24 h)
  let chatToOrderCount = 0
  try {
    const loyaltyService: any = req.scope.resolve(LOYALTY_MODULE)
    const txs = await loyaltyService.listLoyaltyTransactions(
      { type: "chat_engagement" },
      { take: null }
    )
    chatToOrderCount = txs.filter((t: any) => t.ref_id?.startsWith("order_")).length
  } catch (err) {
    console.error("Failed to compute chat-to-order conversions:", err)
  }

  res.json({
    analytics: {
      total_conversations: direct.length,
      broadcast_channels: conversations.length - direct.length,
      answered_conversations: answered,
      response_rate_pct: direct.length > 0 ? Math.round((answered / direct.length) * 100) : null,
      answered_within_1h_pct:
        answered > 0 ? Math.round((answeredWithinHour / answered) * 100) : null,
      median_first_response_minutes:
        medianDelayMs !== null ? Math.round(medianDelayMs / 60000) : null,
      messages_last_7d: messagesLast7d,
      active_conversations_last_7d: activeConversationsLast7d,
      chat_to_order_conversions: chatToOrderCount,
    },
  })
}
