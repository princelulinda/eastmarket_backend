import { ModuleProvider, Modules } from "@medusajs/framework/utils"
import MbiyoPayService from "./service"

export default ModuleProvider(Modules.PAYMENT, {
  services: [MbiyoPayService],
})
