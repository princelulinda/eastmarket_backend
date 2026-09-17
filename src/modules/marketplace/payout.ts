import { MedusaContainer } from "@medusajs/framework/types"
import { ContainerRegistrationKeys, Modules } from "@medusajs/framework/utils"
import MarketplaceModuleService from "./service"
import { vendorShare } from "./commission"

/**
 * Horodatage du versement, posé sur le **colis** : l'unité de paiement est le colis et non
 * la commande, sinon une commande livrée en deux fois serait payée deux fois en entier.
 */
export const PAYOUT_DONE_KEY = "vendor_payout_at"

/** Horodatage de la relance envoyée au client avant le versement automatique. */
export const PAYOUT_REMINDER_KEY = "payout_reminder_at"

/**
 * Horodatage d'une suspension : le client a signalé un problème sur ce colis.
 *
 * C'est ce qui donne sa valeur au séquestre. Sans lui, la fenêtre de confirmation ne fait
 * que retarder l'argent : l'acheteur attend quelques jours, puis le vendeur est payé, qu'il
 * ait livré le bon colis ou non. Tant que ce marqueur est posé, plus rien ne part
 * automatiquement — seule une levée explicite peut débloquer la situation.
 */
export const PAYOUT_HOLD_KEY = "payout_hold_at"

const DAY_MS = 24 * 60 * 60 * 1000
const HOUR_MS = 60 * 60 * 1000

/** Délai laissé au client pour confirmer de lui-même avant qu'on le relance. */
export const CONFIRMATION_MS =
  Number(process.env.PAYOUT_CONFIRMATION_DAYS ?? 4) * DAY_MS

/** Délai après la relance au terme duquel l'argent part sans confirmation. */
export const GRACE_MS = Number(process.env.PAYOUT_GRACE_HOURS ?? 24) * HOUR_MS

export type PayoutReason = "customer_confirmed" | "auto_release"

/**
 * Libère vers les vendeurs l'argent d'un colis livré, puis marque le colis comme réglé.
 *
 * Trois chemins y mènent — la confirmation du client, la libération automatique après
 * relance, et une reprise manuelle — d'où l'extraction ici : le marqueur `vendor_payout_at`
 * est ce qui garantit qu'aucun d'eux ne paie deux fois le même colis.
 *
 * Renvoie `true` si un versement a eu lieu, `false` si le colis était déjà réglé, annulé,
 * ou sans vendeur identifiable.
 */
export async function releaseFulfillmentPayout(
  container: MedusaContainer,
  fulfillmentId: string,
  reason: PayoutReason
): Promise<boolean> {
  const query = container.resolve(ContainerRegistrationKeys.QUERY)
  const marketplaceModule = container.resolve(
    "marketplace"
  ) as MarketplaceModuleService
  const fulfillmentModule: any = container.resolve(Modules.FULFILLMENT)

  const {
    data: [fulfillment],
  } = await query.graph({
    entity: "fulfillment",
    fields: [
      "id",
      "metadata",
      "canceled_at",
      "delivered_at",
      // Alias exposé par le lien order_fulfillment, qui étend Fulfillment.
      "order.id",
      "items.line_item_id",
      "items.quantity",
    ],
    filters: { id: fulfillmentId },
  })

  if (!fulfillment) return false

  const meta = (fulfillment.metadata as any) ?? {}

  // Un colis annulé, jamais livré, ou déjà réglé ne donne lieu à aucun versement.
  if ((fulfillment as any).canceled_at) return false
  if (!(fulfillment as any).delivered_at) return false
  if (meta[PAYOUT_DONE_KEY]) return false

  // Litige en cours : l'argent ne bouge pas, même si le client confirme par ailleurs.
  if (meta[PAYOUT_HOLD_KEY]) {
    console.log(
      `[Marketplace] Colis ${fulfillmentId} sous litige depuis ${meta[PAYOUT_HOLD_KEY]}, versement suspendu.`
    )
    return false
  }

  const orderId = (fulfillment as any).order?.id
  if (!orderId) {
    console.warn(
      `[Marketplace] Colis ${fulfillmentId} sans commande rattachée, versement ignoré.`
    )
    return false
  }

  const {
    data: [order],
  } = await query.graph({
    entity: "order",
    fields: [
      "id",
      "items.id",
      "items.unit_price",
      "items.product_id",
      "items.metadata",
    ],
    filters: { id: orderId },
  })

  const lineItems = new Map<string, any>(
    ((order as any)?.items ?? []).map((item: any) => [item.id, item])
  )

  const shippedItems = ((fulfillment as any).items ?? []).filter(
    (item: any) => item.line_item_id
  )

  // Agrégé par vendeur avant versement : `addVendorBalance` relit la balance à chaque
  // appel, deux appels rapprochés pour le même vendeur en perdraient un.
  const credits = new Map<string, number>()

  for (const shipped of shippedItems) {
    const line = lineItems.get(shipped.line_item_id)
    if (!line) continue

    let vendorId = line.metadata?.vendor_id as string | undefined

    if (!vendorId && line.product_id) {
      const { data: products } = await query.graph({
        entity: "product",
        fields: ["id", "vendor.id"],
        filters: { id: line.product_id },
      })
      vendorId = products[0]?.vendor?.id
    }

    if (!vendorId) continue

    // La quantité livrée, pas la quantité commandée.
    const itemTotal = Number(line.unit_price) * Number(shipped.quantity)
    credits.set(vendorId, (credits.get(vendorId) ?? 0) + vendorShare(itemTotal))
  }

  for (const [vendorId, amount] of credits) {
    if (amount <= 0) continue

    await marketplaceModule.addVendorBalance(vendorId, amount)
    console.log(
      `[Marketplace] Vendeur ${vendorId} crédité de ${amount} pour le colis ${fulfillmentId} ` +
        `(commande ${orderId}, ${reason}).`
    )
  }

  // Marqueur posé après les versements : un échec en cours de route reste rejouable,
  // plutôt que de laisser un vendeur impayé sur un colis marqué comme réglé.
  await fulfillmentModule.updateFulfillment(fulfillmentId, {
    metadata: {
      ...meta,
      [PAYOUT_DONE_KEY]: new Date().toISOString(),
      vendor_payout_reason: reason,
    },
  })

  return credits.size > 0
}

/**
 * Suspend le versement d'un colis : l'argent reste chez la marketplace jusqu'à arbitrage.
 *
 * Idempotent — un second signalement ne réécrit pas la date du premier, pour que l'ancienneté
 * du litige reste lisible.
 */
export async function holdFulfillmentPayout(
  container: MedusaContainer,
  fulfillmentId: string,
  reason: string
): Promise<boolean> {
  const query = container.resolve(ContainerRegistrationKeys.QUERY)
  const fulfillmentModule: any = container.resolve(Modules.FULFILLMENT)

  const {
    data: [fulfillment],
  } = await query.graph({
    entity: "fulfillment",
    fields: ["id", "metadata"],
    filters: { id: fulfillmentId },
  })

  if (!fulfillment) return false

  const meta = ((fulfillment as any).metadata ?? {}) as Record<string, any>

  // Déjà versé : il est trop tard pour retenir l'argent, le litige se règle autrement.
  if (meta[PAYOUT_DONE_KEY]) return false
  if (meta[PAYOUT_HOLD_KEY]) return true

  await fulfillmentModule.updateFulfillment(fulfillmentId, {
    metadata: {
      ...meta,
      [PAYOUT_HOLD_KEY]: new Date().toISOString(),
      payout_hold_reason: reason,
    },
  })

  return true
}

/** Note qu'on a relancé le client, pour ne le faire qu'une fois par colis. */
export async function markPayoutReminderSent(
  container: MedusaContainer,
  fulfillmentId: string,
  currentMetadata: Record<string, any> | null | undefined
): Promise<void> {
  const fulfillmentModule: any = container.resolve(Modules.FULFILLMENT)

  await fulfillmentModule.updateFulfillment(fulfillmentId, {
    metadata: {
      ...(currentMetadata ?? {}),
      [PAYOUT_REMINDER_KEY]: new Date().toISOString(),
    },
  })
}
