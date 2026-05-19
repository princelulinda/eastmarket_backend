import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { REVIEW_MODULE } from "../../../modules/review"
import { ReviewModuleService } from "../../../modules/review/service"
import { NOTIFICATION_MODULE } from "../../../modules/notification-center"
import NotificationCenterService from "../../../modules/notification-center/service"

export async function POST(req: MedusaRequest, res: MedusaResponse) {
  const reviewService: ReviewModuleService = req.scope.resolve(REVIEW_MODULE)
  const notificationService: NotificationCenterService = req.scope.resolve(NOTIFICATION_MODULE)
  
  const { product_id, customer_id, rating, content, vendor_id } = req.body

  const [review] = await reviewService.createReviews([{
    product_id,
    customer_id,
    rating,
    content,
  }])

  if (vendor_id) {
    await notificationService.createNotification({
      recipient_id: vendor_id,
      recipient_type: "vendor",
      type: "new_review",
      title: "Nouveau avis",
      body: `Un client a laissé un avis de ${rating} étoiles sur votre produit.`,
      data: { review_id: review.id, product_id },
    })
  }
  
  res.json({ review })
}
