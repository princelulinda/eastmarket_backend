import { model } from "@medusajs/framework/utils"

const ShortVideo = model.define("short_video", {
  id: model.id().primaryKey(),
  vendor_id: model.text(),
  title: model.text(),
  description: model.text().nullable(),
  video_url: model.text(),           // Source MP4 URL
  hls_url: model.text().nullable(),   // Streaming HLS URL (.m3u8)
  thumbnail_url: model.text().nullable(),
  duration: model.number().nullable(), // seconds
  tag: model.text().nullable(),        // category label shown on card
  status: model.enum(["draft", "published", "archived"]).default("draft"),
  is_processed: model.boolean().default(false), // True when HLS is ready
  likes_count: model.number().default(0),
  comments_count: model.number().default(0),
  shares_count: model.number().default(0),
  views_count: model.number().default(0),
  // product_ids stored as JSON array for fast feed queries
  product_ids: model.json().nullable(),
})

export default ShortVideo
