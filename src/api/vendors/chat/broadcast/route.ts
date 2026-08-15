import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"
import { CHAT_MODULE } from "../../../../modules/chat"
import ChatModuleService from "../../../../modules/chat/service"
import { postBroadcastAnnouncement } from "../../../../modules/chat/broadcast"

const resolveVendor = async (req: AuthenticatedMedusaRequest) => {
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id", "vendor.name"],
    filters: { id: [req.auth_context.actor_id] },
  })
  if (!vendorAdmin?.vendor?.id) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Vendor not found")
  }
  return vendorAdmin.vendor as { id: string; name?: string }
}

/** Récupère le canal de diffusion du vendeur (+ ses derniers messages) */
export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const chatService: ChatModuleService = req.scope.resolve(CHAT_MODULE)
  const vendor = await resolveVendor(req)

  const conversation = await chatService.findOrCreateBroadcastConversation(vendor.id)
  const messages = await chatService.getMessages(
    conversation.id,
    Number(req.query.limit) || 50,
    Number(req.query.offset) || 0
  )

  res.json({ conversation, messages })
}

/** Publie une annonce dans le canal et notifie tous les abonnés */
export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const vendor = await resolveVendor(req)

  const body = req.body as {
    content?: string
    type?: string
    file_url?: string
    metadata?: Record<string, unknown>
  }

  if (!body.content && !body.file_url) {
    throw new MedusaError(MedusaError.Types.INVALID_DATA, "content or file_url required")
  }

  const { conversation, message } = await postBroadcastAnnouncement(req.scope, vendor.id, {
    content: body.content || "",
    type: body.type || "text",
    file_url: body.file_url,
    metadata: body.metadata,
    vendorName: vendor.name,
  })

  res.status(201).json({ message, conversation })
}
