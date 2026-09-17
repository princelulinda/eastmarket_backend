import { SubscriberArgs, type SubscriberConfig } from "@medusajs/framework"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { notifyRecipient } from "../modules/notification-center/notify"

/**
 * Le vendeur vient de marquer un colis livré : on demande au client de confirmer.
 *
 * C'est le point de départ du compte à rebours. Tant que le client n'a pas confirmé — ou
 * que le délai de grâce n'est pas écoulé (voir jobs/release-vendor-payouts.ts) — l'argent
 * reste chez la marketplace. Ce handler ne verse donc rien : il ouvre la fenêtre pendant
 * laquelle l'acheteur garde la main.
 *
 * `delivery.created` transporte l'id du colis, pas celui de la commande.
 */
export default async function deliveryConfirmationRequestHandler({
  event: { data },
  container,
}: SubscriberArgs<{ id: string }>) {
  const fulfillmentId = data?.id
  if (!fulfillmentId) return

  const query = container.resolve(ContainerRegistrationKeys.QUERY)

  try {
    const {
      data: [fulfillment],
    } = await query.graph({
      entity: "fulfillment",
      fields: [
        "id",
        "canceled_at",
        "order.id",
        "order.display_id",
        "order.customer_id",
      ],
      filters: { id: fulfillmentId },
    })

    if (!fulfillment || (fulfillment as any).canceled_at) return

    const order = (fulfillment as any).order
    if (!order?.customer_id) return

    await notifyRecipient(container, {
      recipientId: order.customer_id,
      recipientType: "customer",
      type: "delivery_confirmation_request",
      title: "Votre colis est marqué livré",
      body: `Confirmez la réception de la commande #${order.display_id} pour que le vendeur soit payé.`,
      data: { order_id: order.id, fulfillment_id: fulfillmentId },
      pushCategory: "orders",
    })
  } catch (error) {
    console.error(
      `Erreur lors de la demande de confirmation pour le colis ${fulfillmentId}:`,
      error
    )
  }
}

export const config: SubscriberConfig = {
  // Émis par markOrderFulfillmentAsDeliveredWorkflow, avec { id: fulfillment.id }.
  event: "delivery.created",
}
