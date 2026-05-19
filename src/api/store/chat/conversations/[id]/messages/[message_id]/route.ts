import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"
import { CHAT_MODULE } from "../../../../../../../modules/chat"
import ChatModuleService from "../../../../../../../modules/chat/service"

export const DELETE = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const chatService: ChatModuleService = req.scope.resolve(CHAT_MODULE)
  const conversationId = req.params.id
  const messageId = req.params.message_id

  // 1. Récupérer la conversation pour vérification de l'appartenance
  let conversation
  try {
    conversation = await chatService.retrieveConversation(conversationId)
  } catch {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Conversation not found")
  }

  if (conversation.customer_id !== req.auth_context.actor_id) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Conversation not found")
  }

  // 2. Vérifier que le message appartient bien à la conversation
  const message = await chatService.retrieveMessage(messageId)
  if (message.conversation_id !== conversationId) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Message not found in this conversation")
  }

  // 3. Suppression logique (soft delete)
  await chatService.softDeleteMessage(messageId)

  res.status(200).json({ success: true, message_id: messageId })
}
