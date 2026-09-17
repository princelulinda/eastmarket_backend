import { SubscriberArgs, type SubscriberConfig } from "@medusajs/framework"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import {
  PAYOUT_DONE_KEY,
  releaseFulfillmentPayout,
} from "../modules/marketplace/payout"

/**
 * Le client a confirmé avoir reçu sa commande : les vendeurs sont payés immédiatement.
 *
 * C'est le chemin nominal du séquestre — celui qui ne dépend d'aucun délai. La libération
 * automatique après relance (jobs/release-vendor-payouts.ts) n'est que le filet pour les
 * clients qui ne confirment jamais.
 *
 * Seuls les colis effectivement livrés sont réglés : une commande peut être complétée
 * alors qu'un colis est encore en route, et celui-là n'a pas à être payé d'avance.
 */
export default async function vendorPayoutOnConfirmationHandler({
  event: { data },
  container,
}: SubscriberArgs<{ id: string } | { id: string }[]>) {
  // `order.completed` porte un tableau (le workflow complète plusieurs commandes à la fois),
  // mais reste tolérant à la forme unitaire.
  const orderIds = (Array.isArray(data) ? data : [data])
    .map((entry) => entry?.id)
    .filter(Boolean) as string[]

  if (orderIds.length === 0) return

  const query = container.resolve(ContainerRegistrationKeys.QUERY)

  for (const orderId of orderIds) {
    try {
      const {
        data: [order],
      } = await query.graph({
        entity: "order",
        fields: [
          "id",
          "fulfillments.id",
          "fulfillments.delivered_at",
          "fulfillments.canceled_at",
          "fulfillments.metadata",
        ],
        filters: { id: orderId },
      })

      const fulfillments = (order as any)?.fulfillments ?? []

      for (const fulfillment of fulfillments) {
        if (!fulfillment?.delivered_at || fulfillment.canceled_at) continue
        if ((fulfillment.metadata ?? {})[PAYOUT_DONE_KEY]) continue

        await releaseFulfillmentPayout(
          container,
          fulfillment.id,
          "customer_confirmed"
        )
      }
    } catch (error) {
      console.error(
        `Erreur lors du versement après confirmation de la commande ${orderId}:`,
        error
      )
    }
  }
}

export const config: SubscriberConfig = {
  event: "order.completed",
}
