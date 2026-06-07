import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"

export async function GET(
  req: MedusaRequest,
  res: MedusaResponse
) {
  try {
    // Récupérer la devise depuis les paramètres de l'URL (ex: ?currency=XAF)
    const currency = "bif";

    if (!currency) {
      // Si la devise n'est pas fournie par le Storefront, renvoyer une erreur 400
      return res.status(400).json({ error: "Le paramètre 'currency' est requis (ex: ?currency=XAF)" });
    }

    const apiUrl = process.env.KASHFLOW_API_URL || "https://api.kashflow-service.com"
    
    // Passer la devise à l'API de KashFlow via la Query String
    const response = await fetch(`${apiUrl}/api/v1/payment-methods?currency=${currency.toUpperCase()}`, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      }
    })

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}))
      throw new Error(errorData.message || `Erreur KashFlow: ${response.status}`)
    }

    const paymentMethods = await response.json()

    res.status(200).json({
      methods: paymentMethods
    })
  } catch (error: any) {
    console.error("Erreur API Payment Methods:", error)
    res.status(500).json({ error: error.message || "Erreur interne" })
  }
}
