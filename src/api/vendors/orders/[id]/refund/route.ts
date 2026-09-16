import { z } from "@medusajs/framework/zod"
import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"
import { refundPaymentWorkflow, getOrderDetailWorkflow } from "@medusajs/medusa/core-flows"
import { assertOrderOwnership, ORDER_DETAIL_FIELDS } from "../../order-ownership"
import { MARKETPLACE_MODULE } from "../../../../../modules/marketplace"
import MarketplaceModuleService from "../../../../../modules/marketplace/service"
import { vendorShare } from "../../../../../modules/marketplace/commission"
import { getVendorContext } from "../../../vendor-context"

export const PostVendorRefundSchema = z.object({
  /** Montant en centimes. Omis, la totalité du paiement capturé est remboursée. */
  amount: z.number().int().positive().optional(),
  note: z.string().max(500).optional(),
}).strict()

type PostBody = z.infer<typeof PostVendorRefundSchema>

/**
 * Rembourse tout ou partie d'une commande.
 *
 * Le remboursement reprend au vendeur exactement la part qui lui avait été
 * créditée à la livraison (voir modules/marketplace/commission.ts). Sans ce
 * débit, un vendeur remboursé garderait l'argent de la vente.
 */
export const POST = async (req: AuthenticatedMedusaRequest<PostBody>, res: MedusaResponse) => {
  const orderId = req.params.id
  await assertOrderOwnership(req, orderId)

  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const marketplaceModule: MarketplaceModuleService = req.scope.resolve(MARKETPLACE_MODULE)

  const { data: [order] } = await query.graph({
    entity: "order",
    fields: [
      "id", "currency_code",
      "payment_collections.id",
      "payment_collections.payments.id",
      "payment_collections.payments.amount",
      "payment_collections.payments.captured_at",
      "payment_collections.payments.canceled_at",
      "payment_collections.payments.refunds.amount",
    ],
    filters: { id: orderId },
  })

  if (!order) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Order not found")
  }

  // On ne peut rembourser qu'un paiement effectivement encaissé.
  const payments = (order.payment_collections || [])
    .flatMap((pc: any) => pc?.payments || [])
    .filter((p: any) => p?.captured_at && !p?.canceled_at)

  if (payments.length === 0) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Aucun paiement encaissé sur cette commande : il n'y a rien à rembourser.",
    )
  }

  const payment = payments[0]
  const alreadyRefunded = (payment.refunds || [])
    .reduce((sum: number, r: any) => sum + (Number(r?.amount) || 0), 0)
  const refundable = (Number(payment.amount) || 0) - alreadyRefunded

  if (refundable <= 0) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      "Cette commande est déjà intégralement remboursée.",
    )
  }

  const amount = req.validatedBody.amount ?? refundable

  if (amount > refundable) {
    throw new MedusaError(
      MedusaError.Types.INVALID_DATA,
      `Montant trop élevé : il reste ${refundable} à rembourser sur ce paiement.`,
    )
  }

  await refundPaymentWorkflow(req.scope).run({
    input: {
      payment_id: payment.id,
      amount,
      note: req.validatedBody.note,
      created_by: req.auth_context.actor_id,
    },
  })

  // Reprise de la part vendeur. Le débit peut rendre la balance négative :
  // un remboursement client ne doit jamais être bloqué parce que le vendeur a
  // déjà retiré son argent.
  let vendorDebit = 0
  const vendor = await getVendorContext(req)
  if (vendor) {
    vendorDebit = vendorShare(amount)
    try {
      await marketplaceModule.debitVendorBalance(vendor.id, vendorDebit)
    } catch (err) {
      // Le client est remboursé : on ne défait pas l'opération pour un
      // problème de compteur, mais l'écart doit être visible.
      console.error(`Refund ${amount} on order ${orderId}: failed to debit vendor ${vendor.id}:`, err)
      vendorDebit = 0
    }
  }

  const { result: updatedOrder } = await getOrderDetailWorkflow(req.scope).run({
    input: { order_id: orderId, fields: ORDER_DETAIL_FIELDS },
  })

  res.json({
    order: updatedOrder,
    refund: {
      amount,
      currency_code: order.currency_code,
      remaining_refundable: refundable - amount,
      vendor_balance_debited: vendorDebit,
    },
  })
}
