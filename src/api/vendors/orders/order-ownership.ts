import { AuthenticatedMedusaRequest } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"

/** Champs renvoyés au client après une action sur une commande. */
export const ORDER_DETAIL_FIELDS = [
  "id", "status", "total", "subtotal",
  "items.*", "items.detail",
  "fulfillments.*", "fulfillments.items.*",
  "payment_collections.*",
]

/**
 * Refuse l'accès à une commande qui n'appartient pas au vendeur connecté.
 * Renvoie "Order not found" plutôt qu'une erreur d'autorisation, pour ne pas
 * divulguer l'existence des commandes des autres vendeurs.
 */
export async function assertOrderOwnership(
  req: AuthenticatedMedusaRequest,
  orderId: string,
): Promise<void> {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.orders.id"],
    filters: { id: [req.auth_context.actor_id] },
  })

  const orderIds = (vendorAdmin?.vendor?.orders || []).map((o: { id: string }) => o.id)
  if (!orderIds.includes(orderId)) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Order not found")
  }
}
