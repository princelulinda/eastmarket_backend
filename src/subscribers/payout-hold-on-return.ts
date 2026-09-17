import { SubscriberArgs, type SubscriberConfig } from "@medusajs/framework"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import {
  PAYOUT_DONE_KEY,
  holdFulfillmentPayout,
} from "../modules/marketplace/payout"

/**
 * Un retour a été demandé sur une commande : le versement au vendeur est suspendu.
 *
 * Double le bouton « Signaler un problème » de l'app, mais par un autre chemin : un retour
 * ouvert depuis l'admin, ou par tout autre parcours, doit retenir l'argent de la même façon.
 * `holdFulfillmentPayout` étant idempotent, les deux chemins peuvent se déclencher ensemble
 * sans se gêner.
 */
export default async function payoutHoldOnReturnHandler({
  event: { data },
  container,
}: SubscriberArgs<{ order_id: string; return_id?: string }>) {
  const orderId = data?.order_id
  if (!orderId) return

  const query = container.resolve(ContainerRegistrationKeys.QUERY)

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

    for (const fulfillment of (order as any)?.fulfillments ?? []) {
      if (!fulfillment?.delivered_at || fulfillment.canceled_at) continue
      if ((fulfillment.metadata ?? {})[PAYOUT_DONE_KEY]) continue

      await holdFulfillmentPayout(container, fulfillment.id, "Demande de retour")
    }
  } catch (error) {
    console.error(
      `Erreur lors de la suspension du versement après demande de retour sur ${orderId}:`,
      error
    )
  }
}

export const config: SubscriberConfig = {
  event: "order.return_requested",
}
