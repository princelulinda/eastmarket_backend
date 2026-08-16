import {
  createStep,
  StepResponse,
  createWorkflow,
  transform,
  WorkflowResponse,
} from "@medusajs/framework/workflows-sdk"
import { createCampaignsWorkflow, createPromotionsWorkflow } from "@medusajs/core-flows"
import { PromotionStatus, PromotionType } from "@medusajs/framework/utils"
import { FLASH_SALE_MODULE } from "../../../modules/flash-sale"
import FlashSaleModuleService from "../../../modules/flash-sale/service"

export type CreateFlashSaleInput = {
  vendor_id?: string
  title: string
  banner_color?: string
  // Omit/empty to target the entire vendor_id catalog instead of a curated list.
  product_ids?: string[]
  discount_type: "percentage" | "fixed"
  discount_value: number
  starts_at: Date
  ends_at: Date
}

function generateIdentifier(): string {
  return `FLASH-${Math.random().toString(36).slice(2, 8).toUpperCase()}`
}

const createFlashSaleRecordStep = createStep(
  "create-flash-sale-record-step",
  async (
    input: { promotionId: string; campaignId: string; saleInput: CreateFlashSaleInput },
    { container }
  ) => {
    const service = container.resolve(FLASH_SALE_MODULE) as FlashSaleModuleService

    const sale = await service.createFlashSales({
      vendor_id: input.saleInput.vendor_id ?? null,
      title: input.saleInput.title,
      banner_color: input.saleInput.banner_color ?? null,
      // model.json() is typed as Record<string, unknown> by the DML, but this field
      // actually stores a string[] of product ids — cast to match the JSON column's real shape.
      product_ids: (input.saleInput.product_ids && input.saleInput.product_ids.length > 0 ? input.saleInput.product_ids : null) as unknown as Record<string, unknown> | null,
      promotion_id: input.promotionId,
      campaign_id: input.campaignId,
      discount_type: input.saleInput.discount_type,
      discount_value: input.saleInput.discount_value,
      starts_at: input.saleInput.starts_at,
      ends_at: input.saleInput.ends_at,
      is_active: true,
    })

    return new StepResponse(sale, sale.id)
  },
  async (saleId, { container }) => {
    if (!saleId) return
    const service = container.resolve(FLASH_SALE_MODULE) as FlashSaleModuleService
    await service.deleteFlashSales(saleId)
  }
)

const createFlashSaleWorkflow = createWorkflow(
  "create-flash-sale",
  (input: CreateFlashSaleInput) => {
    const campaignPayload = transform({ input }, (data) => ({
      name: data.input.title,
      campaign_identifier: generateIdentifier(),
      starts_at: data.input.starts_at,
      ends_at: data.input.ends_at,
    }))

    const campaigns = createCampaignsWorkflow.runAsStep({
      input: { campaignsData: [campaignPayload] },
    })

    const promotionPayload = transform({ input, campaigns }, (data) => {
      const hasProductList = !!data.input.product_ids && data.input.product_ids.length > 0
      const targetRule = hasProductList
        ? { attribute: "items.product_id", operator: "in" as const, values: data.input.product_ids as string[] }
        : { attribute: "items.vendor_id", operator: "eq" as const, values: [data.input.vendor_id as string] }

      return {
        code: generateIdentifier(),
        type: PromotionType.STANDARD,
        status: PromotionStatus.ACTIVE,
        is_automatic: true, // applies automatically to matching cart items, no code needed
        campaign_id: data.campaigns[0].id,
        application_method: {
          type: data.input.discount_type,
          value: data.input.discount_value,
          allocation: "across" as const,
          target_type: "items" as const,
          target_rules: [targetRule],
        },
      }
    })

    const promotions = createPromotionsWorkflow.runAsStep({
      input: { promotionsData: [promotionPayload] },
    })

    const sale = createFlashSaleRecordStep({
      promotionId: promotions[0].id,
      campaignId: campaigns[0].id,
      saleInput: input,
    })

    return new WorkflowResponse(sale)
  }
)

export default createFlashSaleWorkflow
