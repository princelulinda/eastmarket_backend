import { LoaderOptions } from "@medusajs/framework/types"
import { container as globalContainer } from "@medusajs/framework"
import { Server } from "socket.io"
import jwt from "jsonwebtoken"
import { CHAT_MODULE } from "../../chat"
import ChatModuleService from "../../chat/service"
import { NOTIFICATION_MODULE } from "../../notification-center"
import NotificationCenterService from "../../notification-center/service"
import { sendPushNotification } from "../../notification-center/push-service"
import { setIO } from "../service"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"

type JwtPayload = {
  actor_id: string
  actor_type: string
  auth_identity_id: string
}

export default async function socketModuleLoader({ container }: LoaderOptions) {
  const logger = container.resolve("logger")
  logger.info("[Socket.io] Module loader started.")

  if ((globalThis as any).__medusaSocketHandlersRegistered) {
    logger.info("[Socket.io] Handlers already registered. Skipping.")
    return
  }

  // Wait for __medusaIo to be set by instrumentation.ts
  const waitForIO = (): Promise<Server> =>
    new Promise((resolve) => {
      const check = () => {
        const io = (globalThis as any).__medusaIo
        if (io) {
          resolve(io)
        } else {
          setTimeout(check, 200)
        }
      }
      check()
    })

  const io = await waitForIO()
  ;(globalThis as any).__medusaSocketHandlersRegistered = true

  setIO(io)
  logger.info("[Socket.io] io instance found and registered. Setting up handlers...")

  setupSocketIO(io, logger)

  logger.info("[Socket.io] All handlers registered successfully.")
}

function setupSocketIO(io: Server, logger: any) {
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

  // ─── Lazy service resolution (uses globalContainer, not the isolated module container) ──
  // Services are resolved on first use, after all Medusa modules are loaded.
  const getServices = () => ({
    chatService: globalContainer.resolve<ChatModuleService>(CHAT_MODULE),
    notifService: globalContainer.resolve<NotificationCenterService>(NOTIFICATION_MODULE),
  })

  // ─── Resolve vendor admin → vendor.id ────────────────────────────────────
  const resolveActorId = async (socket: any): Promise<string> => {
    if (socket.data.resolvedActorId) return socket.data.resolvedActorId

    const { actor_id, actor_type } = socket.data

    if (actor_type !== "vendor") {
      socket.data.resolvedActorId = actor_id
      return actor_id
    }

    try {
      const query = globalContainer.resolve<any>(ContainerRegistrationKeys.QUERY)
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

      logger.warn(`[Socket.io] No vendor found for admin actor_id=${actor_id}`)
    } catch (err) {
      logger.error(`[Socket.io] Error resolving vendor ID for actor_id=${actor_id}:`, err)
    }

    socket.data.resolvedActorId = actor_id
    return actor_id
  }

  // ─── Connection ──────────────────────────────────────────────────────────
  io.on("connection", async (socket) => {
    const { actor_id, actor_type } = socket.data
    logger.info(`[Socket.io] Connected — socket=${socket.id} actor=${actor_id} (${actor_type})`)

    const { notifService } = getServices()

    const resolvedId = await resolveActorId(socket)

    socket.join(`user:${resolvedId}`)
    logger.info(`[Socket.io] Joined notification room user:${resolvedId}`)

    try {
      const count = await notifService.countUnread(resolvedId)
      socket.emit("notification_count", { count })
      logger.info(`[Socket.io] notification_count=${count} sent to user:${resolvedId}`)
    } catch (err) {
      logger.error(`[Socket.io] Error fetching notification count for ${resolvedId}:`, err)
    }

    // ─── NOTIFICATIONS ───────────────────────────────────────────────────

    socket.on("mark_notification_read", async ({ notification_id }: { notification_id: string }) => {
      logger.info(`[Socket.io] mark_notification_read notification_id=${notification_id}`)
      try {
        const { notifService } = getServices()
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
        const { notifService } = getServices()
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
        const { chatService } = getServices()
        const conversation = await chatService.retrieveConversation(conversation_id)
        logger.info(`[Socket.io] Conversation found — customer_id=${conversation.customer_id} vendor_id=${conversation.vendor_id}`)

        const rid = await resolveActorId(socket)
        const isMember =
          (actor_type === "customer" && conversation.customer_id === rid) ||
          (actor_type === "vendor" && conversation.vendor_id === rid)

        logger.info(`[Socket.io] join_conversation — resolvedId=${rid} isMember=${isMember}`)

        if (!isMember) {
          logger.warn(`[Socket.io] join_conversation UNAUTHORIZED — resolvedId=${rid} does not match conversation`)
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
      type?: "text" | "image" | "file"
      file_url?: string
    }) => {
      logger.info(`[Socket.io] send_message conversation_id=${data.conversation_id} sender=${actor_type}`)
      try {
        const { chatService, notifService } = getServices()
        const conversation = await chatService.retrieveConversation(data.conversation_id)
        const rid = await resolveActorId(socket)
        const isMember =
          (actor_type === "customer" && conversation.customer_id === rid) ||
          (actor_type === "vendor" && conversation.vendor_id === rid)

        if (!isMember) {
          logger.warn(`[Socket.io] send_message UNAUTHORIZED — resolvedId=${rid}`)
          socket.emit("error", { message: "Unauthorized" })
          return
        }

        const message = await chatService.sendMessage({
          conversation_id: data.conversation_id,
          sender_type: actor_type as "customer" | "vendor",
          sender_id: rid,
          content: data.content,
          type: data.type || "text",
          file_url: data.file_url,
        })
        logger.info(`[Socket.io] Message saved id=${message.id}`)

        io.to(`conversation:${data.conversation_id}`).emit("message_received", {
          message,
          conversation_id: data.conversation_id,
        })

        const recipientId = actor_type === "customer" ? conversation.vendor_id : conversation.customer_id
        const recipientType = actor_type === "customer" ? "vendor" : "customer"

        // ─── Emit real-time conversation list update for recipient ──────────
        try {
          // Fetch recipient's unread count for this conversation
          const unreadMsgs = await chatService.listMessages({
            conversation_id: data.conversation_id,
            sender_type: actor_type as "customer" | "vendor", // messages sent by sender are unread for recipient
            is_read: false,
          } as any)

          // Let's resolve the sender details (either customer info or vendor info) to enrich the event
          let senderInfo: any = null
          const query = globalContainer.resolve<any>(ContainerRegistrationKeys.QUERY)
          if (actor_type === "customer") {
            const { data: customers } = await query.graph({
              entity: "customer",
              fields: ["id", "first_name", "last_name", "email"],
              filters: { id: [rid] }
            })
            if (customers && customers.length > 0) {
              senderInfo = customers[0]
            }
          }

          const conversationUpdate = {
            id: conversation.id,
            customer_id: conversation.customer_id,
            vendor_id: conversation.vendor_id,
            last_message_at: message.created_at,
            last_message: {
              id: message.id,
              content: message.content,
              sender_type: message.sender_type,
              sender_id: message.sender_id,
              type: message.type,
              file_url: message.file_url,
              created_at: message.created_at,
            },
            unread_count: unreadMsgs.length,
            customer: actor_type === "customer" ? senderInfo : undefined,
          }

          logger.info(`[Socket.io] Emitting conversation_list_updated to user:${recipientId}`)
          io.to(`user:${recipientId}`).emit("conversation_list_updated", conversationUpdate)

          // ─── Emit real-time conversation list update for sender ──────────
          // The sender's unread count is always 0 for their own message
          const senderConversationUpdate = {
            ...conversationUpdate,
            unread_count: 0,
            // If the sender is a customer, we already have their info
            customer: actor_type === "customer" ? senderInfo : undefined,
          }
          logger.info(`[Socket.io] Emitting conversation_list_updated to sender user:${rid}`)
          io.to(`user:${rid}`).emit("conversation_list_updated", senderConversationUpdate)
        } catch (updateErr) {
          logger.error("[Socket.io] Failed to broadcast conversation list update:", updateErr)
        }

        const notif = await notifService.createNotification({
          recipient_id: recipientId,
          recipient_type: recipientType,
          type: "new_message",
          title: "Nouveau message",
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
          const tokens = await notifService.getRecipientTokens(recipientId)
          if (tokens.length > 0) {
            await sendPushNotification(
              tokens.map((t: any) => t.token),
              "Nouveau message",
              data.content.substring(0, 100),
              { conversation_id: data.conversation_id }
            )
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
        const { chatService } = getServices()
        const rid = await resolveActorId(socket)
        await chatService.markMessagesAsRead(conversation_id, actor_type as "customer" | "vendor")
        
        io.to(`conversation:${conversation_id}`).emit("messages_read", {
          conversation_id,
          reader_type: actor_type,
        })

        // Also emit a conversation_list_updated to the reader to set unread_count to 0
        const conversation = await chatService.retrieveConversation(conversation_id)
        
        // Fetch last message for the update
        const messages = await chatService.getMessages(conversation_id, 1)
        const lastMessage = messages.length > 0 ? messages[0] : null

        let customerInfo: any = undefined
        if (conversation.customer_id) {
          const query = globalContainer.resolve<any>(ContainerRegistrationKeys.QUERY)
          const { data: customers } = await query.graph({
            entity: "customer",
            fields: ["id", "first_name", "last_name", "email"],
            filters: { id: [conversation.customer_id] }
          })
          if (customers && customers.length > 0) {
            customerInfo = customers[0]
          }
        }

        const conversationUpdate = {
          id: conversation.id,
          customer_id: conversation.customer_id,
          vendor_id: conversation.vendor_id,
          last_message_at: conversation.last_message_at,
          last_message: lastMessage ? {
            id: lastMessage.id,
            content: lastMessage.content,
            sender_type: lastMessage.sender_type,
            sender_id: lastMessage.sender_id,
            type: lastMessage.type,
            file_url: lastMessage.file_url,
            created_at: lastMessage.created_at,
          } : null,
          unread_count: 0,
          customer: customerInfo,
        }

        logger.info(`[Socket.io] Emitting conversation_list_updated on mark_read to user:${rid}`)
        io.to(`user:${rid}`).emit("conversation_list_updated", conversationUpdate)
      } catch (err: any) {
        logger.error("[Socket.io] mark_read error:", err)
        socket.emit("error", { message: err.message })
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
    })
  })
}
