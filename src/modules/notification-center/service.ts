import { MedusaService } from "@medusajs/framework/utils"
import AppNotification from "./models/notification"
import PushToken from "./models/push-token"

type CreateNotificationInput = {
  recipient_id: string
  recipient_type: "customer" | "vendor"
  type: string
  title: string
  body: string
  data?: Record<string, any>
}

class NotificationCenterService extends MedusaService({ AppNotification, PushToken }) {

  async registerPushToken(input: {
    recipient_id: string
    recipient_type: "customer" | "vendor"
    token: string
    device_type?: string
  }) {
    // Check if token already exists to update or create
    const existing = await this.listPushTokens({ recipient_id: input.recipient_id, token: input.token })
    if (existing.length > 0) {
      return existing[0]
    }
    return await this.createPushTokens(input)
  }

  async getRecipientTokens(recipientId: string) {
    return await this.listPushTokens({ recipient_id: recipientId })
  }

  async createNotification(input: CreateNotificationInput) {
    return await this.createAppNotifications({
      recipient_id: input.recipient_id,
      recipient_type: input.recipient_type,
      type: input.type as any,
      title: input.title,
      body: input.body,
      data: input.data || null,
      is_read: false,
    })
  }

  async listForRecipient(recipientId: string, onlyUnread = false) {
    const filters: Record<string, any> = { recipient_id: recipientId }
    if (onlyUnread) filters.is_read = false
    return await this.listAppNotifications(filters, {
      order: { created_at: "DESC" },
      take: 50,
    })
  }

  async markAsRead(notificationId: string) {
    return await this.updateAppNotifications({ id: notificationId, is_read: true })
  }

  async markAllAsRead(recipientId: string) {
    const unread = await this.listAppNotifications({
      recipient_id: recipientId,
      is_read: false,
    })
    if (unread.length === 0) return
    await Promise.all(
      unread.map((n: any) => this.updateAppNotifications({ id: n.id, is_read: true }))
    )
  }

  async countUnread(recipientId: string) {
    const unread = await this.listAppNotifications({
      recipient_id: recipientId,
      is_read: false,
    })
    return unread.length
  }
}

export default NotificationCenterService
