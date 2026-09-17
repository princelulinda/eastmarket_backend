import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError, Modules } from "@medusajs/framework/utils"
import { assertOrderCustomerOwnership } from "../../order-ownership"
import {
  PAYOUT_DONE_KEY,
  holdFulfillmentPayout,
} from "../../../../../modules/marketplace/payout"
import { notifyVendor } from "../../../../../modules/notification-center/notify"

/** Motifs proposés au client. Le texte libre reste optionnel. */
const ISSUE_LABELS: Record<string, string> = {
  not_received: "Colis jamais reçu",
  damaged: "Article endommagé",
  not_as_described: "Article non conforme à l'annonce",
  incomplete: "Commande incomplète",
  return_request: "Demande de retour",
  other: "Autre problème",
}

/**
 * POST /store/orders/:id/report-issue — le client signale un problème sur sa commande.
 *
 * Effet immédiat et concret : le versement au vendeur est suspendu sur tous les colis livrés
 * mais pas encore réglés. C'est ce qui donne sa valeur au séquestre — sans ce bouton, la
 * fenêtre de confirmation ne fait que retarder l'argent, puisque la seule action offerte au
 * client était d'accélérer le paiement du vendeur.
 *
 * La suspension ne se lève pas toute seule : elle attend un arbitrage.
 */
export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const orderId = req.params.id
  const { type, description } = (req.body ?? {}) as {
    type?: string
    description?: string
  }

  if (!type || !ISSUE_LABELS[type]) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      `'type' doit valoir l'un de : ${Object.keys(ISSUE_LABELS).join(", ")}`
    )
  }

  await assertOrderCustomerOwnership(req, orderId)

  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const orderModule: any = req.scope.resolve(Modules.ORDER)

  const {
    data: [order],
  } = await query.graph({
    entity: "order",
    fields: [
      "id",
      "display_id",
      "metadata",
      "vendor.id",
      "fulfillments.id",
      "fulfillments.delivered_at",
      "fulfillments.canceled_at",
      "fulfillments.metadata",
    ],
    filters: { id: orderId },
  })

  const label = ISSUE_LABELS[type]
  const fulfillments = (order as any)?.fulfillments ?? []

  let held = 0
  for (const fulfillment of fulfillments) {
    if (!fulfillment?.delivered_at || fulfillment.canceled_at) continue
    if ((fulfillment.metadata ?? {})[PAYOUT_DONE_KEY]) continue

    const ok = await holdFulfillmentPayout(req.scope as any, fulfillment.id, label)
    if (ok) held++
  }

  // Trace sur la commande : le signalement existe même quand il n'y avait rien à retenir
  // (colis pas encore livré, ou vendeur déjà payé).
  const issues = [
    ...(((order as any)?.metadata?.reported_issues ?? []) as any[]),
    {
      type,
      label,
      description: description?.trim() || null,
      held_fulfillments: held,
      reported_at: new Date().toISOString(),
    },
  ]

  await orderModule.updateOrders([
    {
      id: orderId,
      metadata: { ...(((order as any)?.metadata ?? {}) as object), reported_issues: issues },
    },
  ])

  const vendorId = (order as any)?.vendor?.id
  if (vendorId) {
    try {
      await notifyVendor(req.scope as any, {
        vendorId,
        type: "order_issue_reported",
        title: "Problème signalé sur une commande",
        body: `${label} — commande #${(order as any).display_id}. Le versement est suspendu.`,
        data: { order_id: orderId, issue_type: type },
        pushCategory: "orders",
      })
    } catch (err) {
      // Le signalement est enregistré et l'argent retenu : une notification ratée
      // ne doit pas annuler la protection.
      console.error(`Failed to notify vendor ${vendorId} of reported issue:`, err)
    }
  }

  res.json({
    order_id: orderId,
    type,
    label,
    /** Nombre de colis dont le versement vient d'être suspendu. */
    held_fulfillments: held,
  })
}
