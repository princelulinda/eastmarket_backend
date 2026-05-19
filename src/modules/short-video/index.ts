import { Module } from "@medusajs/framework/utils"
import ShortVideoService from "./service"

export const SHORT_VIDEO_MODULE = "short_video"

export default Module(SHORT_VIDEO_MODULE, {
  service: ShortVideoService,
})
