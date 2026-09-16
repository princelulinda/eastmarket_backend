import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"

/**
 * GET /vendors/sales-channels
 *
 * Canaux de vente disponibles. Les produits vendeurs sont publiés sur le canal
 * par défaut de la boutique (voir create-vendor-product), qui est donc listé en
 * premier — l'app s'en sert pour afficher la destination de publication.
 */
export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const { data: stores } = await query.graph({
    entity: "store",
    fields: ["default_sales_channel_id"],
  })
  const defaultId = stores?.[0]?.default_sales_channel_id

  const { data: salesChannels } = await query.graph({
    entity: "sales_channel",
    fields: ["id", "name", "description", "is_disabled"],
  })

  const available = (salesChannels || []).filter((c: any) => !c.is_disabled)
  available.sort((a: any, b: any) =>
    a.id === defaultId ? -1 : b.id === defaultId ? 1 : 0,
  )

  res.json({
    sales_channels: available,
    default_sales_channel_id: defaultId ?? null,
  })
}
