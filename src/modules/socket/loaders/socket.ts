import { Server } from "socket.io"
import * as http from "http"
import jwt from "jsonwebtoken"
import { LoaderOptions } from "@medusajs/framework/types"
import { asValue } from "@medusajs/framework/awilix"
import { CHAT_MODULE } from "../../chat"
import ChatModuleService from "../../chat/service"
import { NOTIFICATION_MODULE } from "../../notification-center"
import NotificationCenterService from "../../notification-center/service"
import { setIO } from "../service"

const SOCKET_PORT = parseInt(process.env.SOCKET_PORT || "9001")

type JwtPayload = {
  actor_id: string
  actor_type: string
}

export default async function socketLoader({ container }: LoaderOptions) {
  const logger = container.resolve("logger")

  // Create a standalone HTTP server for Socket.io on a separate port
  const httpServer = http.createServer()

  const io = new Server(httpServer, {
    cors: {
      origin: process.env.STORE_CORS?.split(",") || ["*"],
      methods: ["GET", "POST"],
      credentials: true,
    },
    path: "/socket.io",
    transports: ["websocket", "polling"],
  })

  // Store io globally for REST routes
  setIO(io)

  // Register io in the module container
  container.register("io", asValue(io))

  // Auth middleware
  io.use((socket, next) => {
    const token =
      socket.handshake.auth?.token ||
      socket.handshake.headers?.authorization?.replace("Bearer ", "")

    if (!token) {
      return next(new Error("Authentication required"))
    }

    try {
      const secret = process.env.JWT_SECRET || "supersecret"
      const payload = jwt.verify(token, secret) as JwtPayload

      if (!payload.actor_id || !payload.actor_type) {
        return next(new Error("Invalid token"))
      }

      socket.data.actor_id = payload.actor_id
      socket.data.actor_type = payload.actor_type
      next()
    } catch {
      return next(new Error("Invalid token"))
    }
  })

  // Resolve services — they may not be available yet at loader time
  // so we resolve them lazily inside event handlers
  io.on("connection", async (socket) => {
    const { actor_id, actor_type } = socket.data
    console.log( actor_id, actor_type)
    let chatService: ChatModuleService
    let notifService: NotificationCenterService

    try {
      chatService = container.resolve(CHAT_MODULE)
      notifService = container.resolve(NOTIFICATION_MODULE)
    } catch {
      logger.warn("[Socket.io] Could not resolve chat/notification services")
      socket.disconnect()
      return
    }

    // Auto-join personal notification room
    socket.join(`user:${actor_id}`)

    // Send unread count on connect
    try {
      const count = await notifService.countUnread(actor_id)
      socket.emit("notification_count", { count })
    } catch {}

    // ─── NOTIFICATIONS ────────────────────────────────────────────

    socket.on("mark_notification_read", async ({ notification_id }: { notification_id: string }) => {
      try {
        await notifService.markAsRead(notification_id)
        const count = await notifService.countUnread(actor_id)
        socket.emit("notification_count", { count })
      } catch (err: any) {
        socket.emit("error", { message: err.message })
      }
    })

    socket.on("mark_all_notifications_read", async () => {
      try {
        await notifService.markAllAsRead(actor_id)
        socket.emit("notification_count", { count: 0 })
      } catch (err: any) {
        socket.emit("error", { message: err.message })
      }
    })

    // ─── CHAT ─────────────────────────────────────────────────────

    socket.on("join_conversation", async ({ conversation_id }: { conversation_id: string }) => {
      try {
        const conversation = await chatService.retrieveConversation(conversation_id)
        const isMember =
          (actor_type === "customer" && conversation.customer_id === actor_id) ||
          (actor_type === "vendor" && conversation.vendor_id === actor_id)

        if (!isMember) {
          socket.emit("error", { message: "Unauthorized" })
          return
        }

        socket.join(`conversation:${conversation_id}`)
        socket.emit("joined", { conversation_id })
      } catch {
        socket.emit("error", { message: "Conversation not found" })
      }
    })

    socket.on("send_message", async (data: {
      conversation_id: string
      content: string
      type?: "text" | "image" | "file"
      file_url?: string
    }) => {
      try {
        const conversation = await chatService.retrieveConversation(data.conversation_id)
        const isMember =
          (actor_type === "customer" && conversation.customer_id === actor_id) ||
          (actor_type === "vendor" && conversation.vendor_id === actor_id)

        if (!isMember) {
          socket.emit("error", { message: "Unauthorized" })
          return
        }

        const message = await chatService.sendMessage({
          conversation_id: data.conversation_id,
          sender_type: actor_type as "customer" | "vendor",
          sender_id: actor_id,
          content: data.content,
          type: data.type || "text",
          file_url: data.file_url,
        })

        io.to(`conversation:${data.conversation_id}`).emit("message_received", {
          message,
          conversation_id: data.conversation_id,
        })

        // Notify the other party
        const recipientId = actor_type === "customer"
          ? conversation.vendor_id
          : conversation.customer_id

        if (recipientId) {
          const recipientType = actor_type === "customer" ? "vendor" : "customer"
          const notif = await notifService.createNotification({
            recipient_id: recipientId,
            recipient_type: recipientType,
            type: "new_message",
            title: "Nouveau message",
            body: data.content.substring(0, 100),
            data: { conversation_id: data.conversation_id, sender_type: actor_type },
          })
          const count = await notifService.countUnread(recipientId)
          io.to(`user:${recipientId}`).emit("new_notification", { notification: notif, count })
        }
      } catch (err: any) {
        socket.emit("error", { message: err.message || "Failed to send message" })
      }
    })

    socket.on("mark_read", async ({ conversation_id }: { conversation_id: string }) => {
      try {
        await chatService.markMessagesAsRead(conversation_id, actor_type as "customer" | "vendor")
        io.to(`conversation:${conversation_id}`).emit("messages_read", {
          conversation_id,
          reader_type: actor_type,
        })
      } catch (err: any) {
        socket.emit("error", { message: err.message })
      }
    })

    socket.on("typing", ({ conversation_id }: { conversation_id: string }) => {
      socket.to(`conversation:${conversation_id}`).emit("user_typing", { conversation_id, actor_type })
    })

    socket.on("stop_typing", ({ conversation_id }: { conversation_id: string }) => {
      socket.to(`conversation:${conversation_id}`).emit("user_stop_typing", { conversation_id })
    })

    socket.on("disconnect", () => {})
  })

  httpServer.listen(SOCKET_PORT, () => {
    logger.info(`[Socket.io] Server running on port ${SOCKET_PORT}`)
  })
}
