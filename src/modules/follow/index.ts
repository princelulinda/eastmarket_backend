import { Module } from "@medusajs/framework/utils"
import FollowModuleService from "./service"

export const FOLLOW_MODULE = "follow"

export default Module(FOLLOW_MODULE, {
  service: FollowModuleService,
})
