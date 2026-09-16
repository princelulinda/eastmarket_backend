import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { parseListParams, paginationMeta } from "../list-params"

const SORTABLE = ["created_at", "updated_at"]

/**
 * Tous les retours de la boutique, toutes commandes confondues.
 * `?status=requested` donne la file des retours à traiter.
 */
export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const params = parseListParams(req, { sortable: SORTABLE, defaultOrder: "-created_at" })
  const { status } = req.query as Record<string, string | undefined>

  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.orders.id"],
    filters: { id: [req.auth_context.actor_id] },
  })

  const orderIds = (vendorAdmin?.vendor?.orders || [])
    .map((o: any) => o?.id)
    .filter(Boolean) as string[]

  if (orderIds.length === 0) {
    return res.json({ returns: [], ...paginationMeta(params, 0) })
  }

  const filters: Record<string, any> = { order_id: orderIds }
  if (status) {
    filters.status = status.includes(",") ? status.split(",") : status
  }

  const { data: returns, metadata } = await query.graph({
    entity: "return",
    fields: [
      "id", "status", "order_id", "created_at", "received_at", "canceled_at",
      "order.display_id", "order.email", "order.currency_code",
      "items.id", "items.item_id", "items.quantity", "items.received_quantity",
    ],
    filters,
    pagination: {
      skip: params.offset,
      take: params.limit,
      order: params.order,
    },
  })

  res.json({
    returns,
    ...paginationMeta(params, metadata?.count ?? returns.length),
  })
}
