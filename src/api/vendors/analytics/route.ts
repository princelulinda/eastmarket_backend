import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import AnalyticsService from "../../../../modules/analytics/service"

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const analyticsService = req.scope.resolve("analytics") as AnalyticsService
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  // Récupérer les filtres de date depuis les query params
  // Exemple : GET /vendors/analytics?from=2024-01-01&to=2024-12-31
  const { from, to } = req.query as { from?: string; to?: string }

  const fromDate = from ? new Date(from) : undefined
  const toDate = to ? new Date(to) : undefined

  // Get vendor ID
  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id"],
    filters: { id: [req.auth_context.actor_id] }
  })

  const events = await analyticsService.listAnalyticsEvents({
    vendor_id: vendorAdmin.vendor.id
  })

  // Filtrer par plage de dates si fournie (sur created_at géré automatiquement par Medusa)
  const filteredEvents = events.filter((event: any) => {
    const createdAt = new Date(event.created_at)
    if (fromDate && createdAt < fromDate) return false
    if (toDate && createdAt > toDate) return false
    return true
  })

  // Agrégation dynamique par source (facebook, tiktok, etc.)
  const summary = filteredEvents.reduce((acc, event) => {
    acc[event.source] = acc[event.source] || { clicks: 0, conversions: 0 }
    if (event.event_type === "click") acc[event.source].clicks++
    if (event.event_type === "conversion") acc[event.source].conversions++
    return acc
  }, {} as Record<string, { clicks: number; conversions: number }>)

  res.json({
    summary,
    meta: {
      from: fromDate?.toISOString() ?? null,
      to: toDate?.toISOString() ?? null,
      total_events: filteredEvents.length,
    }
  })
}
