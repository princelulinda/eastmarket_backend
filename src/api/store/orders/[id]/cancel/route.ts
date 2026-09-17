import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { cancelOrderWorkflow, getOrderDetailWorkflow } from "@medusajs/medusa/core-flows"
import {
  assertOrderCustomerOwnership,
  STORE_ORDER_DETAIL_FIELDS,
} from "../../order-ownership"

/**
 * POST /store/orders/:id/cancel — le client annule sa propre commande.
 *
 * L'app appelait déjà cette route, qui n'existait pas : le bouton « Annuler la commande »
 * tombait sur un 404 et affichait « Impossible d'annuler la commande ».
 *
 * `cancelOrderWorkflow` refuse une commande déjà expédiée ou déjà annulée, et remonte alors
 * son propre message — c'est lui qui décide de ce qui est annulable, pas cette route.
 */
export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const orderId = req.params.id

  await assertOrderCustomerOwnership(req, orderId)

  await cancelOrderWorkflow(req.scope).run({
    input: {
      order_id: orderId,
      canceled_by: req.auth_context.actor_id,
    },
  })

  const { result: order } = await getOrderDetailWorkflow(req.scope).run({
    input: { order_id: orderId, fields: STORE_ORDER_DETAIL_FIELDS },
  })

  res.json({ order })
}
