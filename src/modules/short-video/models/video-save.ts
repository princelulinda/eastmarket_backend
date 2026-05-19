import { model } from "@medusajs/framework/utils"

const VideoSave = model.define("video_save", {
  id: model.id().primaryKey(),
  video_id: model.text(),
  customer_id: model.text(),
})

export default VideoSave
