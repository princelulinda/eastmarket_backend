import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"

export const GET = async (req: MedusaRequest, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const { data: vendors } = await query.graph({
    entity: "vendor",
    fields: [
      "id", "handle", "name", "logo", "cover_image", "description",
      "country", "city", "business_type", "is_verified",
      "response_rate", "response_time", "founded_year", "employee_count",
    ],
  })

  res.json({ vendors })
}
