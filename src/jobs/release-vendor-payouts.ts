import { MedusaContainer } from "@medusajs/framework/types"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { notifyRecipient } from "../modules/notification-center/notify"
import {
  CONFIRMATION_MS,
  GRACE_MS,
  PAYOUT_DONE_KEY,
  PAYOUT_HOLD_KEY,
  PAYOUT_REMINDER_KEY,
  markPayoutReminderSent,
  releaseFulfillmentPayout,
} from "../modules/marketplace/payout"

const DAY_MS = 24 * 60 * 60 * 1000

/** Au-delà, un colis encore impayé relève d'une reprise manuelle, pas de l'automatisme. */
const LOOKBACK_MS = 60 * DAY_MS

/**
 * Filet du séquestre : libère l'argent des colis que le client n'a jamais confirmés.
 *
 * Le parcours nominal reste la confirmation du client (voir
 * subscribers/vendor-payout-on-confirmation.ts), qui paie le vendeur immédiatement. Ce job
 * ne s'occupe que du silence :
 *
 *   1. colis marqué livré → le client a PAYOUT_CONFIRMATION_DAYS pour confirmer ;
 *   2. passé ce délai, une relance part, une seule fois par colis ;
 *   3. PAYOUT_GRACE_HOURS après la relance, l'argent part quand même.
 *
 * La relance est envoyée avant, et pas au moment du versement : un client qui a un problème
 * avec sa commande doit l'apprendre pendant qu'il peut encore réagir, pas après.
 */
export default async function releaseVendorPayoutsJob(container: MedusaContainer) {
  const logger = container.resolve("logger")
  const query = container.resolve(ContainerRegistrationKeys.QUERY)

  const now = Date.now()
  const since = new Date(now - LOOKBACK_MS)

  // Un `delivered_at` renseigné et récent : les colis jamais livrés ne remontent pas.
  const { data: fulfillments } = await query.graph({
    entity: "fulfillment",
    fields: [
      "id",
      "delivered_at",
      "canceled_at",
      "metadata",
      "order.id",
      "order.display_id",
      "order.customer_id",
    ],
    filters: { delivered_at: { $gte: since } },
  })

  let reminded = 0
  let released = 0

  for (const fulfillment of fulfillments ?? []) {
    const meta = ((fulfillment as any).metadata ?? {}) as Record<string, any>

    if ((fulfillment as any).canceled_at || meta[PAYOUT_DONE_KEY]) continue

    // Litige signalé par le client : ni relance ni versement tant qu'il n'est pas tranché.
    if (meta[PAYOUT_HOLD_KEY]) continue

    const deliveredAt = new Date((fulfillment as any).delivered_at).getTime()
    if (!Number.isFinite(deliveredAt)) continue

    // Le client a encore la main : rien ne bouge avant la fin du délai de confirmation.
    if (now < deliveredAt + CONFIRMATION_MS) continue

    const order = (fulfillment as any).order
    const remindedAt = meta[PAYOUT_REMINDER_KEY]
      ? new Date(meta[PAYOUT_REMINDER_KEY]).getTime()
      : null

    try {
      if (!remindedAt) {
        if (order?.customer_id) {
          await notifyRecipient(container, {
            recipientId: order.customer_id,
            recipientType: "customer",
            type: "delivery_confirmation_reminder",
            title: "Confirmez la réception de votre commande",
            body:
              `Sans réponse de votre part sous 24 h, la commande #${order.display_id} ` +
              `sera considérée comme reçue et le vendeur sera payé.`,
            data: { order_id: order.id, fulfillment_id: (fulfillment as any).id },
            pushCategory: "orders",
          })
        }

        // Marqueur posé même sans destinataire joignable : sans lui, le colis resterait
        // bloqué à l'étape relance et ne serait jamais versé.
        await markPayoutReminderSent(container, (fulfillment as any).id, meta)
        reminded++
        continue
      }

      if (now >= remindedAt + GRACE_MS) {
        const paid = await releaseFulfillmentPayout(
          container,
          (fulfillment as any).id,
          "auto_release"
        )
        if (paid) released++
      }
    } catch (error) {
      logger.error(`[Payouts] Colis ${(fulfillment as any).id} : ${error}`)
    }
  }

  if (reminded > 0 || released > 0) {
    logger.info(
      `[Payouts] ${reminded} relance(s) client, ${released} versement(s) automatique(s).`
    )
  }
}

export const config = {
  name: "release-vendor-payouts",
  // Toutes les heures : le délai de grâce se compte en heures, inutile d'être plus fin.
  schedule: "0 * * * *",
}
