import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { MBIYOPAY_COUNTRIES } from "../../../../modules/mbiyopay/networks"

export async function GET(
  req: MedusaRequest,
  res: MedusaResponse
) {
  const country = (req.query.country as string | undefined)?.toUpperCase()

  if (!country) {
    return res.status(200).json({ countries: MBIYOPAY_COUNTRIES })
  }

  const match = MBIYOPAY_COUNTRIES.find((c) => c.country_code === country)

  if (!match) {
    return res.status(404).json({
      error: `Aucun réseau mobile money MBIYOPAY disponible pour le pays '${country}'`,
    })
  }

  return res.status(200).json({ country: match })
}
