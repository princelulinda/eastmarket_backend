import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { REVIEW_MODULE } from "../../../modules/review"
import { ReviewModuleService } from "../../../modules/review/service"
import { notifyVendor } from "../../../modules/notification-center/notify"

export async function POST(req: MedusaRequest, res: MedusaResponse) {
  const reviewService: ReviewModuleService = req.scope.resolve(REVIEW_MODULE)
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const { product_id, customer_id, rating, content, images } = (req.body || {}) as any

  const [review] = await (reviewService as any).createReviews([{
    product_id,
    customer_id,
    rating,
    content,
    images: Array.isArray(images) && images.length > 0 ? images : null,
  } as any])

  // Le vendeur est déduit du produit, pas repris du corps de la requête :
  // un `vendor_id` fourni par le client permettait d'adresser la notification
  // à n'importe quelle boutique.
  const { data: [product] } = await query.graph({
    entity: "product",
    fields: ["id", "title", "vendor.id"],
    filters: { id: product_id },
  })

  const vendorId = (product as any)?.vendor?.id

  if (vendorId) {
    try {
      // `notifyVendor` déclenche les trois canaux — in-app, socket et push.
      // L'ancien appel direct à `createNotification` ne créait que l'entrée
      // in-app : le téléphone du vendeur restait muet.
      await notifyVendor(req.scope as any, {
        vendorId,
        type: "new_review",
        title: rating >= 4 ? "Nouvel avis positif" : "Nouvel avis",
        body: product?.title
          ? `${rating}★ sur « ${product.title} ».`
          : `Un client a laissé un avis de ${rating} étoiles sur votre produit.`,
        data: { review_id: review.id, product_id, rating },
        pushCategory: "messages",
      })
    } catch (err) {
      // L'avis est enregistré : un échec de notification ne doit pas l'annuler.
      console.error(`Failed to notify vendor ${vendorId} of new review:`, err)
    }
  }

  res.json({ review })
}
