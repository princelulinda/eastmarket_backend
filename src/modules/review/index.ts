import { Module } from "@medusajs/framework/utils"
import { ReviewModuleService } from "./service"
import Review from "./models/review"

export const REVIEW_MODULE = "review"

export default Module(REVIEW_MODULE, {
  service: ReviewModuleService,
  models: [Review],
})
