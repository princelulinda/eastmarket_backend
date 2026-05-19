import { Server } from "socket.io"
import jwt from "jsonwebtoken"
import { MedusaContainer } from "@medusajs/framework/types"
import { CHAT_MODULE } from "../modules/chat"
import ChatModuleService from "../modules/chat/service"
import { NOTIFICATION_MODULE } from "../modules/notification-center"
import NotificationCenterService from "../modules/notification-center/service"

type JwtPayload = {
  actor_id: string
  actor_type: string
  auth_identity_id: string
}

let _io: Server | null = null
export const getIO = () => _io

export default async function socketLoader({
  container,
  app,
}: {
  container: MedusaContainer
  app: any
}) {
  // Medusa v2 exposes the underlying Express app — get its HTTP server
  const httpServer = app?.server || app?.httpServer || (app as any)?._server

  if (!httpServer) {
    console.warn("[Socket.io] Could not find HTTP server, trying alternative...")
    // Fallback: attach to the express app directly
    // Socket.io can attach to an express app too
  }

  const io = new Server(httpServer || app, {
    cors: {
      origin: process.env.STORE_CORS?.split(",") || ["*"],
      methods: ["GET", "POST"],
      credentials: true,
    },
    path: "/socket.io",
    transports: ["websocket", "polling"],
  })

  _io = io

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

  const chatService: ChatModuleService = container.resolve(CHAT_MODULE)
  const notifService: NotificationCenterService = container.resolve(NOTIFICATION_MODULE)

  io.on("connection", (socket) => {
    const { actor_id, actor_type } = socket.data

    // Auto-join personal notification room
    socket.join(`user:${actor_id}`)

    // ─── NOTIFICATIONS ────────────────────────────────────────────

    // Get unread notifications count on connect
    notifService.countUnread(actor_id).then((count) => {
      socket.emit("notification_count", { count })
    })

    // Mark a single notification as read
    socket.on("mark_notification_read", async ({ notification_id }: { notification_id: string }) => {
      try {
        await notifService.markAsRead(notification_id)
        const count = await notifService.countUnread(actor_id)
        socket.emit("notification_count", { count })
      } catch (err: any) {
        socket.emit("error", { message: err.message })
      }
    })

    // Mark all notifications as read
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

        const room = `conversation:${data.conversation_id}`
        io.to(room).emit("message_received", {
          message,
          conversation_id: data.conversation_id,
        })

        // Push notification to the OTHER party's personal room
        const recipientId = actor_type === "customer"
          ? conversation.vendor_id
          : conversation.customer_id

        const recipientType = actor_type === "customer" ? "vendor" : "customer"

        const notif = await notifService.createNotification({
          recipient_id: recipientId,
          recipient_type: recipientType,
          type: "new_message",
          title: "Nouveau message",
          body: data.content.substring(0, 100),
          data: {
            conversation_id: data.conversation_id,
            sender_type: actor_type,
            sender_id: actor_id,
          },
        })

        const unreadCount = await notifService.countUnread(recipientId)

        io.to(`user:${recipientId}`).emit("new_notification", {
          notification: notif,
          count: unreadCount,
        })

      } catch (err: any) {
        socket.emit("error", { message: err.message || "Failed to send message" })
      }
    })

    socket.on("mark_read", async ({ conversation_id }: { conversation_id: string }) => {
      try {
        await chatService.markMessagesAsRead(
          conversation_id,
          actor_type as "customer" | "vendor"
        )
        io.to(`conversation:${conversation_id}`).emit("messages_read", {
          conversation_id,
          reader_type: actor_type,
        })
      } catch (err: any) {
        socket.emit("error", { message: err.message })
      }
    })

    socket.on("typing", ({ conversation_id }: { conversation_id: string }) => {
      socket.to(`conversation:${conversation_id}`).emit("user_typing", {
        conversation_id,
        actor_type,
      })
    })

    socket.on("stop_typing", ({ conversation_id }: { conversation_id: string }) => {
      socket.to(`conversation:${conversation_id}`).emit("user_stop_typing", {
        conversation_id,
      })
    })

    socket.on("disconnect", () => {})
  })

  console.log("[Socket.io] Server initialized")
}
