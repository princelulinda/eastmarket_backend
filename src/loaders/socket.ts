import { Server } from "socket.io"
import jwt from "jsonwebtoken"
import { CHAT_MODULE } from "../modules/chat"
import ChatModuleService from "../modules/chat/service"
import { FOLLOW_MODULE } from "../modules/follow"
import { NOTIFICATION_MODULE } from "../modules/notification-center"
import NotificationCenterService from "../modules/notification-center/service"
import { sendPushNotification } from "../modules/notification-center/push-service"
import {
  setIO,
  getPresence,
  trackConnect,
  trackDisconnect,
} from "../modules/socket/service"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"

type JwtPayload = {
  actor_id: string
  actor_type: string
  auth_identity_id: string
}

export default async function socketAppLoader({
  container,
  app,
}: {
  container: any
  app: any
}) {
  const logger = container.resolve("logger")
  logger.info("[Socket.io] Application plugin loader started.")

  if ((globalThis as any).__medusaSocketHandlersRegistered) {
    logger.info("[Socket.io] Handlers already registered. Skipping.")
    return
  }

  const waitForIO = (): Promise<Server> => {
    return new Promise((resolve) => {
      const check = () => {
        const io = (globalThis as any).__medusaIo
        if (io) {
          resolve(io)
        } else {
          logger.info("[Socket.io] Waiting for globalThis.__medusaIo...")
          setTimeout(check, 200)
        }
      }
      check()
    })
  }

  const io = await waitForIO()
  ;(globalThis as any).__medusaSocketHandlersRegistered = true

  setIO(io)
  logger.info("[Socket.io] io instance found. Registering all handlers...")

  setupSocketIO(io, container, logger)
}

function setupSocketIO(io: Server, container: any, logger: any) {
  // ─── Auth middleware ─────────────────────────────────────────────────────
  io.use((socket, next) => {
    const token =
      socket.handshake.auth?.token ||
      socket.handshake.headers?.authorization?.replace("Bearer ", "")

    if (!token) {
      logger.warn("[Socket.io Auth] Rejected: no token provided.")
      return next(new Error("Authentication required"))
    }

    try {
      const secret = process.env.JWT_SECRET || "supersecret"
      const payload = jwt.verify(token, secret) as JwtPayload

      if (!payload.actor_id || !payload.actor_type) {
        logger.warn("[Socket.io Auth] Rejected: missing actor_id or actor_type in JWT.")
        return next(new Error("Invalid token"))
      }

      socket.data.actor_id = payload.actor_id
      socket.data.actor_type = payload.actor_type
      logger.info(`[Socket.io Auth] OK — actor=${payload.actor_id} type=${payload.actor_type}`)
      next()
    } catch (err: any) {
      logger.warn(`[Socket.io Auth] Rejected: invalid JWT — ${err.message}`)
      return next(new Error("Invalid token"))
    }
  })

  const chatService: ChatModuleService = container.resolve(CHAT_MODULE)
  const notifService: NotificationCenterService = container.resolve(NOTIFICATION_MODULE)
  const followService: any = container.resolve(FOLLOW_MODULE)

  // Membre d'une conversation directe, ou abonné du canal de diffusion
  const isConversationMember = async (
    conversation: any,
    actorType: string,
    resolvedId: string
  ): Promise<boolean> => {
    if (conversation.type === "broadcast") {
      if (actorType === "vendor") return conversation.vendor_id === resolvedId
      try {
        return await followService.isFollowing(resolvedId, conversation.vendor_id)
      } catch {
        return false
      }
    }
    return (
      (actorType === "customer" && conversation.customer_id === resolvedId) ||
      (actorType === "vendor" && conversation.vendor_id === resolvedId)
    )
  }

  // ─── Nom de l'expéditeur (pour les titres de push), mis en cache ─────────
  const resolveSenderName = async (socket: any): Promise<string | null> => {
    if (socket.data.senderName !== undefined) return socket.data.senderName

    const { actor_type } = socket.data
    let name: string | null = null
    try {
      const query = container.resolve(ContainerRegistrationKeys.QUERY)
      if (actor_type === "customer") {
        const { data: customers } = await query.graph({
          entity: "customer",
          fields: ["first_name", "last_name", "email"],
          filters: { id: [socket.data.actor_id] },
        })
        if (customers?.length > 0) {
          name =
            [customers[0].first_name, customers[0].last_name].filter(Boolean).join(" ") ||
            customers[0].email ||
            null
        }
      } else if (actor_type === "vendor") {
        const rid = await resolveActorId(socket)
        const { data: vendors } = await query.graph({
          entity: "vendor",
          fields: ["name"],
          filters: { id: [rid] },
        })
        name = vendors?.[0]?.name || null
      }
    } catch (err) {
      logger.error("[Socket.io] resolveSenderName error:", err)
    }

    socket.data.senderName = name
    return name
  }

  // ─── Resolve vendor admin → vendor.id ────────────────────────────────────
  const resolveActorId = async (socket: any): Promise<string> => {
    if (socket.data.resolvedActorId) return socket.data.resolvedActorId

    const { actor_id, actor_type } = socket.data

    if (actor_type !== "vendor") {
      socket.data.resolvedActorId = actor_id
      return actor_id
    }

    try {
      const query = container.resolve(ContainerRegistrationKeys.QUERY)
      const { data: admins } = await query.graph({
        entity: "vendor_admin",
        fields: ["vendor.id"],
        filters: { id: [actor_id] },
      })

      if (admins?.length > 0 && admins[0].vendor?.id) {
        const vendorId = admins[0].vendor.id
        socket.data.resolvedActorId = vendorId
        logger.info(`[Socket.io] vendor admin ${actor_id} → vendor ${vendorId}`)
        return vendorId
      }

      logger.warn(`[Socket.io] No vendor found for admin ${actor_id}`)
    } catch (err) {
      logger.error(`[Socket.io] Error resolving vendor ID for ${actor_id}:`, err)
    }

    socket.data.resolvedActorId = actor_id
    return actor_id
  }

  // ─── Connection ──────────────────────────────────────────────────────────
  io.on("connection", async (socket) => {
    const { actor_id, actor_type } = socket.data
    logger.info(`[Socket.io] Connected — socket=${socket.id} actor=${actor_id} (${actor_type})`)

    const resolvedId = await resolveActorId(socket)

    socket.join(`user:${resolvedId}`)
    logger.info(`[Socket.io] Joined room user:${resolvedId}`)

    // ─── PRÉSENCE ────────────────────────────────────────────────────────
    if (trackConnect(resolvedId)) {
      io.to(`presence:${resolvedId}`).emit("presence_changed", getPresence(resolvedId))
    }

    // ─── LIVRAISON — messages en attente pendant qu'il était hors ligne ──
    try {
      const delivered = await chatService.markAllDeliveredForRecipient(
        resolvedId,
        actor_type as "customer" | "vendor"
      )
      for (const { conversation_id, message_ids } of delivered) {
        io.to(`conversation:${conversation_id}`).emit("messages_delivered", {
          conversation_id,
          message_ids,
        })
      }
    } catch (err) {
      logger.error(`[Socket.io] markAllDeliveredForRecipient error for ${resolvedId}:`, err)
    }

    socket.on("subscribe_presence", ({ user_id }: { user_id: string }) => {
      if (!user_id) return
      socket.join(`presence:${user_id}`)
      socket.emit("presence_state", getPresence(user_id))
    })

    socket.on("unsubscribe_presence", ({ user_id }: { user_id: string }) => {
      if (!user_id) return
      socket.leave(`presence:${user_id}`)
    })

    try {
      const count = await notifService.countUnread(resolvedId)
      socket.emit("notification_count", { count })
      logger.info(`[Socket.io] notification_count=${count} → user:${resolvedId}`)
    } catch (err) {
      logger.error(`[Socket.io] Error fetching notification count for ${resolvedId}:`, err)
    }

    // ─── NOTIFICATIONS ───────────────────────────────────────────────────

    socket.on("mark_notification_read", async ({ notification_id }: { notification_id: string }) => {
      logger.info(`[Socket.io] mark_notification_read notification_id=${notification_id}`)
      try {
        await notifService.markAsRead(notification_id)
        const rid = await resolveActorId(socket)
        const count = await notifService.countUnread(rid)
        socket.emit("notification_count", { count })
      } catch (err: any) {
        logger.error("[Socket.io] mark_notification_read error:", err)
        socket.emit("error", { message: err.message })
      }
    })

    socket.on("mark_all_notifications_read", async () => {
      logger.info("[Socket.io] mark_all_notifications_read")
      try {
        const rid = await resolveActorId(socket)
        await notifService.markAllAsRead(rid)
        socket.emit("notification_count", { count: 0 })
      } catch (err: any) {
        logger.error("[Socket.io] mark_all_notifications_read error:", err)
        socket.emit("error", { message: err.message })
      }
    })

    // ─── CHAT ────────────────────────────────────────────────────────────

    socket.on("join_conversation", async ({ conversation_id }: { conversation_id: string }) => {
      logger.info(`[Socket.io] join_conversation conversation_id=${conversation_id} actor=${actor_id} (${actor_type})`)
      try {
        const conversation = await chatService.retrieveConversation(conversation_id)
        logger.info(`[Socket.io] Conversation found — customer_id=${conversation.customer_id} vendor_id=${conversation.vendor_id}`)

        const rid = await resolveActorId(socket)
        const isMember = await isConversationMember(conversation, actor_type, rid)

        logger.info(`[Socket.io] join_conversation resolvedId=${rid} isMember=${isMember}`)

        if (!isMember) {
          logger.warn(`[Socket.io] join_conversation UNAUTHORIZED — resolvedId=${rid}`)
          socket.emit("error", { message: "Unauthorized" })
          return
        }

        socket.join(`conversation:${conversation_id}`)
        logger.info(`[Socket.io] Socket ${socket.id} joined room conversation:${conversation_id}`)
        socket.emit("joined", { conversation_id })
      } catch (err: any) {
        logger.error(`[Socket.io] join_conversation error for ${conversation_id}:`, err)
        socket.emit("error", { message: "Conversation not found" })
      }
    })

    socket.on("send_message", async (data: {
      conversation_id: string
      content: string
      type?: string
      file_url?: string
      reply_to_id?: string
      metadata?: Record<string, unknown>
    }) => {
      logger.info(`[Socket.io] send_message conversation_id=${data.conversation_id} sender=${actor_type}`)
      try {
        const conversation = await chatService.retrieveConversation(data.conversation_id)

        // Les canaux de diffusion passent par la route REST vendeur dédiée
        if ((conversation as any).type === "broadcast") {
          socket.emit("error", { message: "Broadcast channels are read-only here" })
          return
        }

        const rid = await resolveActorId(socket)
        const isMember = await isConversationMember(conversation, actor_type, rid)

        if (!isMember) {
          logger.warn(`[Socket.io] send_message UNAUTHORIZED resolvedId=${rid}`)
          socket.emit("error", { message: "Unauthorized" })
          return
        }

        const message = await chatService.sendMessage({
          conversation_id: data.conversation_id,
          sender_type: actor_type as "customer" | "vendor",
          sender_id: rid,
          content: data.content,
          type: (data.type as any) || "text",
          file_url: data.file_url,
          reply_to_id: data.reply_to_id,
          metadata: data.metadata,
        })
        logger.info(`[Socket.io] Message saved id=${message.id}`)

        const recipientId = actor_type === "customer" ? conversation.vendor_id : conversation.customer_id
        const recipientType = actor_type === "customer" ? "vendor" : "customer"

        // Destinataire en ligne → distribué immédiatement
        if (recipientId && getPresence(recipientId).online) {
          const deliveredAt = new Date()
          await chatService.updateMessages({ id: message.id, delivered_at: deliveredAt } as any)
          ;(message as any).delivered_at = deliveredAt
        }

        io.to(`conversation:${data.conversation_id}`).emit("message_received", {
          message,
          conversation_id: data.conversation_id,
        })

        const senderName = await resolveSenderName(socket)
        const pushTitle = senderName ? `Message de ${senderName}` : "Nouveau message"

        const notif = await notifService.createNotification({
          recipient_id: recipientId,
          recipient_type: recipientType,
          type: "new_message",
          title: pushTitle,
          body: data.content.substring(0, 100),
          data: {
            conversation_id: data.conversation_id,
            sender_type: actor_type,
            sender_id: rid,
          },
        })

        const unreadCount = await notifService.countUnread(recipientId)
        io.to(`user:${recipientId}`).emit("new_notification", { notification: notif, count: unreadCount })

        try {
          if (await notifService.isPushAllowed(recipientId, "messages")) {
            const tokens = await notifService.getRecipientTokens(recipientId)
            if (tokens.length > 0) {
              await sendPushNotification(
                tokens.map((t: any) => t.token),
                pushTitle,
                data.content.substring(0, 100),
                { conversation_id: data.conversation_id }
              )
            }
          }
        } catch (pushErr) {
          logger.error("[Socket.io] Push notification failed:", pushErr)
        }
      } catch (err: any) {
        logger.error("[Socket.io] send_message error:", err)
        socket.emit("error", { message: err.message || "Failed to send message" })
      }
    })

    socket.on("mark_read", async ({ conversation_id }: { conversation_id: string }) => {
      logger.info(`[Socket.io] mark_read conversation_id=${conversation_id}`)
      try {
        // is_read est partagé entre tous les abonnés d'un canal : on ne le touche pas
        const conversation = await chatService.retrieveConversation(conversation_id)
        if ((conversation as any).type === "broadcast") return

        await chatService.markMessagesAsRead(conversation_id, actor_type as "customer" | "vendor")
        io.to(`conversation:${conversation_id}`).emit("messages_read", {
          conversation_id,
          reader_type: actor_type,
        })
      } catch (err: any) {
        logger.error("[Socket.io] mark_read error:", err)
        socket.emit("error", { message: err.message })
      }
    })

    socket.on("add_reaction", async (data: {
      conversation_id: string
      message_id: string
      emoji: string
    }) => {
      logger.info(`[Socket.io] add_reaction message_id=${data.message_id} emoji=${data.emoji}`)
      try {
        const conversation = await chatService.retrieveConversation(data.conversation_id)
        const rid = await resolveActorId(socket)
        const isMember = await isConversationMember(conversation, actor_type, rid)

        if (!isMember) {
          socket.emit("error", { message: "Unauthorized" })
          return
        }

        const message = await chatService.retrieveMessage(data.message_id)
        if (message.conversation_id !== data.conversation_id) {
          socket.emit("error", { message: "Message not found in this conversation" })
          return
        }

        const result = await chatService.addReaction(
          data.message_id,
          actor_type as "customer" | "vendor",
          rid,
          data.emoji
        )

        io.to(`conversation:${data.conversation_id}`).emit("reaction_added", {
          conversation_id: data.conversation_id,
          message_id: data.message_id,
          reactions: result.reactions,
          actor_type,
          actor_id: rid,
          emoji: data.emoji,
        })
      } catch (err: any) {
        logger.error("[Socket.io] add_reaction error:", err)
        socket.emit("error", { message: err.message || "Failed to add reaction" })
      }
    })

    socket.on("delete_message", async (data: {
      conversation_id: string
      message_id: string
    }) => {
      logger.info(`[Socket.io] delete_message message_id=${data.message_id}`)
      try {
        const conversation = await chatService.retrieveConversation(data.conversation_id)
        const rid = await resolveActorId(socket)
        const isMember = await isConversationMember(conversation, actor_type, rid)

        if (!isMember) {
          socket.emit("error", { message: "Unauthorized" })
          return
        }

        const message = await chatService.retrieveMessage(data.message_id)
        if (message.conversation_id !== data.conversation_id) {
          socket.emit("error", { message: "Message not found in this conversation" })
          return
        }

        // Seul l'auteur peut supprimer son message
        if (!(message.sender_type === actor_type && message.sender_id === rid)) {
          socket.emit("error", { message: "You can only delete your own messages" })
          return
        }

        await chatService.softDeleteMessage(data.message_id)

        io.to(`conversation:${data.conversation_id}`).emit("message_deleted", {
          conversation_id: data.conversation_id,
          message_id: data.message_id,
        })
      } catch (err: any) {
        logger.error("[Socket.io] delete_message error:", err)
        socket.emit("error", { message: err.message || "Failed to delete message" })
      }
    })

    socket.on("typing", ({ conversation_id }: { conversation_id: string }) => {
      socket.to(`conversation:${conversation_id}`).emit("user_typing", { conversation_id, actor_type })
    })

    socket.on("stop_typing", ({ conversation_id }: { conversation_id: string }) => {
      socket.to(`conversation:${conversation_id}`).emit("user_stop_typing", { conversation_id })
    })

    socket.on("disconnect", () => {
      logger.info(`[Socket.io] Disconnected — socket=${socket.id} actor=${actor_id}`)
      if (trackDisconnect(resolvedId)) {
        io.to(`presence:${resolvedId}`).emit("presence_changed", getPresence(resolvedId))
      }
    })
  })

  logger.info("[Socket.io] All handlers registered successfully.")
}
