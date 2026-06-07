import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { getIO } from "../../../modules/socket/service"
import { ContainerRegistrationKeys, Modules } from "@medusajs/framework/utils"

export async function POST(
  req: MedusaRequest,
  res: MedusaResponse
) {
  try {
    const payload = req.body as any
    const transactionId = payload.transaction_id
    const appReference = payload.app_reference
    const status = payload.status
    const io = getIO()

    const logger = req.scope.resolve("logger")
    const paymentModule = req.scope.resolve(Modules.PAYMENT)
    const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

    if (status === "SUCCESS") {
      logger.info(`[KashFlow Webhook] Processing success for transaction: ${transactionId}, Reference: ${appReference}`)

      // 1. Authorize the payment session in Medusa
      try {
        await paymentModule.authorizePaymentSession(transactionId, {
          context: {
            app_reference: appReference,
          },
        })
        logger.info(`[KashFlow Webhook] Payment session ${transactionId} authorized successfully.`)
      } catch (authError) {
        logger.error(`[KashFlow Webhook] Failed to authorize payment session ${transactionId}:`, authError)
        return res.status(500).json({ error: "Failed to authorize payment" })
      }

      // 2. Resolve customer ID to notify via WebSocket
      let customerId = null;

      // Try finding customer via Cart
      const { data: carts } = await query.graph({
        entity: "cart",
        fields: ["customer_id"],
        filters: { id: [appReference] },
      })
      
      if (carts?.length > 0) {
        customerId = carts[0].customer_id
      } else {
        // Fallback: Try finding customer via Order
        const { data: orders } = await query.graph({
          entity: "order",
          fields: ["customer_id"],
          filters: { id: [appReference] },
        })
        if (orders?.length > 0) {
          customerId = orders[0].customer_id
        }
      }

      // 3. Notify user via WebSocket
      if (customerId && io) {
        io.to(`user:${customerId}`).emit("payment_status", {
          status: "success",
          transaction_id: transactionId,
          message: "Votre paiement a été confirmé avec succès."
        })
        logger.info(`[KashFlow Webhook] Notification sent to client: ${customerId}`)
      }
    } else {
      logger.warn(`[KashFlow Webhook] Received status '${status}' for transaction: ${transactionId}`)
    }

    return res.status(200).json({ received: true })

  } catch (error) {
    console.error("Erreur Webhook KashFlow:", error)
    return res.status(500).json({ error: "Webhook Error" })
  }
}
