import { SubscriberArgs, type SubscriberConfig } from "@medusajs/framework"
import MarketplaceModuleService from "../../modules/marketplace/service"

export default async function vendorPayoutOnDeliveryHandler({
  event: { data },
  container,
}: SubscriberArgs<{ id: string, order_id: string }>) {
  // En Medusa v2, selon l'événement, vous pourriez avoir { id: string } (ID de l'order)
  // ou { id, order_id } (ID du fulfillment et de l'order).
  // On récupère l'order_id (si on écoute fulfillment) ou l'id (si on écoute order)
  const orderId = data.order_id || data.id;

  if (!orderId) return;

  const orderModule = container.resolve("order")
  const marketplaceModule = container.resolve("marketplace") as MarketplaceModuleService

  try {
    // 1. Récupérer la commande avec ses articles
    const order = await orderModule.retrieveOrder(orderId, {
      relations: ["items"]
    })

    // 2. Parcourir les articles pour rémunérer les vendeurs
    for (const item of order.items) {
      // Supposons que vous stockez l'ID du vendeur dans les métadonnées de l'article
      const vendorId = item.metadata?.vendor_id as string | undefined;
      
      if (vendorId) {
        // Logique de commission : par exemple, la marketplace garde 10%
        const commissionRate = 0.10; 
        
        // Calcul du montant qui revient au vendeur (Prix unitaire * quantité - commission)
        const itemTotal = Number(item.unit_price) * Number(item.quantity);
        const amountForVendor = itemTotal * (1 - commissionRate);
        
        // 3. Libérer l'argent au vendeur
        await marketplaceModule.addVendorBalance(vendorId, amountForVendor)
        
        console.log(`[Marketplace] Vendeur ${vendorId} crédité de ${amountForVendor} suite à la livraison de la commande ${orderId}.`)
      }
    }
  } catch (error) {
    console.error(`Erreur lors du versement au vendeur pour la commande ${orderId}:`, error)
  }
}

export const config: SubscriberConfig = {
  // Événement déclencheur. 
  // Remplacez par "fulfillment.delivered" ou tout autre événement généré par votre module "delivery" 
  // lorsque le colis est officiellement remis au client.
  // Par défaut dans Medusa natif, "order.fulfillment_created" indique que l'expédition est gérée.
  event: "order.fulfillment_created", 
}
