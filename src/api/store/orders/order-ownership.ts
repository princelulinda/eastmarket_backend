import { AuthenticatedMedusaRequest } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"

/**
 * Ce que le client doit pouvoir lire sur sa propre commande.
 *
 * `payment_collections.*` seul ne dit ni par quel moyen la commande a été réglée, ni si elle
 * l'a été : le fournisseur et la transaction vivent sur `payments` (et sur `payment_sessions`
 * tant qu'aucun paiement n'a abouti). `fulfillments.labels` porte les numéros de suivi — dans
 * Medusa v2 ils ne sont plus sur `tracking_links`.
 */
export const STORE_ORDER_DETAIL_FIELDS = [
  "id",
  "status",
  "display_id",
  "email",
  "currency_code",
  "created_at",
  "updated_at",
  "total",
  "subtotal",
  "tax_total",
  "shipping_total",
  "discount_total",
  "items.*",
  "shipping_address.*",
  "billing_address.*",
  "shipping_methods.*",
  "fulfillments.*",
  "fulfillments.items.*",
  "fulfillments.labels.*",
  "payment_collections.*",
  "payment_collections.payments.*",
  "payment_collections.payment_sessions.*",
  // La boutique à qui la commande a été passée : le client doit pouvoir la reconnaître,
  // et la contacter depuis sa commande plutôt que de la rechercher.
  "vendor.id",
  "vendor.name",
  "vendor.handle",
  "vendor.logo",
]

/**
 * Refuse l'accès à une commande qui n'appartient pas au client connecté.
 *
 * Répond « Order not found » et non « Unauthorized » : distinguer les deux dirait à qui
 * tâtonne des identifiants lesquels correspondent à une commande réelle.
 */
export async function assertOrderCustomerOwnership(
  req: AuthenticatedMedusaRequest,
  orderId: string
): Promise<void> {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const {
    data: [order],
  } = await query.graph({
    entity: "order",
    fields: ["customer_id"],
    filters: { id: orderId },
  })

  if (!order || order.customer_id !== req.auth_context.actor_id) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Order not found")
  }
}
