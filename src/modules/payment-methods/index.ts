import { Module } from "@medusajs/framework/utils"
import PaymentMethodsModuleService from "./service"

export const PAYMENT_METHODS_MODULE = "paymentMethodsModule"

export default Module(PAYMENT_METHODS_MODULE, {
  service: PaymentMethodsModuleService,
})
