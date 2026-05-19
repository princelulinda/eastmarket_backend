import { Module } from "@medusajs/framework/utils"
import OpeninaryImageService from "./service"

export const OPENINARY_IMAGE_MODULE = "openinaryImageModule"

export default Module(OPENINARY_IMAGE_MODULE, {
  service: OpeninaryImageService,
})
