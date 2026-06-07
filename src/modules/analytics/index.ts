import { Module } from "@medusajs/framework/utils"
import AnalyticsService from "./service"

export default Module("analytics", {
  service: AnalyticsService,
})
