import { z } from "@medusajs/framework/zod"
import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import updateVendorWorkflow from "../../../workflows/marketplace/update-vendor"

const SocialLinksSchema = z.object({
  instagram: z.string().optional(),
  facebook: z.string().optional(),
  whatsapp: z.string().optional(),
  twitter: z.string().optional(),
  linkedin: z.string().optional(),
  tiktok: z.string().optional(),
}).optional()

export const PutVendorMeSchema = z.object({
  name: z.string().optional(),
  logo: z.string().optional(),
  cover_image: z.string().optional(),
  description: z.string().optional(),
  phone: z.string().optional(),
  email: z.string().email().optional(),
  website: z.string().optional(),
  country: z.string().optional(),
  city: z.string().optional(),
  address: z.string().optional(),
  founded_year: z.number().int().min(1800).max(new Date().getFullYear()).optional(),
  business_type: z.enum(["manufacturer", "trader", "wholesaler", "retailer", "other"]).optional(),
  main_products: z.string().optional(),
  employee_count: z.enum(["1-10", "11-50", "51-200", "201-500", "500+"]).optional(),
  social_links: SocialLinksSchema,
  response_time: z.string().optional(),
}).strict()

type PutBody = z.infer<typeof PutVendorMeSchema>

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: [
      "vendor.id", "vendor.handle", "vendor.name", "vendor.logo",
      "vendor.cover_image", "vendor.description", "vendor.phone",
      "vendor.email", "vendor.website", "vendor.country", "vendor.city",
      "vendor.address", "vendor.founded_year", "vendor.business_type",
      "vendor.main_products", "vendor.employee_count", "vendor.social_links",
      "vendor.is_verified", "vendor.response_rate", "vendor.response_time",
      "vendor.admins.*"
    ],
    filters: { id: [req.auth_context.actor_id] }
  })

  res.json({ vendor: vendorAdmin.vendor })
}

export const PUT = async (req: AuthenticatedMedusaRequest<PutBody>, res: MedusaResponse) => {
  const { result } = await updateVendorWorkflow(req.scope).run({
    input: {
      vendor_admin_id: req.auth_context.actor_id,
      update: req.validatedBody
    }
  })

  res.json({ vendor: result.vendor })
}
