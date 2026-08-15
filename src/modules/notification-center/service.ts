import { MedusaService } from "@medusajs/framework/utils"
import AppNotification from "./models/notification"
import PushToken from "./models/push-token"
import NotificationPreference from "./models/notification-preference"

export type PushCategory = "messages" | "reminders" | "broadcasts" | "orders"

export type NotificationPrefs = {
  messages: boolean
  reminders: boolean
  broadcasts: boolean
  orders: boolean
  quiet_hours: { start: string; end: string } | null
}

const DEFAULT_PREFS: NotificationPrefs = {
  messages: true,
  reminders: true,
  broadcasts: true,
  orders: true,
  quiet_hours: null,
}

type CreateNotificationInput = {
  recipient_id: string
  recipient_type: "customer" | "vendor"
  type: string
  title: string
  body: string
  data?: Record<string, any>
}

class NotificationCenterService extends MedusaService({
  AppNotification,
  PushToken,
  NotificationPreference,
}) {

  async getPreferences(recipientId: string): Promise<NotificationPrefs> {
    const rows = await this.listNotificationPreferences({ recipient_id: recipientId })
    if (rows.length === 0) return { ...DEFAULT_PREFS }
    return { ...DEFAULT_PREFS, ...(rows[0].prefs as Partial<NotificationPrefs>) }
  }

  async setPreferences(
    recipientId: string,
    recipientType: "customer" | "vendor",
    prefs: Partial<NotificationPrefs>
  ): Promise<NotificationPrefs> {
    const merged = { ...(await this.getPreferences(recipientId)), ...prefs }
    const rows = await this.listNotificationPreferences({ recipient_id: recipientId })
    if (rows.length > 0) {
      await this.updateNotificationPreferences({ id: rows[0].id, prefs: merged } as any)
    } else {
      await this.createNotificationPreferences({
        recipient_id: recipientId,
        recipient_type: recipientType,
        prefs: merged,
      } as any)
    }
    return merged
  }

  /**
   * Garde-fou : la catégorie est-elle activée, et sommes-nous hors heures calmes ?
   * Les notifications in-app ne sont jamais bloquées — seul le push l'est.
   */
  async isPushAllowed(recipientId: string, category: PushCategory, now = new Date()): Promise<boolean> {
    const prefs = await this.getPreferences(recipientId)
    if (!prefs[category]) return false

    if (prefs.quiet_hours?.start && prefs.quiet_hours?.end) {
      const [sh, sm] = prefs.quiet_hours.start.split(":").map(Number)
      const [eh, em] = prefs.quiet_hours.end.split(":").map(Number)
      const minutes = now.getHours() * 60 + now.getMinutes()
      const start = sh * 60 + (sm || 0)
      const end = eh * 60 + (em || 0)
      const inQuietHours =
        start <= end
          ? minutes >= start && minutes < end
          : minutes >= start || minutes < end // fenêtre qui traverse minuit
      if (inQuietHours) return false
    }

    return true
  }

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
