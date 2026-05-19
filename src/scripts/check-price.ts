import { Modules } from "@medusajs/framework/utils";
import { MedusaContainer } from "@medusajs/framework/types";

export default async function (container: MedusaContainer) {
  const productModule = container.resolve(Modules.PRODUCT);
  const pricingModule = container.resolve(Modules.PRICING);

  const variantId = "variant_01KR61D29ZDQWQZ2BCXQ271RDB"; // Votre variante manuelle
  
  console.log("Checking variant:", variantId);

  // Essayer de récupérer la variante avec son price_set_id si disponible
  const variant = await productModule.retrieveProductVariant(variantId);
  console.log("Variant data:", JSON.stringify(variant, null, 2));

  // Vérifier si le PricingModule trouve des prix
  const prices = await pricingModule.calculatePrices({
    id: [variantId],
    context: { currency_code: "qar" },
  });
  console.log("Calculated prices:", JSON.stringify(prices, null, 2));
}
