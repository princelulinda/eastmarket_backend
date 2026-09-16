import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"
import { NOTIFICATION_MODULE } from "../../../modules/notification-center"
import NotificationCenterService from "../../../modules/notification-center/service"
import { REVIEW_MODULE } from "../../../modules/review"
import { ReviewModuleService } from "../../../modules/review/service"
import { computeOnboarding } from "../onboarding"
import { MARKETPLACE_MODULE } from "../../../modules/marketplace"
import MarketplaceModuleService from "../../../modules/marketplace/service"
import { PENDING_VERIFICATION_FLAG } from "../../middlewares/require-approved-vendor"

type Bucket = { amount: number; orders: number }

const emptyBucket = (): Bucket => ({ amount: 0, orders: 0 })

/** Minuit aujourd'hui, dans le fuseau du serveur. */
function startOfToday(): Date {
  const d = new Date()
  d.setHours(0, 0, 0, 0)
  return d
}

function startOfWeek(): Date {
  const d = startOfToday()
  // Semaine ISO : lundi comme premier jour.
  const day = (d.getDay() + 6) % 7
  d.setDate(d.getDate() - day)
  return d
}

function startOfMonth(offset = 0): Date {
  const d = startOfToday()
  d.setDate(1)
  d.setMonth(d.getMonth() + offset)
  return d
}

/**
 * Tout ce qu'affiche la page d'accueil du dashboard vendeur, en un seul appel.
 *
 * Le front devait jusqu'ici enchaîner commandes, produits, payouts,
 * notifications, analytics et /vendors/me, puis recalculer les totaux
 * lui-même — six allers-retours avant d'afficher quoi que ce soit.
 *
 * Les montants sont dans l'unité de la commande (centimes), comme partout
 * ailleurs dans l'API : c'est au client de formater.
 */
export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const notifService: NotificationCenterService = req.scope.resolve(NOTIFICATION_MODULE)
  const reviewService: ReviewModuleService = req.scope.resolve(REVIEW_MODULE)
  const marketplaceModule: MarketplaceModuleService = req.scope.resolve(MARKETPLACE_MODULE)

  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: [
      "vendor.id", "vendor.name", "vendor.logo",
      "vendor.is_verified", "vendor.verified_at", "vendor.balance",
      "vendor.response_rate", "vendor.response_time",
      "vendor.orders.id",
      "vendor.products.id",
    ],
    filters: { id: [req.auth_context.actor_id] },
  })

  const vendor = vendorAdmin?.vendor as any
  if (!vendor) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Vendor not found")
  }

  // État du dossier KYC : `is_verified` seul ne distingue pas « jamais soumis »
  // de « en cours d'examen » ni de « refusé ». Le dashboard vendeur en a besoin
  // pour afficher le bon message plutôt qu'un simple « non vérifié ».
  const [latestVerification] = await marketplaceModule.listVendorVerifications(
    { vendor_id: vendor.id },
    { order: { created_at: "DESC" }, take: 1 },
  )
  const verificationStatus: "none" | "pending" | "approved" | "rejected" = vendor.is_verified
    ? "approved"
    : ((latestVerification as any)?.status as "pending" | "rejected" | undefined) ?? "none"

  const orderIds = (vendor.orders || []).map((o: any) => o?.id).filter(Boolean) as string[]
  const productIds = (vendor.products || []).map((p: any) => p?.id).filter(Boolean) as string[]

  // ── Commandes ────────────────────────────────────────────────────────
  // Champs minimaux : ce bloc calcule des agrégats, il n'a pas à rapatrier
  // les lignes de commande.
  const orders = orderIds.length
    ? (await query.graph({
        entity: "order",
        fields: [
          "id", "status", "total", "currency_code", "created_at",
          "fulfillments.id", "fulfillments.canceled_at",
        ],
        filters: { id: orderIds },
      })).data
    : []

  const today = startOfToday()
  const week = startOfWeek()
  const month = startOfMonth()
  const prevMonth = startOfMonth(-1)

  const revenue = {
    today: emptyBucket(),
    week: emptyBucket(),
    month: emptyBucket(),
    previous_month: emptyBucket(),
  }

  let toFulfill = 0
  const byStatus: Record<string, number> = {}
  let currencyCode: string | null = null

  for (const order of orders as any[]) {
    byStatus[order.status] = (byStatus[order.status] ?? 0) + 1
    currencyCode = currencyCode ?? order.currency_code ?? null

    const activeFulfillments = (order.fulfillments || []).filter((f: any) => !f?.canceled_at)
    // Une commande annulée n'attend rien ; une commande sans expédition active si.
    if (order.status !== "canceled" && order.status !== "completed" && activeFulfillments.length === 0) {
      toFulfill++
    }

    // Une commande annulée ne compte pas dans le chiffre d'affaires.
    if (order.status === "canceled") continue

    const createdAt = new Date(order.created_at)
    const amount = Number(order.total) || 0

    if (createdAt >= today) { revenue.today.amount += amount; revenue.today.orders++ }
    if (createdAt >= week) { revenue.week.amount += amount; revenue.week.orders++ }
    if (createdAt >= month) {
      revenue.month.amount += amount; revenue.month.orders++
    } else if (createdAt >= prevMonth) {
      revenue.previous_month.amount += amount; revenue.previous_month.orders++
    }
  }

  // ── Catalogue ────────────────────────────────────────────────────────
  const products = productIds.length
    ? (await query.graph({
        entity: "product",
        fields: [
          "id", "status", "metadata",
          "variants.id",
          "variants.inventory.location_levels.available_quantity",
        ],
        filters: { id: productIds },
      })).data
    : []

  let published = 0
  let draft = 0
  let heldByVerification = 0
  let outOfStock = 0

  for (const product of products as any[]) {
    if (product.status === "published") published++
    if (product.status === "draft") draft++
    if (product.metadata?.[PENDING_VERIFICATION_FLAG] === true) heldByVerification++

    const variants = product.variants || []
    // Un produit est « en rupture » quand aucune de ses variantes n'est disponible.
    // Une variante sans inventaire suivi n'est pas comptée comme en rupture.
    const tracked = variants.filter((v: any) => (v.inventory || []).length > 0)
    if (tracked.length > 0) {
      const anyAvailable = tracked.some((v: any) =>
        (v.inventory || []).some((inv: any) =>
          (inv.location_levels || []).some((l: any) => Number(l?.available_quantity) > 0)
        )
      )
      if (!anyAvailable) outOfStock++
    }
  }

  // ── Avis ─────────────────────────────────────────────────────────────
  let reviewSummary = { total: 0, average: null as number | null, unanswered: 0 }
  if (productIds.length) {
    const reviews = await reviewService.listReviews(
      { product_id: productIds },
      { select: ["id", "rating", "vendor_reply"] as any },
    )
    const rows = reviews as any[]
    const rated = rows.filter((r) => typeof r.rating === "number" && r.rating >= 1 && r.rating <= 5)
    reviewSummary = {
      total: rows.length,
      average: rated.length
        ? Math.round((rated.reduce((s, r) => s + r.rating, 0) / rated.length) * 10) / 10
        : null,
      unanswered: rows.filter((r) => !r.vendor_reply).length,
    }
  }

  const [unreadNotifications, onboarding] = await Promise.all([
    notifService.countUnread(vendor.id),
    computeOnboarding(req),
  ])

  res.json({
    vendor: {
      id: vendor.id,
      name: vendor.name,
      logo: vendor.logo,
      is_verified: vendor.is_verified,
      verified_at: vendor.verified_at,
      verification_status: verificationStatus,
      /** Motif du dernier refus, pour l'afficher sans second appel. */
      verification_rejection_reason:
        verificationStatus === "rejected" ? (latestVerification as any)?.rejection_reason ?? null : null,
      balance: vendor.balance,
      response_rate: vendor.response_rate,
      response_time: vendor.response_time,
    },
    revenue: { ...revenue, currency_code: currencyCode },
    orders: {
      total: orders.length,
      to_fulfill: toFulfill,
      by_status: byStatus,
    },
    catalogue: {
      total: products.length,
      published,
      draft,
      held_by_verification: heldByVerification,
      out_of_stock: outOfStock,
    },
    reviews: reviewSummary,
    unread_notifications: unreadNotifications,
    onboarding: onboarding
      ? {
          completion: onboarding.completion,
          completed_steps: onboarding.completed_steps,
          total_steps: onboarding.total_steps,
          next_step: onboarding.next_step,
        }
      : null,
  })
}
