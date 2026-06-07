import { 
  AuthenticatedMedusaRequest, 
  MedusaResponse
} from "@medusajs/framework/http"
import { z } from "@medusajs/framework/zod"
import createDeliveryCompanyWorkflow from "../../../workflows/delivery/create-delivery-company"
import linkShippingCompanyWorkflow from "../../../workflows/delivery/link-shipping-company"
import { DELIVERY_MODULE } from "../../../modules/delivery"
import DeliveryModuleService from "../../../modules/delivery/service"

export const PostAdminCreateDeliveryCompanySchema = z.object({
  name: z.string(),
  logo: z.string().optional(),
  phone: z.string().optional(),
  email: z.string().email(),
  website: z.string().optional(),
  is_active: z.boolean().optional(),
  metadata: z.record(z.any()).optional(),
  shipping_option_ids: z.array(z.string()).optional(),
})

type RequestBody = z.infer<typeof PostAdminCreateDeliveryCompanySchema>

export const POST = async (
  req: AuthenticatedMedusaRequest<RequestBody>,
  res: MedusaResponse
) => {
  const { shipping_option_ids, ...companyData } = req.validatedBody

  const { result } = await createDeliveryCompanyWorkflow(req.scope)
    .run({
      input: companyData
    })
    
  const companyId = (result.company as any).id;

  if (shipping_option_ids && shipping_option_ids.length > 0) {
    for (const optionId of shipping_option_ids) {
        await linkShippingCompanyWorkflow(req.scope).run({
            input: {
                shipping_option_id: optionId,
                delivery_company_id: companyId
            }
        });
    }
  }

  res.status(201).json({
    delivery_company: result.company,
  })
}

export const GET = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const deliveryModuleService: DeliveryModuleService = 
    req.scope.resolve(DELIVERY_MODULE)

  const [companies, count] = await deliveryModuleService.listAndCountDeliveryCompanies(
    {},
    {
      relations: ["drivers"],
    }
  )

  res.json({
    delivery_companies: companies,
    count,
  })
}
