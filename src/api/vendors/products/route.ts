import { 
  AuthenticatedMedusaRequest, 
  MedusaResponse
} from "@medusajs/framework/http";
import { 
  HttpTypes,
} from "@medusajs/framework/types"
import { 
  ContainerRegistrationKeys
} from "@medusajs/framework/utils"
import createVendorProductWorkflow from "../../../workflows/marketplace/create-vendor-product";
import { parseListParams, paginationMeta } from "../list-params"

/** Champs de la liste produits. */
const LIST_FIELDS = [
  "*",
  "variants.*",
  "variants.prices.*",
  "variants.inventory.location_levels.*",
]

const SORTABLE = ["created_at", "updated_at", "title"]

export const GET = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const params = parseListParams(req, { sortable: SORTABLE, defaultOrder: "-created_at" })
  const { status, category_id } = req.query as Record<string, string | undefined>

  // Seulement les identifiants : `vendor.products.*` rapatriait tout le catalogue,
  // variantes, prix et niveaux de stock compris, avant toute pagination.
  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.products.id"],
    filters: { id: [req.auth_context.actor_id] },
  })

  const productIds = (vendorAdmin?.vendor?.products || [])
    .map((p: { id: string } | null) => p?.id)
    .filter(Boolean) as string[]

  if (productIds.length === 0) {
    return res.json({ products: [], ...paginationMeta(params, 0) })
  }

  const filters: Record<string, any> = { id: productIds }

  if (status) {
    filters.status = status.includes(",") ? status.split(",") : status
  }
  if (category_id) {
    filters["categories.id"] = category_id.includes(",") ? category_id.split(",") : category_id
  }
  if (params.q) {
    filters.title = { $ilike: `%${params.q}%` }
  }

  const { data: products, metadata } = await query.graph({
    entity: "product",
    fields: LIST_FIELDS,
    filters,
    pagination: {
      skip: params.offset,
      take: params.limit,
      order: params.order,
    },
  })

  // Injection de calculated_price pour compatibilité frontend via les données déjà chargées
  for (const product of products) {
    for (const variant of product.variants || []) {
      const v = variant as any
      const price = v.prices?.[0]
      if (price) {
        (variant as any).calculated_price = {
          calculated_amount: price.amount,
          original_amount: price.amount,
          currency_code: price.currency_code,
          is_calculated_price_price_list: false 
        }
      }
    }
  }

  res.json({
    products,
    ...paginationMeta(params, metadata?.count ?? products.length),
  })
}

export const POST = async (
  req: AuthenticatedMedusaRequest<HttpTypes.AdminCreateProduct>,
  res: MedusaResponse
) => {
  const { result } = await createVendorProductWorkflow(req.scope)
    .run({
      input: {
        vendor_admin_id: req.auth_context.actor_id,
        product: req.validatedBody
      }
    })

  res.json({
    product: result.product,
    // Vrai quand forceDraftUntilApproved a basculé le produit en brouillon :
    // le dashboard affiche un bandeau « en attente de vérification » plutôt
    // que de laisser le vendeur croire que son produit est en ligne.
    pending_verification: (req as any).pending_vendor_verification === true,
  })
}