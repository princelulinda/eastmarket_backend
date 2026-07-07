import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"

export async function GET(
  req: MedusaRequest,
  res: MedusaResponse
) {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const countryCode = req.query.country_code as string

  if (!countryCode) {
    return res.status(400).json({
      message: "Le paramètre 'country_code' est requis (ex: ?country_code=BI)",
    })
  }

  try {
    // Dans Medusa, la relation est region -> countries
    // On va récupérer la région qui a ce pays dans sa liste de pays.
    const { data: regions } = await query.graph({
      entity: "region",
      fields: ["id", "name", "currency_code", "countries.*"],
      filters: {
        countries: {
          iso_2: countryCode.toLowerCase(),
        },
      },
    })

    if (!regions || regions.length === 0) {
      return res.status(404).json({
        message: `Aucune région (ou devise) trouvée pour le pays : ${countryCode}`,
      })
    }

    // On récupère également le store pour avoir toutes les devises supportées
    const { data: stores } = await query.graph({
      entity: "store",
      fields: ["id", "supported_currencies.*"],
    })
    
    const store = stores && stores.length > 0 ? stores[0] : null;
    const supportedCurrencies = store?.supported_currencies?.map((c: any) => c.currency_code) || [regions[0].currency_code];

    // On renvoie la première région correspondante
    const region = regions[0]

    return res.json({
      region: {
        id: region.id,
        name: region.name,
        currency_code: region.currency_code,
        supported_currencies: supportedCurrencies
      },
    })
  } catch (error) {
    return res.status(500).json({
      message: "Erreur lors de la récupération de la région",
      error: error instanceof Error ? error.message : String(error),
    })
  }
}
