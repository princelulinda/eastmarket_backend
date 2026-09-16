import { z } from "@medusajs/framework/zod"
import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { createOrderFulfillmentWorkflow } from "@medusajs/medusa/core-flows"
import { assertOrderOwnership } from "../order-ownership"

/**
 * Préparation groupée de commandes.
 *
 * Le vendeur qui reçoit vingt commandes le matin devait ouvrir chaque fiche,
 * appuyer sur « Préparer », revenir, recommencer. Ici, une seule requête —
 * chaque commande est traitée intégralement (toutes ses lignes, quantité pleine),
 * ce qui couvre le cas courant ; une préparation partielle reste l'affaire de
 * la fiche détaillée.
 */
export const PostBatchFulfillSchema = z.object({
  order_ids: z.array(z.string()).min(1).max(50),
  /** Entrepôt d'expédition ; à défaut, le premier entrepôt de la boutique. */
  location_id: z.string().optional(),
}).strict()

type PostBody = z.infer<typeof PostBatchFulfillSchema>

export const POST = async (
  req: AuthenticatedMedusaRequest<PostBody>,
  res: MedusaResponse
) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { order_ids } = req.validatedBody

  let locationId = req.validatedBody.location_id
  if (!locationId) {
    const { data: locations } = await query.graph({
      entity: "stock_location",
      fields: ["id"],
    })
    locationId = locations[0]?.id
  }

  if (!locationId) {
    return res.status(400).json({
      message: "No stock location available",
      succeeded: [],
      failed: order_ids.map((id) => ({ id, reason: "no_location" })),
    })
  }

  const succeeded: string[] = []
  const failed: { id: string; reason: string }[] = []

  // Séquentiel et non parallèle : chaque préparation décrémente le stock, et
  // deux commandes portant la même référence se marcheraient dessus.
  for (const orderId of order_ids) {
    try {
      await assertOrderOwnership(req, orderId)

      const { data: [order] } = await query.graph({
        entity: "order",
        fields: ["id", "items.id", "items.quantity", "items.detail.fulfilled_quantity"],
        filters: { id: orderId },
      })

      if (!order) {
        failed.push({ id: orderId, reason: "not_found" })
        continue
      }

      // Ne demander que le reste à préparer : renvoyer la quantité totale sur
      // une commande déjà partiellement traitée ferait échouer le workflow.
      const items = (order.items || [])
        .map((item: any) => ({
          id: item.id,
          quantity: (item.quantity ?? 0) - (item.detail?.fulfilled_quantity ?? 0),
        }))
        .filter((item: any) => item.quantity > 0)

      if (items.length === 0) {
        failed.push({ id: orderId, reason: "already_fulfilled" })
        continue
      }

      await createOrderFulfillmentWorkflow(req.scope).run({
        input: { order_id: orderId, location_id: locationId, items: items as any },
      })

      succeeded.push(orderId)
    } catch (e: any) {
      // Une commande en échec ne doit pas interrompre le lot : le vendeur
      // récupère la liste de celles qui restent à traiter.
      failed.push({ id: orderId, reason: e?.message ?? "error" })
    }
  }

  res.json({ succeeded, failed })
}
