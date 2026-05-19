import { MedusaService } from "@medusajs/framework/utils"
import { MedusaError } from "@medusajs/framework/utils"
import Conversation from "./models/conversation"
import Message from "./models/message"

type CreateMessageInput = {
  conversation_id: string
  sender_type: "customer" | "vendor"
  sender_id: string
  content: string
  type?: "text" | "image" | "file"
  file_url?: string
}

class ChatModuleService extends MedusaService({ Conversation, Message }) {

  async findOrCreateConversation(customerId: string, vendorId: string) {
    const existing = await this.listConversations({
      customer_id: customerId,
      vendor_id: vendorId,
    })

    if (existing.length > 0) {
      return existing[0]
    }

    return await this.createConversations({
      customer_id: customerId,
      vendor_id: vendorId,
    })
  }

  async listConversationsByCustomer(customerId: string) {
    return await this.listConversations({ customer_id: customerId })
  }

  async listConversationsByVendor(vendorId: string) {
    return await this.listConversations({ vendor_id: vendorId })
  }

  async sendMessage(data: CreateMessageInput) {
    const msgType = data.type || "text"

    if ((msgType === "image" || msgType === "file") && !data.file_url) {
      throw new MedusaError(
        MedusaError.Types.INVALID_DATA,
        `file_url required for type ${msgType}`
      )
    }

    const message = await this.createMessages({
      conversation_id: data.conversation_id,
      sender_type: data.sender_type,
      sender_id: data.sender_id,
      content: data.content,
      type: msgType,
      file_url: data.file_url || null,
      is_read: false,
    } as any)

    // Only update last_message_at — pass only id to avoid null FK errors
    await this.updateConversations({
      id: data.conversation_id,
      last_message_at: new Date(),
    } as any)

    return message
  }

  async getMessages(conversationId: string, limit = 50, offset = 0) {
    return await this.listMessages(
      { conversation_id: conversationId } as any,
      { take: limit, skip: offset, order: { created_at: "DESC" } }
    )
  }

  async markMessagesAsRead(conversationId: string, readerType: "customer" | "vendor") {
    const senderType = readerType === "customer" ? "vendor" : "customer"

    const unread = await this.listMessages({
      conversation_id: conversationId,
      sender_type: senderType,
      is_read: false,
    } as any)

    if (unread.length === 0) return

    await Promise.all(
      unread.map((msg: any) => this.updateMessages({ id: msg.id, is_read: true }))
    )
  }

  async softDeleteMessage(messageId: string) {
    return await this.softDeleteMessages([messageId])
  }
}

export default ChatModuleService
