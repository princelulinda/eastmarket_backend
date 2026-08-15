import { MedusaContainer } from "@medusajs/framework/types"
import { CHAT_MODULE } from "../modules/chat"
import ChatModuleService from "../modules/chat/service"
import { MARKETPLACE_MODULE } from "../modules/marketplace"

/**
 * Calcule pour chaque vendeur, à partir des vrais messages du chat :
 *  - response_rate : % de conversations où le vendeur a répondu
 *  - response_time : temps médian de première réponse, en libellé lisible
 * Ces champs existaient déjà sur le vendor mais n'étaient jamais calculés.
 */
export default async function computeVendorResponseSla(container: MedusaContainer) {
  const logger = container.resolve("logger")
  const chatService: ChatModuleService = container.resolve(CHAT_MODULE)
  const marketplaceService: any = container.resolve(MARKETPLACE_MODULE)

  const conversations = await chatService.listConversations(
    {},
    { take: null } as any
  )

  // vendor_id → délais de première réponse (ms) + compteurs
  const byVendor = new Map<string, { delays: number[]; answered: number; total: number }>()

  for (const conv of conversations) {
    if (!conv.vendor_id) continue

    const messages = await chatService.listMessages(
      { conversation_id: conv.id } as any,
      { take: 50, order: { created_at: "ASC" } } as any
    )

    const firstCustomerMsg = messages.find((m: any) => m.sender_type === "customer")
    if (!firstCustomerMsg) continue

    const stats = byVendor.get(conv.vendor_id) || { delays: [], answered: 0, total: 0 }
    stats.total += 1

    const firstVendorReply = messages.find(
      (m: any) =>
        m.sender_type === "vendor" &&
        // Exclure les messages système postés au nom du vendeur
        !["order_update", "system", "flash_sale"].includes(m.type) &&
        new Date(m.created_at) > new Date(firstCustomerMsg.created_at)
    )

    if (firstVendorReply) {
      stats.answered += 1
      stats.delays.push(
        new Date(firstVendorReply.created_at).getTime() -
          new Date(firstCustomerMsg.created_at).getTime()
      )
    }

    byVendor.set(conv.vendor_id, stats)
  }

  const labelFor = (ms: number): string => {
    const minutes = ms / 60000
    if (minutes < 5) return "Répond en ~5 min"
    if (minutes < 15) return "Répond en ~15 min"
    if (minutes < 60) return "Répond en ~1 h"
    if (minutes < 60 * 6) return "Répond en quelques heures"
    if (minutes < 60 * 24) return "Répond sous 24 h"
    return "Répond sous quelques jours"
  }

  let updated = 0
  for (const [vendorId, stats] of byVendor) {
    if (stats.total === 0) continue

    const responseRate = Math.round((stats.answered / stats.total) * 100)
    let responseTime: string | null = null
    if (stats.delays.length > 0) {
      const sorted = [...stats.delays].sort((a, b) => a - b)
      const median = sorted[Math.floor(sorted.length / 2)]
      responseTime = labelFor(median)
    }

    try {
      await marketplaceService.updateVendors({
        id: vendorId,
        response_rate: responseRate,
        ...(responseTime ? { response_time: responseTime } : {}),
      })
      updated += 1
    } catch (err) {
      logger.error(`[vendor-sla] Failed to update vendor ${vendorId}:`, err)
    }
  }

  logger.info(`[vendor-sla] Updated response SLA for ${updated} vendor(s).`)
}

export const config = {
  name: "compute-vendor-response-sla",
  // Toutes les heures
  schedule: "0 * * * *",
}
