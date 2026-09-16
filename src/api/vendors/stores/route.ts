import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"

/**
 * GET /vendors/stores
 *
 * Paramètres de la boutique Medusa hôte : devises supportées, canal et région
 * par défaut. L'app vendeur s'en sert pour afficher les montants dans la bonne
 * devise et nommer la plateforme.
 */
export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const { data: stores } = await query.graph({
    entity: "store",
    fields: [
      "id", "name", "default_sales_channel_id", "default_region_id",
      "default_location_id", "metadata", "created_at", "updated_at",
      "supported_currencies.*", "supported_currencies.currency.*",
    ],
  })

  res.json({
    stores: stores || [],
    count: stores?.length ?? 0,
    offset: 0,
    limit: stores?.length ?? 0,
  })
}
