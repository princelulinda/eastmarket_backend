import { model } from "@medusajs/framework/utils"

const VideoLike = model.define("video_like", {
  id: model.id().primaryKey(),
  video_id: model.text(),
  customer_id: model.text(),
})

export default VideoLike
