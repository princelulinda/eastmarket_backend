import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import { CHAT_MODULE } from "../../../../../../modules/chat"
import ChatModuleService from "../../../../../../modules/chat/service"
import { getIO } from "../../../../../../modules/socket/service"

export const GET = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const chatService: ChatModuleService = req.scope.resolve(CHAT_MODULE)

  let conversation
  try {
    conversation = await chatService.retrieveConversation(req.params.id)
  } catch {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Conversation not found")
  }

  if (conversation.customer_id !== req.auth_context.actor_id) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Conversation not found")
  }

  const limit = Number(req.query.limit) || 50
  const offset = Number(req.query.offset) || 0

  const messages = await chatService.getMessages(req.params.id, limit, offset)

  res.json({ messages, count: messages.length, limit, offset })
}

export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const chatService: ChatModuleService = req.scope.resolve(CHAT_MODULE)
  const { id } = req.params
  const io = getIO()

  let conversation
  try {
    conversation = await chatService.retrieveConversation(id)
  } catch {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Conversation not found")
  }

  if (conversation.customer_id !== req.auth_context.actor_id) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Conversation not found")
  }

  const body = req.body as { content?: string; type?: string; file_url?: string }

  const message = await chatService.sendMessage({
    conversation_id: id,
    sender_type: "customer",
    sender_id: req.auth_context.actor_id,
    content: body.content || "",
    type: (body.type as "text" | "image" | "file") || "text",
    file_url: body.file_url,
  })

  // Broadcast en temps réel à tous les membres de la room
  if (io) {
    io.to(`conversation:${id}`).emit("message_received", {
      message,
      conversation_id: id,
    })
  }

  res.status(201).json({ message })
}
