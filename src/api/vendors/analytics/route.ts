import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import AnalyticsService from "../../../modules/analytics/service"

const DEFAULT_WINDOW_DAYS = 30

type SalesTotals = {
  revenue: number
  orders: number
  items_sold: number
  average_order_value: number
}

const emptyTotals = (): SalesTotals => ({
  revenue: 0,
  orders: 0,
  items_sold: 0,
  average_order_value: 0,
})

/** `YYYY-MM-DD` dans le fuseau du serveur, clé des séries quotidiennes. */
function dayKey(date: Date): string {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")}`
}

/**
 * Fenêtre d'analyse. `?from` et `?to` restent les noms de paramètres
 * historiques ; sans eux on prend les 30 derniers jours.
 *
 * `to` est porté à la fin de la journée : `?to=2026-08-23` doit inclure le
 * 23 août. L'implémentation précédente comparait à minuit, ce qui vidait
 * systématiquement le dernier jour demandé.
 */
function resolveWindow(req: AuthenticatedMedusaRequest) {
  const { from, to } = req.query as { from?: string; to?: string }

  const toDate = to ? new Date(to) : new Date()
  if (!Number.isNaN(toDate.getTime()) && to && !to.includes("T")) {
    toDate.setHours(23, 59, 59, 999)
  }

  let fromDate: Date
  if (from) {
    fromDate = new Date(from)
    if (!from.includes("T")) fromDate.setHours(0, 0, 0, 0)
  } else {
    fromDate = new Date(toDate)
    fromDate.setDate(fromDate.getDate() - (DEFAULT_WINDOW_DAYS - 1))
    fromDate.setHours(0, 0, 0, 0)
  }

  // Période précédente de même durée, pour l'évolution.
  const spanMs = toDate.getTime() - fromDate.getTime()
  const prevTo = new Date(fromDate.getTime() - 1)
  const prevFrom = new Date(prevTo.getTime() - spanMs)

  return { fromDate, toDate, prevFrom, prevTo }
}

function accumulate(totals: SalesTotals, order: any) {
  totals.revenue += Number(order.total) || 0
  totals.orders += 1
  for (const item of order.items || []) {
    totals.items_sold += Number(item?.quantity) || 0
  }
}

function finalize(totals: SalesTotals): SalesTotals {
  totals.average_order_value = totals.orders
    ? Math.round(totals.revenue / totals.orders)
    : 0
  return totals
}

/** Variation en pourcentage, `null` quand la période précédente est vide. */
function variation(current: number, previous: number): number | null {
  if (!previous) return null
  return Math.round(((current - previous) / previous) * 1000) / 10
}

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const analyticsService = req.scope.resolve("analytics") as AnalyticsService
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const { fromDate, toDate, prevFrom, prevTo } = resolveWindow(req)

  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id", "vendor.orders.id"],
    filters: { id: [req.auth_context.actor_id] }
  })

  const vendorId = vendorAdmin?.vendor?.id
  const orderIds = (vendorAdmin?.vendor?.orders || [])
    .map((o: any) => o?.id)
    .filter(Boolean) as string[]

  // ── Sources de trafic (comportement historique conservé) ─────────────
  // Le filtrage se fait désormais en base : la route chargeait auparavant
  // l'intégralité des événements de la boutique pour les filtrer en mémoire.
  const events = vendorId
    ? await analyticsService.listAnalyticsEvents({
        vendor_id: vendorId,
        created_at: { $gte: fromDate, $lte: toDate },
      } as any)
    : []

  const summary = (events as any[]).reduce((acc, event) => {
    acc[event.source] = acc[event.source] || { clicks: 0, conversions: 0 }
    if (event.event_type === "click") acc[event.source].clicks++
    if (event.event_type === "conversion") acc[event.source].conversions++
    return acc
  }, {} as Record<string, { clicks: number; conversions: number }>)

  const clicks = (events as any[]).filter((e) => e.event_type === "click").length

  // ── Ventes ───────────────────────────────────────────────────────────
  const orders = orderIds.length
    ? (await query.graph({
        entity: "order",
        // `items.*` en entier, pas une sélection : le calcul des totaux Medusa
        // s'appuie sur la forme complète de la ligne. Avec une sélection
        // partielle, `order.total` et `item.total` reviennent faux.
        fields: [
          "id", "status", "total", "currency_code", "created_at",
          "items.*", "items.detail",
        ],
        filters: { id: orderIds, created_at: { $gte: prevFrom, $lte: toDate } },
      })).data
    : []

  const current = emptyTotals()
  const previous = emptyTotals()
  const daily = new Map<string, { revenue: number; orders: number }>()
  const productTotals = new Map<string, { product_id: string; title: string; thumbnail: string | null; quantity: number; revenue: number }>()
  let currencyCode: string | null = null

  for (const order of orders as any[]) {
    // Une commande annulée n'est ni un revenu, ni une vente.
    if (order.status === "canceled") continue

    const createdAt = new Date(order.created_at)
    currencyCode = currencyCode ?? order.currency_code ?? null

    if (createdAt >= fromDate && createdAt <= toDate) {
      accumulate(current, order)

      const key = dayKey(createdAt)
      const bucket = daily.get(key) ?? { revenue: 0, orders: 0 }
      bucket.revenue += Number(order.total) || 0
      bucket.orders += 1
      daily.set(key, bucket)

      for (const item of order.items || []) {
        if (!item?.product_id) continue
        const entry = productTotals.get(item.product_id) ?? {
          product_id: item.product_id,
          title: item.title ?? "",
          thumbnail: item.thumbnail ?? null,
          quantity: 0,
          revenue: 0,
        }
        entry.quantity += Number(item.quantity) || 0
        entry.revenue += Number(item.total) || 0
        productTotals.set(item.product_id, entry)
      }
    } else if (createdAt >= prevFrom && createdAt <= prevTo) {
      accumulate(previous, order)
    }
  }

  finalize(current)
  finalize(previous)

  // Série continue : un jour sans vente doit valoir zéro, pas disparaître du
  // graphique — sinon la courbe ment sur la régularité des ventes.
  const timeseries: { date: string; revenue: number; orders: number }[] = []
  for (const cursor = new Date(fromDate); cursor <= toDate; cursor.setDate(cursor.getDate() + 1)) {
    const key = dayKey(cursor)
    const bucket = daily.get(key)
    timeseries.push({ date: key, revenue: bucket?.revenue ?? 0, orders: bucket?.orders ?? 0 })
  }

  const topProducts = [...productTotals.values()]
    .sort((a, b) => b.revenue - a.revenue)
    .slice(0, 10)

  res.json({
    // Conservé pour ne pas casser l'écran « sources » existant.
    summary,
    sales: {
      ...current,
      currency_code: currencyCode,
      previous_period: previous,
      variation: {
        revenue: variation(current.revenue, previous.revenue),
        orders: variation(current.orders, previous.orders),
        average_order_value: variation(current.average_order_value, previous.average_order_value),
      },
    },
    timeseries,
    top_products: topProducts,
    conversion: {
      // Uniquement le trafic tracé par les liens de campagne : ce n'est pas le
      // taux de conversion global de la boutique.
      tracked_clicks: clicks,
      orders: current.orders,
      rate: clicks ? Math.round((current.orders / clicks) * 1000) / 10 : null,
    },
    meta: {
      from: fromDate.toISOString(),
      to: toDate.toISOString(),
      previous_from: prevFrom.toISOString(),
      previous_to: prevTo.toISOString(),
      total_events: events.length,
    }
  })
}
