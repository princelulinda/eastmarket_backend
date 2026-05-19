import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { CHAT_MODULE } from "../../../../modules/chat"
import ChatModuleService from "../../../../modules/chat/service"

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const chatService: ChatModuleService = req.scope.resolve(CHAT_MODULE)
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  // Get vendor_id from the authenticated vendor admin
  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id"],
    filters: { id: [req.auth_context.actor_id] }
  })

  const conversations = await chatService.listConversationsByVendor(vendorAdmin.vendor.id)
  
  // Extraire les IDs des clients
  const customerIds = conversations
    .map(c => c.customer_id)
    .filter((id): id is string => id !== null)
  
  // Récupérer les détails des clients (via Customer Module)
  const { data: customers } = await query.graph({
    entity: "customer",
    fields: ["id", "first_name", "last_name", "email"],
    filters: { id: customerIds }
  })
  
  // Fusionner les données
  const enrichedConversations = conversations.map(conv => ({
    ...conv,
    customer: customers.find(c => c.id === conv.customer_id)
  }))

  res.json({ conversations: enrichedConversations })
}
