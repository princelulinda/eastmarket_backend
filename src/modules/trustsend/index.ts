import { ModuleProvider, Modules } from "@medusajs/framework/utils"
import TrustSendService from "./service"

export default ModuleProvider(Modules.PAYMENT, {
  services: [TrustSendService],
})
