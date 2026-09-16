import { z } from "@medusajs/framework/zod"
import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"
import {
  beginReturnOrderWorkflow,
  requestItemReturnWorkflow,
  confirmReturnRequestWorkflow,
  cancelReturnRequestWorkflow,
  getOrderDetailWorkflow,
} from "@medusajs/medusa/core-flows"
import { assertOrderOwnership, ORDER_DETAIL_FIELDS } from "../../order-ownership"

export const PostVendorReturnSchema = z.object({
  items: z.array(z.object({
    /** Identifiant de la ligne de commande (order line item), pas du produit. */
    id: z.string().min(1),
    quantity: z.number().int().positive(),
    reason_id: z.string().optional(),
    internal_note: z.string().max(500).optional(),
  })).min(1),
  /** Visible par le client. */
  description: z.string().max(1000).optional(),
  /** Réservé au vendeur. */
  internal_note: z.string().max(1000).optional(),
  location_id: z.string().optional(),
}).strict()

type PostBody = z.infer<typeof PostVendorReturnSchema>

/** Retours déjà enregistrés sur cette commande. */
export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  await assertOrderOwnership(req, req.params.id)
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const { data: returns } = await query.graph({
    entity: "return",
    fields: [
      "id", "status", "order_id", "created_at", "received_at", "canceled_at",
      "items.id", "items.item_id", "items.quantity", "items.received_quantity",
    ],
    filters: { order_id: req.params.id },
  })

  res.json({ returns })
}

/**
 * Enregistre un retour sur une commande de la boutique.
 *
 * Le vendeur ne disposait d'aucun chemin pour traiter un renvoi : il pouvait
 * expédier, marquer livré, annuler — mais pas reprendre un article.
 *
 * On enchaîne les trois workflows du parcours admin (ouvrir → ajouter les
 * lignes → confirmer) plutôt que createAndCompleteReturnOrderWorkflow : ce
 * dernier est le parcours vitrine et impose une option d'expédition retour,
 * alors qu'un vendeur reprend souvent la marchandise en main propre.
 *
 * Le remboursement reste une action distincte (POST .../refund) : accepter un
 * retour et rendre l'argent ne se décident pas toujours en même temps.
 */
export const POST = async (req: AuthenticatedMedusaRequest<PostBody>, res: MedusaResponse) => {
  const orderId = req.params.id
  await assertOrderOwnership(req, orderId)

  const { items, description, internal_note, location_id } = req.validatedBody

  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { data: [order] } = await query.graph({
    entity: "order",
    // `items.*` complet : une sélection partielle ne renvoie pas les quantités,
    // et le contrôle ci-dessous passerait silencieusement à côté.
    fields: ["id", "status", "items.*", "items.detail"],
    filters: { id: orderId },
  })

  if (!order) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Order not found")
  }
  if (order.status === "canceled") {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Cette commande est annulée : il n'y a rien à retourner.",
    )
  }

  // Messages explicites plutôt que l'erreur générique du workflow, qui ne dit
  // pas laquelle des lignes envoyées est en cause.
  const byId = new Map<string, any>((order.items || []).map((i: any) => [i.id, i] as [string, any]))
  for (const item of items) {
    const line = byId.get(item.id)
    if (!line) {
      throw new MedusaError(
        MedusaError.Types.INVALID_DATA,
        `La ligne ${item.id} n'appartient pas à cette commande.`,
      )
    }
    const ordered = Number(line.quantity)
    if (Number.isFinite(ordered) && item.quantity > ordered) {
      throw new MedusaError(
        MedusaError.Types.INVALID_DATA,
        `Quantité retournée (${item.quantity}) supérieure à la quantité commandée (${ordered}) pour « ${line.title} ».`,
      )
    }
  }

  const { result: orderChange } = await beginReturnOrderWorkflow(req.scope).run({
    input: {
      order_id: orderId,
      created_by: req.auth_context.actor_id,
      description,
      internal_note,
      location_id,
    },
  })

  const returnId = (orderChange as any)?.return_id
  if (!returnId) {
    throw new MedusaError(
      MedusaError.Types.UNEXPECTED_STATE,
      "Le retour n'a pas pu être ouvert.",
    )
  }

  // Les trois workflows ne forment pas une transaction : si l'ajout des lignes
  // ou la confirmation échoue — par exemple parce que la quantité dépasse ce
  // qui a été expédié —, le retour ouvert à l'étape précédente resterait en
  // base, vide et invisible pour le vendeur. On le referme nous-mêmes.
  try {
    await requestItemReturnWorkflow(req.scope).run({
      input: {
        return_id: returnId,
        items: items.map((i) => ({
          id: i.id,
          quantity: i.quantity,
          reason_id: i.reason_id,
          internal_note: i.internal_note,
        })),
      },
    })

    await confirmReturnRequestWorkflow(req.scope).run({
      input: { return_id: returnId, confirmed_by: req.auth_context.actor_id },
    })
  } catch (err) {
    try {
      await cancelReturnRequestWorkflow(req.scope).run({ input: { return_id: returnId } })
    } catch (cleanupErr) {
      console.error(`Failed to roll back dangling return ${returnId}:`, cleanupErr)
    }
    throw err
  }

  const [{ data: [createdReturn] }, { result: updatedOrder }] = await Promise.all([
    query.graph({
      entity: "return",
      fields: [
        "id", "status", "order_id", "created_at", "received_at", "canceled_at",
        "items.id", "items.item_id", "items.quantity", "items.received_quantity",
      ],
      filters: { id: returnId },
    }),
    getOrderDetailWorkflow(req.scope).run({
      input: { order_id: orderId, fields: ORDER_DETAIL_FIELDS },
    }),
  ])

  res.status(201).json({ return: createdReturn, order: updatedOrder })
}
