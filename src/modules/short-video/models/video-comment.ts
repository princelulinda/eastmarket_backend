import { model } from "@medusajs/framework/utils"

const VideoComment = model.define("video_comment", {
  id: model.id().primaryKey(),
  video_id: model.text(),
  customer_id: model.text().nullable(), // Nullable for vendor replies
  vendor_id: model.text().nullable(),   // Optional: track if vendor replied
  content: model.text(),
  parent_id: model.text().nullable(),   // Threading
})

export default VideoComment
