import { MedusaService } from "@medusajs/framework/utils"
import AnalyticsEvent from "./models/analytics-event"

class AnalyticsService extends MedusaService({ AnalyticsEvent }) {}

export default AnalyticsService
