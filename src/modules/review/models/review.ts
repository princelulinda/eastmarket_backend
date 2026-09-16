import { model } from "@medusajs/framework/utils"

const Review = model.define("review", {
  id: model.id().primaryKey(),
  product_id: model.text(),
  customer_id: model.text(),
  rating: model.number(), // 1 to 5
  content: model.text().nullable(),
  images: model.json().nullable(), // string[] of uploaded photo URLs
  // Réponse publique du vendeur. Affichée sous l'avis en vitrine : une boutique
  // qui répond à ses avis est le signal de sérieux le plus lisible pour l'acheteur.
  vendor_reply: model.text().nullable(),
  vendor_replied_at: model.dateTime().nullable(),
})

export default Review
