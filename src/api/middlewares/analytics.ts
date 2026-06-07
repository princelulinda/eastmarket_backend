import { 
  MedusaRequest, 
  MedusaResponse, 
  MedusaNextFunction 
} from "@medusajs/framework/http"
import { ContainerRegistrationKeys, Modules } from "@medusajs/framework/utils"
import AnalyticsService from "../modules/analytics/service"

export async function trackProductClick(
  req: MedusaRequest,
  res: MedusaResponse,
  next: MedusaNextFunction
) {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const analyticsService = req.scope.resolve("analytics") as AnalyticsService
  
  // Only track product detail pages
  if (req.path.startsWith("/store/products/") && req.method === "GET") {
    const productId = req.params.id
    
    // Attempt to get source and campaign from query params or referer
    const utmSource = req.query.utm_source as string
    const utmCampaign = req.query.utm_campaign as string
    const referer = req.headers.referer || ""
    
    let source = utmSource
    if (!source && referer) {
      try {
        source = new URL(referer).hostname
      } catch (e) {
        source = "direct"
      }
    }

    // Resolve vendor_id for the product
    const { data: [product] } = await query.graph({
      entity: "product",
      fields: ["id", "vendor.id"],
      filters: { id: productId }
    })

    if (product && product.vendor) {
      await analyticsService.createAnalyticsEvents({
        product_id: productId,
        vendor_id: product.vendor.id,
        source: source || "direct",
        campaign: utmCampaign || null,
        event_type: "click"
      })
    }
  }
  
  next()
}
