import { z } from "@medusajs/framework/zod"
import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { FLASH_SALE_MODULE } from "../../../modules/flash-sale"
import FlashSaleModuleService from "../../../modules/flash-sale/service"
import createFlashSaleWorkflow from "../../../workflows/flash-sale/create-flash-sale"
import { postBroadcastAnnouncement } from "../../../modules/chat/broadcast"

export const PostVendorFlashSaleSchema = z.object({
  title: z.string(),
  banner_color: z.string().optional(),
  // Omit or leave empty to run the sale across the vendor's entire catalog
  // instead of a curated product list.
  product_ids: z.array(z.string()).min(1).optional(),
  discount_type: z.enum(["percentage", "fixed"]),
  discount_value: z.number(),
  starts_at: z.coerce.date(),
  ends_at: z.coerce.date(),
}).strict()

type PostBody = z.infer<typeof PostVendorFlashSaleSchema>

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const service = req.scope.resolve(FLASH_SALE_MODULE) as FlashSaleModuleService

  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id"],
    filters: { id: [req.auth_context.actor_id] },
  })

  const sales = await service.listForVendor(vendorAdmin.vendor.id)
  res.json({ flash_sales: sales })
}

export const POST = async (req: AuthenticatedMedusaRequest<PostBody>, res: MedusaResponse) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id", "vendor.name"],
    filters: { id: [req.auth_context.actor_id] },
  })

  const { result: flashSale } = await createFlashSaleWorkflow(req.scope).run({
    input: { vendor_id: vendorAdmin.vendor.id, ...req.validatedBody },
  })

  // Annonce automatique dans le canal de diffusion du vendeur
  try {
    const { title, discount_type, discount_value, starts_at, ends_at } = req.validatedBody
    const discountLabel =
      discount_type === "percentage" ? `-${discount_value}%` : `-${discount_value}`
    await postBroadcastAnnouncement(req.scope, vendorAdmin.vendor.id, {
      content: `⚡ Flash sale : ${title} — jusqu'à ${discountLabel} !`,
      type: "flash_sale",
      metadata: {
        flash_sale_id: (flashSale as any)?.id,
        title,
        discount_type,
        discount_value,
        starts_at: starts_at?.toISOString?.() ?? starts_at,
        ends_at: ends_at?.toISOString?.() ?? ends_at,
      },
      vendorName: vendorAdmin.vendor.name,
    })
  } catch (err) {
    console.error("Failed to broadcast flash sale announcement:", err)
  }

  res.json({ flash_sale: flashSale })
}
