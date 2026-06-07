import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http";
import { listShippingOptionsForCartWorkflow } from "@medusajs/core-flows";

export const GET = async (req: MedusaRequest, res: MedusaResponse) => {
  try {
    const { cart_id } = req.query;

    if (!cart_id || typeof cart_id !== "string") {
      return res.status(400).json({ message: "cart_id is required" });
    }

    // Use Medusa's core workflow to get available shipping options for this cart
    const workflow = listShippingOptionsForCartWorkflow(req.scope);
    const { result: shippingOptions } = await workflow.run({
      input: {
        cart_id,
        is_return: false,
        fields: [
          "id",
          "name",
          "price_type",
          "amount",
          "provider_id",
          "delivery_companies.id",
          "delivery_companies.name",
          "delivery_companies.logo",
          "delivery_companies.phone",
          "delivery_companies.email",
          "delivery_companies.website",
          "delivery_companies.is_active"
        ]
      },
    });

    // Group shipping options by company
const companyMap = new Map<string, any>();

shippingOptions.forEach((so: any) => {
  const companies = so.delivery_companies || [];
  companies.filter((c: any) => c && c.id).forEach((c: any) => {
    if (!companyMap.has(c.id)) {
      companyMap.set(c.id, {
        ...c,
        shipping_options: []
      });
    }

    // Add this shipping option to the company's list
    // We create a slim version of the shipping option to avoid circular/bloated data
    const slimShippingOption = {
      id: so.id,
      name: so.name,
      price_type: so.price_type,
      amount: so.amount,
      provider_id: so.provider_id
    };

    companyMap.get(c.id).shipping_options.push(slimShippingOption);
  });
});

const uniqueCompanies = Array.from(companyMap.values());
console.log(uniqueCompanies)

res.json({
  delivery_companies: uniqueCompanies
});
  } catch (error: any) {
    console.error("Error fetching delivery companies:", error);
    res.status(500).json({ message: "Failed to fetch delivery companies" });
  }
};
