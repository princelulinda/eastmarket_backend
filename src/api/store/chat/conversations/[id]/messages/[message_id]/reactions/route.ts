import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import { CHAT_MODULE } from "../../../../../../../../modules/chat"
import ChatModuleService from "../../../../../../../../modules/chat/service"
import { getIO } from "../../../../../../../../modules/socket/service"
import { FOLLOW_MODULE } from "../../../../../../../../modules/follow"

export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const chatService: ChatModuleService = req.scope.resolve(CHAT_MODULE)
  const conversationId = req.params.id
  const messageId = req.params.message_id
  const { emoji } = req.body as { emoji?: string }

  if (!emoji) {
    throw new MedusaError(MedusaError.Types.INVALID_DATA, "emoji is required")
  }

  let conversation
  try {
    conversation = await chatService.retrieveConversation(conversationId)
  } catch {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Conversation not found")
  }

  if ((conversation as any).type === "broadcast") {
    const followService: any = req.scope.resolve(FOLLOW_MODULE)
    const isFollower = await followService.isFollowing(
      req.auth_context.actor_id,
      conversation.vendor_id
    )
    if (!isFollower) {
      throw new MedusaError(MedusaError.Types.NOT_FOUND, "Conversation not found")
    }
  } else if (conversation.customer_id !== req.auth_context.actor_id) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Conversation not found")
  }

  const message = await chatService.retrieveMessage(messageId)
  if (message.conversation_id !== conversationId) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Message not found in this conversation")
  }

  const result = await chatService.addReaction(
    messageId,
    "customer",
    req.auth_context.actor_id,
    emoji
  )

  const io = getIO()
  if (io) {
    io.to(`conversation:${conversationId}`).emit("reaction_added", {
      conversation_id: conversationId,
      message_id: messageId,
      reactions: result.reactions,
      actor_type: "customer",
      actor_id: req.auth_context.actor_id,
      emoji,
    })
  }

  res.status(200).json({ message_id: messageId, reactions: result.reactions })
}
