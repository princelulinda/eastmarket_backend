import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { REVIEW_MODULE } from "../../../../../modules/review"
import { ReviewModuleService } from "../../../../../modules/review/service"

export async function GET(req: MedusaRequest, res: MedusaResponse) {
  const reviewService: ReviewModuleService = req.scope.resolve(REVIEW_MODULE)
  const product_id = req.params.id

  const reviews = await reviewService.listReviews({
    product_id,
  })

  res.json({ reviews })
}
