import { Module } from "@medusajs/framework/utils"
import NotificationCenterService from "./service"

export const NOTIFICATION_MODULE = "notificationCenter"

export default Module(NOTIFICATION_MODULE, {
  service: NotificationCenterService,
})
