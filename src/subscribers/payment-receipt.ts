import { SubscriberArgs, SubscriberConfig } from "@medusajs/framework"
import { ContainerRegistrationKeys, Modules } from "@medusajs/framework/utils"
import {
  sendEmail,
  getPaymentDueEmailTemplate,
  getPaymentReceiptEmailTemplate,
  type PaymentReceiptLine,
} from "../modules/notification-center/email-service"

/**
 * Marqueur posé sur la commande une fois le reçu parti. Un subscriber peut être rejoué, et
 * deux reçus pour un même paiement font douter le client d'avoir été débité deux fois.
 */
const RECEIPT_SENT_KEY = "payment_receipt_sent_at"

/** Sans cette table, le client lirait « pp_trustsend_trustsend » sur son reçu. */
const PROVIDER_LABELS: Record<string, string> = {
  pp_trustsend_trustsend: "Mobile Money · TrustSend",
  pp_mbiyopay_mbiyopay: "Mobile Money · MbiyoPay",
  pp_kashflow_kashflow: "KashFlow",
  pp_stripe_stripe: "Carte bancaire · Stripe",
  pp_system_default: "Paiement à la livraison",
}

/** Le numéro appartient au client, mais un email n'est pas l'endroit pour l'étaler en entier. */
function maskPhone(raw: unknown): string {
  const digits = String(raw ?? "").replace(/\D/g, "")
  if (digits.length < 7) return `+${digits}`
  return `+${digits.slice(0, 4)} •••• ${digits.slice(-3)}`
}

/** Le paiement à la livraison passe par KashFlow : seule la charge utile le distingue. */
function isOnDelivery(payment: any): boolean {
  return (payment?.data ?? {}).payment_method === "pay_on_delivery"
}

function describePayment(payment: any): PaymentReceiptLine {
  const data = payment?.data ?? {}

  const label = isOnDelivery(payment)
    ? "Paiement à la livraison"
    : (PROVIDER_LABELS[payment.provider_id] ??
      String(payment.provider_id ?? "").replace(/^pp_/, "").replace(/_/g, " "))

  const details: string[] = []
  if (!isOnDelivery(payment) && data.provider) {
    details.push(String(data.provider).replace(/_/g, " "))
  }
  if (data.phone_number) details.push(maskPhone(data.phone_number))

  return {
    label,
    detail: details.length > 0 ? details.join(" · ") : null,
    reference: data.deposit_id ?? data.transaction_id ?? null,
    amount: Number(payment.amount ?? 0),
  }
}

/**
 * Envoie au client le document qui parle d'argent, séparément de la confirmation de commande
 * qui parle de logistique : un reçu quand le paiement a réellement eu lieu, un rappel du montant
 * dû quand il est à régler à la livraison.
 *
 * Déclenché sur `order.placed` et non sur `payment.captured` : ce dernier n'est émis que par
 * `capturePaymentWorkflow`, qu'aucun code de ce projet n'appelle. Et pour le mobile money, il
 * ne signifierait rien de plus — l'argent a déjà quitté le compte du payeur au moment où le
 * dépôt passe `completed`, bien avant toute capture. `order.placed` est donc, ici, le moment
 * où le paiement est acquis : l'app ne finalise le panier qu'une fois la session autorisée.
 */
export default async function paymentReceiptHandler({
  event: { data },
  container,
}: SubscriberArgs<{ id: string }>) {
  const query = container.resolve(ContainerRegistrationKeys.QUERY)
  const orderModule: any = container.resolve(Modules.ORDER)

  const {
    data: [order],
  } = await query.graph({
    entity: "order",
    fields: [
      "id",
      "display_id",
      "email",
      "currency_code",
      "metadata",
      "total",
      "subtotal",
      "shipping_total",
      "tax_total",
      "items.*",
      "payment_collections.*",
      "payment_collections.payments.*",
    ],
    filters: { id: data.id },
  })

  // Sans adresse, rien à envoyer — et rien à signaler : une commande sans email est un cas
  // prévu (commande créée côté admin, par exemple).
  if (!order?.email) return

  if ((order.metadata as any)?.[RECEIPT_SENT_KEY]) {
    return
  }

  const collections = (order as any).payment_collections ?? []
  // Une transaction annulée ne prouve aucun encaissement.
  const payments = collections
    .flatMap((c: any) => c.payments ?? [])
    .filter((p: any) => p && !p.canceled_at)

  const paidAmount = payments.reduce(
    (sum: number, p: any) => sum + Number(p.amount ?? 0),
    0
  )

  // Un reçu qui annonce « paiement reçu » alors que tout est dû au livreur serait un faux.
  const nothingCollected =
    payments.length === 0 || paidAmount <= 0 || payments.every(isOnDelivery)

  const first = payments[0]
  const html = nothingCollected
    ? getPaymentDueEmailTemplate(order)
    : getPaymentReceiptEmailTemplate(order, {
        lines: payments.map(describePayment),
        paidAmount,
        paidAt: new Date(first?.captured_at ?? first?.created_at ?? Date.now()),
      })

  const subject = nothingCollected
    ? `Commande #${order.display_id} — à régler à la livraison`
    : `Reçu de paiement — commande #${order.display_id}`

  try {
    await sendEmail({ to: order.email, subject, html })

    // Marqueur posé seulement après un envoi réussi : un échec SMTP doit pouvoir être rejoué.
    await orderModule.updateOrders([
      {
        id: order.id,
        metadata: {
          ...((order.metadata as any) ?? {}),
          [RECEIPT_SENT_KEY]: new Date().toISOString(),
        },
      },
    ])
  } catch (err) {
    // La commande est passée : l'échec du reçu ne doit pas faire échouer le traitement.
    console.error(`Failed to send payment receipt for order ${order.id}:`, err)
  }
}

export const config: SubscriberConfig = {
  event: "order.placed",
}
