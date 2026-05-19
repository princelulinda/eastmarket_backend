import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, MedusaError } from "@medusajs/framework/utils"
import { CHAT_MODULE } from "../../../../../../modules/chat"
import ChatModuleService from "../../../../../../modules/chat/service"
import { getIO } from "../../../../../../modules/socket/service"

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const chatService: ChatModuleService = req.scope.resolve(CHAT_MODULE)
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id"],
    filters: { id: [req.auth_context.actor_id] }
  })

  let conversation
  try {
    conversation = await chatService.retrieveConversation(req.params.id)
  } catch {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Conversation not found")
  }

  if (conversation.vendor_id !== vendorAdmin.vendor.id) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Conversation not found")
  }

  const limit = Number(req.query.limit) || 50
  const offset = Number(req.query.offset) || 0

  const messages = await chatService.getMessages(req.params.id, limit, offset)

  res.json({ messages, count: messages.length, limit, offset })
}

export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const { id } = req.params
  const chatService: ChatModuleService = req.scope.resolve(CHAT_MODULE)
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const io = getIO()

  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["vendor.id"],
    filters: { id: [req.auth_context.actor_id] }
  })

  const conversation = await chatService.retrieveConversation(id)
  if (conversation.vendor_id !== vendorAdmin.vendor.id) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Conversation not found")
  }

  const message = await chatService.sendMessage({
    conversation_id: id,
    sender_type: "vendor",
    sender_id: vendorAdmin.vendor.id,
    content: req.body.content,
    type: req.body.type || "text",
    file_url: req.body.file_url,
  })

  if (io) {
    io.to(`conversation:${id}`).emit("message_received", {
      message,
      conversation_id: id,
    })
  }

  res.json({ message })
}
