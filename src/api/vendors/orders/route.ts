import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http";
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { getOrdersListWorkflow } from "@medusajs/medusa/core-flows"
import { parseListParams, parseDateRange, paginationMeta } from "../list-params"

/** Champs de la liste. Volontairement plus légers que ceux du détail d'une commande. */
const LIST_FIELDS = [
  // Sans ces champs, la liste n'affichait ni numéro de commande, ni date, ni
  // client : impossible d'en faire un tableau exploitable.
  "display_id",
  "created_at",
  "email",
  "currency_code",
  "customer.id",
  "customer.first_name",
  "customer.last_name",
  "metadata",
  "total",
  "subtotal",
  "shipping_total",
  "tax_total",
  "items.*",
  "items.tax_lines",
  "items.adjustments",
  "items.variant",
  "items.variant.product",
  "items.detail",
  "shipping_methods",
  "payment_collections",
  "fulfillments",
]

const SORTABLE = ["created_at", "updated_at", "display_id"]

export const GET = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const params = parseListParams(req, { sortable: SORTABLE, defaultOrder: "-created_at" })
  const { status } = req.query as Record<string, string | undefined>

  // Seulement les identifiants : charger `vendor.orders.*` rapatriait toutes les
  // commandes de la boutique en entier avant même de savoir lesquelles afficher.
  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.orders.id"],
    filters: {
      id: [req.auth_context.actor_id]
    }
  })

  const orderIds = (vendorAdmin?.vendor?.orders || [])
    .map((o: { id: string } | null) => o?.id)
    .filter(Boolean) as string[]

  if (orderIds.length === 0) {
    return res.json({ orders: [], ...paginationMeta(params, 0) })
  }

  const filters: Record<string, any> = { id: orderIds }

  if (status) {
    filters.status = status.includes(",") ? status.split(",") : status
  }

  const createdAt = parseDateRange(req)
  if (createdAt) {
    filters.created_at = createdAt
  }

  // Recherche : un numéro de commande saisi tel quel, sinon l'email du client.
  if (params.q) {
    const asNumber = Number.parseInt(params.q, 10)
    if (Number.isFinite(asNumber) && /^\d+$/.test(params.q)) {
      filters.display_id = asNumber
    } else {
      filters.email = { $ilike: `%${params.q}%` }
    }
  }

  const { result } = await getOrdersListWorkflow(req.scope)
    .run({
      input: {
        fields: LIST_FIELDS,
        variables: {
          filters,
          skip: params.offset,
          take: params.limit,
          order: params.order,
        }
      }
    })

  // Avec skip/take, remoteQuery renvoie { rows, metadata } ; sans, un tableau nu.
  const paginated = result as unknown as { rows?: any[]; metadata?: { count: number } }
  const orders = paginated.rows ?? (result as unknown as any[])
  const count = paginated.metadata?.count ?? orders.length

  res.json({
    orders,
    ...paginationMeta(params, count),
  })
}
