import { model } from "@medusajs/framework/utils"

const VideoComment = model.define("video_comment", {
  id: model.id().primaryKey(),
  video_id: model.text(),
  customer_id: model.text(),
  content: model.text(),
})

export default VideoComment
