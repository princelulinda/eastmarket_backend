import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"

export const GET = async (req: MedusaRequest, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const { data: [vendor] } = await query.graph({
    entity: "vendor",
    fields: [
      "id", "handle", "name", "logo", "cover_image", "description",
      "phone", "email", "website",
      "country", "city", "address",
      "founded_year", "business_type", "main_products", "employee_count",
      "social_links", "is_verified", "response_rate", "response_time",
    ],
    filters: { id: req.params.id }
  })

  if (!vendor) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Vendor not found")
  }

  res.json({ vendor })
}
