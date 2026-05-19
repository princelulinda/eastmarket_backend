import { Module } from "@medusajs/framework/utils"
import SocketModuleService from "./service"
import socketLoader from "./loaders/socket"

export const SOCKET_MODULE = "socketModule"

export default Module(SOCKET_MODULE, {
  service: SocketModuleService,
  loaders: [socketLoader],
})
