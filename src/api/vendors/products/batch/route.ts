import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"
import {
  updateProductsWorkflow,
  deleteProductsWorkflow,
} from "@medusajs/medusa/core-flows"
import { z } from "zod"

/**
 * Actions groupées sur le catalogue.
 *
 * L'app vendeur devait sinon émettre une requête par produit : cinquante
 * allers-retours depuis un téléphone en 3G, dont certains échouent, laissant le
 * catalogue à moitié modifié sans que personne sache lesquels sont passés.
 */

export const PostVendorProductsBatchSchema = z.object({
  ids: z.array(z.string()).min(1).max(100),
  action: z.discriminatedUnion("type", [
    z.object({ type: z.literal("publish") }),
    z.object({ type: z.literal("unpublish") }),
    z.object({ type: z.literal("delete") }),
    z.object({
      type: z.literal("adjust_price"),
      /** Variation en pourcentage : -10 baisse de 10 %, 15 augmente de 15 %. */
      percent: z.number().min(-90).max(1000),
    }),
    z.object({
      type: z.literal("set_category"),
      category_id: z.string().nullable(),
    }),
  ]),
})

type Body = z.infer<typeof PostVendorProductsBatchSchema>

/** Ne renvoie que les identifiants qui appartiennent bien à la boutique. */
async function ownedIds(
  req: AuthenticatedMedusaRequest,
  requested: string[]
): Promise<string[]> {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const {
    data: [vendorAdmin],
  } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.products.id"],
    filters: { id: [req.auth_context.actor_id] },
  })

  const owned = new Set(
    (vendorAdmin?.vendor?.products || []).map((p: { id: string }) => p.id)
  )
  return requested.filter((id) => owned.has(id))
}

export const POST = async (
  req: AuthenticatedMedusaRequest<Body>,
  res: MedusaResponse
) => {
  const { ids, action } = req.validatedBody

  const targets = await ownedIds(req, ids)
  if (targets.length === 0) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "No matching product")
  }

  // Les identifiants écartés sont renvoyés explicitement : l'app doit pouvoir
  // dire « 3 produits sur 5 » plutôt que d'annoncer un succès complet.
  const skipped = ids.filter((id) => !targets.includes(id))

  if (action.type === "delete") {
    await deleteProductsWorkflow(req.scope).run({ input: { ids: targets } })
    return res.json({ updated: targets.length, skipped, ids: targets })
  }

  if (action.type === "publish" || action.type === "unpublish") {
    const status = action.type === "publish" ? "published" : "draft"
    await updateProductsWorkflow(req.scope).run({
      input: { products: targets.map((id) => ({ id, status: status as any })) },
    })
    return res.json({ updated: targets.length, skipped, ids: targets })
  }

  if (action.type === "set_category") {
    await updateProductsWorkflow(req.scope).run({
      input: {
        products: targets.map((id) => ({
          id,
          categories: action.category_id ? [{ id: action.category_id }] : [],
        })),
      },
    })
    return res.json({ updated: targets.length, skipped, ids: targets })
  }

  // ── Ajustement de prix ────────────────────────────────────────────────────
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { data: products } = await query.graph({
    entity: "product",
    fields: ["id", "variants.id", "variants.prices.amount", "variants.prices.currency_code"],
    filters: { id: targets },
  })

  const factor = 1 + action.percent / 100

  const updates = products.map((product: any) => ({
    id: product.id,
    variants: (product.variants || []).map((variant: any) => ({
      id: variant.id,
      prices: (variant.prices || []).map((price: any) => ({
        currency_code: price.currency_code,
        // Arrondi au centime, jamais en dessous de 1 : un prix à zéro rendrait
        // le produit gratuit en boutique.
        amount: Math.max(1, Math.round(price.amount * factor)),
      })),
    })),
  }))

  await updateProductsWorkflow(req.scope).run({ input: { products: updates as any } })

  res.json({ updated: targets.length, skipped, ids: targets })
}
