import { SubscriberArgs, type SubscriberConfig } from "@medusajs/framework"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import MarketplaceModuleService from "../modules/marketplace/service"

export default async function vendorPayoutOnDeliveryHandler({
  event: { data },
  container,
}: SubscriberArgs<{ id: string, order_id: string }>) {
  const orderId = data.order_id || data.id;

  if (!orderId) return;

  const orderModule = container.resolve("order")
  const marketplaceModule = container.resolve("marketplace") as MarketplaceModuleService
  const query = container.resolve(ContainerRegistrationKeys.QUERY)

  try {
    // 1. Récupérer la commande avec ses articles
    const order = await orderModule.retrieveOrder(orderId, {
      relations: ["items"]
    })

    // 2. Parcourir les articles pour rémunérer les vendeurs
    for (const item of order.items) {
      // Tenter de récupérer le vendeur depuis les métadonnées de l'article
      let vendorId = item.metadata?.vendor_id as string | undefined;
      
      // Si absent, interroger la relation produit-vendeur via le Query Graph
      if (!vendorId && item.product_id) {
        const { data: products } = await query.graph({
          entity: "product",
          fields: ["id", "vendor.id"],
          filters: { id: item.product_id }
        })
        vendorId = products[0]?.vendor?.id
      }
      
      if (vendorId) {
        // Logique de commission : la marketplace garde 10%
        const commissionRate = 0.10; 
        
        // Calcul du montant qui revient au vendeur (Prix unitaire * quantité - commission)
        const itemTotal = Number(item.unit_price) * Number(item.quantity);
        const amountForVendor = Math.round(itemTotal * (1 - commissionRate));
        
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
  // Événement déclencheur : déclenché au moment de la livraison du colis
  event: "order.fulfillment_delivered", 
}

