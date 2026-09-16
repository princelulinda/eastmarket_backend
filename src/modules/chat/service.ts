import { MedusaService } from "@medusajs/framework/utils"
import { MedusaError } from "@medusajs/framework/utils"
import Conversation from "./models/conversation"
import Message from "./models/message"

export type MessageType =
  | "text"
  | "image"
  | "file"
  | "audio"
  | "product"
  | "offer"
  | "coupon"
  | "order_update"
  | "flash_sale"
  | "video"
  | "system"

type CreateMessageInput = {
  /**
   * Id généré par le client (ULID). Permet à l'app d'afficher le message
   * immédiatement sous sa clé définitive : l'écho socket et la synchro delta
   * retombent alors sur la même clé, sans doublon ni réconciliation.
   * Omis, l'id est généré par Medusa comme avant.
   */
  id?: string
  conversation_id: string
  sender_type: "customer" | "vendor"
  sender_id: string
  content: string
  type?: MessageType
  file_url?: string
  reply_to_id?: string
  metadata?: Record<string, unknown>
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

  /** Canal de diffusion du vendeur (un seul par vendeur, créé à la volée). */
  async findOrCreateBroadcastConversation(vendorId: string) {
    const existing = await this.listConversations({
      vendor_id: vendorId,
      type: "broadcast",
    } as any)

    if (existing.length > 0) {
      return existing[0]
    }

    return await this.createConversations({
      customer_id: null,
      vendor_id: vendorId,
      type: "broadcast",
    } as any)
  }

  async listConversationsByVendor(vendorId: string) {
    return await this.listConversations({ vendor_id: vendorId })
  }

  async sendMessage(data: CreateMessageInput) {
    const msgType = data.type || "text"

    if ((msgType === "image" || msgType === "file" || msgType === "audio") && !data.file_url) {
      throw new MedusaError(
        MedusaError.Types.INVALID_DATA,
        `file_url required for type ${msgType}`
      )
    }

    const message = await this.createMessages({
      ...(data.id ? { id: data.id } : {}),
      conversation_id: data.conversation_id,
      sender_type: data.sender_type,
      sender_id: data.sender_id,
      content: data.content,
      type: msgType,
      file_url: data.file_url || null,
      reply_to_id: data.reply_to_id || null,
      metadata: data.metadata || null,
      is_read: false,
    } as any)

    // Only update last_message_at — pass only id to avoid null FK errors
    await this.updateConversations({
      id: data.conversation_id,
      last_message_at: new Date(),
    } as any)

    return message
  }

  /**
   * `after` : synchronisation delta. On filtre sur updated_at (et non
   * created_at) pour que les modifications d'un message déjà connu du client
   * — is_read, delivered_at, reactions — redescendent elles aussi. Le tri
   * passe alors sur updated_at, sinon la pagination d'un delta serait
   * incohérente avec le filtre.
   */
  async getMessages(
    conversationId: string,
    limit = 50,
    offset = 0,
    after?: Date
  ) {
    const filters: Record<string, unknown> = { conversation_id: conversationId }
    if (after) {
      filters.updated_at = { $gt: after }
    }

    return await this.listMessages(filters as any, {
      take: limit,
      skip: offset,
      order: after ? { updated_at: "DESC" } : { created_at: "DESC" },
    })
  }

  /**
   * Compteurs de non-lus pour plusieurs conversations, en une seule requête.
   *
   * Les listes de conversations interrogeaient la base par conversation, et
   * chargeaient à chaque fois les lignes entières juste pour en prendre la
   * longueur. Sur une liste de 20 fils cela faisait 20 requêtes et le contenu
   * de tous les messages non lus transitait pour produire 20 entiers.
   *
   * `senderType` désigne l'expéditeur des messages à compter : pour un client
   * ce sont ceux du vendeur, et inversement.
   */
  async countUnreadByConversation(
    conversationIds: string[],
    senderType: "customer" | "vendor"
  ): Promise<Record<string, number>> {
    const counts: Record<string, number> = {}
    if (conversationIds.length === 0) {
      return counts
    }

    const unread = await this.listMessages(
      {
        conversation_id: conversationIds,
        sender_type: senderType,
        is_read: false,
      } as any,
      { select: ["id", "conversation_id"] } as any
    )

    for (const msg of unread as any[]) {
      // La conversation peut être exposée en colonne ou via la relation selon
      // la projection : on accepte les deux pour ne pas compter zéro en silence.
      const cid = msg.conversation_id ?? msg.conversation?.id
      if (cid) {
        counts[cid] = (counts[cid] ?? 0) + 1
      }
    }
    return counts
  }

  async markMessagesAsRead(conversationId: string, readerType: "customer" | "vendor") {
    const senderType = readerType === "customer" ? "vendor" : "customer"

    const unread = await this.listMessages({
      conversation_id: conversationId,
      sender_type: senderType,
      is_read: false,
    } as any)

    if (unread.length === 0) return

    // Lu implique distribué
    const now = new Date()
    await Promise.all(
      unread.map((msg: any) =>
        this.updateMessages({
          id: msg.id,
          is_read: true,
          delivered_at: msg.delivered_at || now,
        } as any)
      )
    )
  }

  async softDeleteMessage(messageId: string) {
    return await this.softDeleteMessages([messageId])
  }

  /** Marque comme distribués les messages reçus par `recipientType` dans une conversation. */
  async markMessagesAsDelivered(conversationId: string, recipientType: "customer" | "vendor") {
    const senderType = recipientType === "customer" ? "vendor" : "customer"

    const undelivered = await this.listMessages({
      conversation_id: conversationId,
      sender_type: senderType,
      delivered_at: null,
    } as any)

    if (undelivered.length === 0) return []

    const now = new Date()
    await Promise.all(
      undelivered.map((msg: any) =>
        this.updateMessages({ id: msg.id, delivered_at: now } as any)
      )
    )

    return undelivered.map((msg: any) => msg.id as string)
  }

  /**
   * À la connexion d'un utilisateur : marque comme distribués tous les messages
   * qui l'attendaient. Retourne { conversation_id, message_ids }[] pour notifier
   * les expéditeurs.
   */
  async markAllDeliveredForRecipient(
    recipientId: string,
    recipientType: "customer" | "vendor"
  ) {
    const conversations = await this.listConversations(
      recipientType === "customer"
        ? { customer_id: recipientId }
        : { vendor_id: recipientId }
    )

    const results: { conversation_id: string; message_ids: string[] }[] = []
    for (const conv of conversations) {
      const ids = await this.markMessagesAsDelivered(conv.id, recipientType)
      if (ids.length > 0) {
        results.push({ conversation_id: conv.id, message_ids: ids })
      }
    }
    return results
  }

  /**
   * Négociation : fait avancer le statut d'une offre.
   * pending  → (vendor)   accept / reject / counter
   * countered → (customer) accept / reject
   */
  async updateOfferStatus(
    messageId: string,
    actorType: "customer" | "vendor",
    action: "accept" | "reject" | "counter",
    amount?: number
  ) {
    const message = await this.retrieveMessage(messageId)

    if (message.type !== "offer") {
      throw new MedusaError(MedusaError.Types.INVALID_DATA, "Message is not an offer")
    }

    const metadata = { ...((message.metadata as Record<string, any>) || {}) }
    const status: string = metadata.status || "pending"

    const allowed =
      (actorType === "vendor" && status === "pending" &&
        ["accept", "reject", "counter"].includes(action)) ||
      (actorType === "customer" && status === "countered" &&
        ["accept", "reject"].includes(action))

    if (!allowed) {
      throw new MedusaError(
        MedusaError.Types.NOT_ALLOWED,
        `Action ${action} not allowed on offer with status ${status} for ${actorType}`
      )
    }

    if (action === "counter") {
      if (!amount || amount <= 0) {
        throw new MedusaError(MedusaError.Types.INVALID_DATA, "amount required for counter offer")
      }
      metadata.counter_amount = amount
      metadata.status = "countered"
    } else {
      metadata.status = action === "accept" ? "accepted" : "rejected"
      // Montant final = contre-offre si elle existait, sinon l'offre initiale
      if (metadata.status === "accepted") {
        metadata.final_amount = metadata.counter_amount ?? metadata.amount
      }
    }
    metadata.responded_at = new Date().toISOString()
    metadata.responded_by = actorType

    await this.updateMessages({ id: messageId, metadata } as any)

    return { message_id: messageId, metadata }
  }

  /**
   * Toggle une réaction : un même acteur qui ré-envoie le même emoji la retire.
   * Format stocké : { [emoji]: ["customer:cus_123", "vendor:ven_456"] }
   */
  async addReaction(
    messageId: string,
    actorType: "customer" | "vendor",
    actorId: string,
    emoji: string
  ) {
    const message = await this.retrieveMessage(messageId)

    const reactions: Record<string, string[]> =
      (message.reactions as Record<string, string[]>) || {}
    const actorKey = `${actorType}:${actorId}`

    // Un acteur n'a qu'une réaction par message : retirer les précédentes
    let removed = false
    for (const key of Object.keys(reactions)) {
      const idx = reactions[key].indexOf(actorKey)
      if (idx !== -1) {
        reactions[key].splice(idx, 1)
        if (key === emoji) removed = true
        if (reactions[key].length === 0) delete reactions[key]
      }
    }

    if (!removed) {
      reactions[emoji] = [...(reactions[emoji] || []), actorKey]
    }

    await this.updateMessages({
      id: messageId,
      reactions: Object.keys(reactions).length > 0 ? reactions : null,
    } as any)

    return { message_id: messageId, reactions }
  }
}

export default ChatModuleService
