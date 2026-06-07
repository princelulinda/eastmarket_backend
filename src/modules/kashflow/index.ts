import { ModuleProvider, Modules } from "@medusajs/framework/utils"
import KashFlowPaymentService from "./service"

export default ModuleProvider(Modules.PAYMENT, {
  services: [KashFlowPaymentService],
})
