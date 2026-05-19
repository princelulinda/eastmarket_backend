import { MedusaService } from "@medusajs/framework/utils"
import ShortVideo from "./models/short-video"
import VideoLike from "./models/video-like"
import VideoComment from "./models/video-comment"
import VideoSave from "./models/video-save"

type CreateVideoInput = {
  vendor_id: string
  title: string
  description?: string
  video_url: string
  thumbnail_url?: string
  duration?: number
  tag?: string
  product_ids?: string[]
}

// MedusaService pluralizes "ShortVideo" → "ShortVideoes" (ends in vowel+o)
class ShortVideoService extends MedusaService({ ShortVideo, VideoLike, VideoComment, VideoSave }) {

  async createVideo(input: CreateVideoInput) {
    return await this.createShortVideoes({
      ...input,
      product_ids: input.product_ids || null,
      status: "draft",
    } as any)
  }

  async updateVideo(id: string, update: Record<string, any>) {
    return await this.updateShortVideoes({ id, ...update } as any)
  }

  async markAsProcessed(id: string, hlsUrl: string) {
    return await this.updateShortVideoes({ id, hls_url: hlsUrl, status: "published" } as any)
  }

  async getFeed(limit = 10, offset = 0) {
    return await this.listShortVideoes(
      { status: "published" } as any,
      { take: limit, skip: offset, order: { created_at: "DESC" } }
    )
  }

  async getVendorVideos(vendorId: string) {
    return await this.listShortVideoes(
      { vendor_id: vendorId } as any,
      { order: { created_at: "DESC" } }
    )
  }

  async toggleLike(videoId: string, customerId: string) {
    const existing = await this.listVideoLikes({ video_id: videoId, customer_id: customerId } as any)
    const video = await this.retrieveShortVideo(videoId)

    if (existing.length > 0) {
      await this.deleteVideoLikes(existing[0].id)
      const newCount = Math.max(0, video.likes_count - 1)
      await this.updateShortVideoes({ id: videoId, likes_count: newCount } as any)
      return { liked: false, likes_count: newCount }
    }

    await this.createVideoLikes({ video_id: videoId, customer_id: customerId } as any)
    const newCount = video.likes_count + 1
    await this.updateShortVideoes({ id: videoId, likes_count: newCount } as any)
    return { liked: true, likes_count: newCount }
  }

  async toggleSave(videoId: string, customerId: string) {
    const existing = await this.listVideoSaves({ video_id: videoId, customer_id: customerId } as any)

    if (existing.length > 0) {
      await this.deleteVideoSaves(existing[0].id)
      return { saved: false }
    }

    await this.createVideoSaves({ video_id: videoId, customer_id: customerId } as any)
    return { saved: true }
  }

  async addComment(videoId: string, customerId: string, content: string) {
    const comment = await this.createVideoComments({
      video_id: videoId,
      customer_id: customerId,
      content,
    } as any)
    const video = await this.retrieveShortVideo(videoId)
    await this.updateShortVideoes({ id: videoId, comments_count: video.comments_count + 1 } as any)
    return comment
  }

  async getComments(videoId: string, limit = 20, offset = 0) {
    return await this.listVideoComments(
      { video_id: videoId } as any,
      { take: limit, skip: offset, order: { created_at: "DESC" } }
    )
  }

  async incrementView(videoId: string) {
    const video = await this.retrieveShortVideo(videoId)
    await this.updateShortVideoes({ id: videoId, views_count: video.views_count + 1 } as any)
  }

  async incrementShare(videoId: string) {
    const video = await this.retrieveShortVideo(videoId)
    await this.updateShortVideoes({ id: videoId, shares_count: video.shares_count + 1 } as any)
  }

  async getSavedVideos(customerId: string) {
    const saves = await this.listVideoSaves({ customer_id: customerId } as any)
    if (saves.length === 0) return []
    const videoIds = saves.map((s: any) => s.video_id)
    return await this.listShortVideoes({ id: videoIds } as any, { order: { created_at: "DESC" } })
  }
}

export default ShortVideoService
