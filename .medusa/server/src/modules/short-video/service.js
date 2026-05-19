"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const utils_1 = require("@medusajs/framework/utils");
const short_video_1 = require("./models/short-video");
const video_like_1 = require("./models/video-like");
const video_comment_1 = require("./models/video-comment");
const video_save_1 = require("./models/video-save");

class ShortVideoService extends (0, utils_1.MedusaService)({
  ShortVideo: short_video_1.default,
  VideoLike: video_like_1.default,
  VideoComment: video_comment_1.default,
  VideoSave: video_save_1.default,
}) {
  async createVideo(input) {
    return await this.createShortVideoes({
      ...input,
      product_ids: input.product_ids || null,
      status: "draft",
    });
  }

  async updateVideo(id, update) {
    return await this.updateShortVideoes({ id, ...update });
  }

  async markAsProcessed(id, hlsUrl) {
    return await this.updateShortVideoes({ id, hls_url: hlsUrl, status: "published" });
  }

  async getFeed(limit = 10, offset = 0) {
    return await this.listShortVideoes(
      { status: "published" },
      { take: limit, skip: offset, order: { created_at: "DESC" } }
    );
  }

  async getVendorVideos(vendorId) {
    return await this.listShortVideoes(
      { vendor_id: vendorId },
      { order: { created_at: "DESC" } }
    );
  }

  async toggleLike(videoId, customerId) {
    const existing = await this.listVideoLikes({ video_id: videoId, customer_id: customerId });
    const video = await this.retrieveShortVideo(videoId);
    if (existing.length > 0) {
      await this.deleteVideoLikes(existing[0].id);
      const newCount = Math.max(0, video.likes_count - 1);
      await this.updateShortVideoes({ id: videoId, likes_count: newCount });
      return { liked: false, likes_count: newCount };
    }
    await this.createVideoLikes({ video_id: videoId, customer_id: customerId });
    const newCount = video.likes_count + 1;
    await this.updateShortVideoes({ id: videoId, likes_count: newCount });
    return { liked: true, likes_count: newCount };
  }

  async toggleSave(videoId, customerId) {
    const existing = await this.listVideoSaves({ video_id: videoId, customer_id: customerId });
    if (existing.length > 0) {
      await this.deleteVideoSaves(existing[0].id);
      return { saved: false };
    }
    await this.createVideoSaves({ video_id: videoId, customer_id: customerId });
    return { saved: true };
  }

  async addComment(videoId, customerId, content) {
    const comment = await this.createVideoComments({ video_id: videoId, customer_id: customerId, content });
    const video = await this.retrieveShortVideo(videoId);
    await this.updateShortVideoes({ id: videoId, comments_count: video.comments_count + 1 });
    return comment;
  }

  async getComments(videoId, limit = 20, offset = 0) {
    return await this.listVideoComments(
      { video_id: videoId },
      { take: limit, skip: offset, order: { created_at: "DESC" } }
    );
  }

  async incrementView(videoId) {
    const video = await this.retrieveShortVideo(videoId);
    await this.updateShortVideoes({ id: videoId, views_count: video.views_count + 1 });
  }

  async incrementShare(videoId) {
    const video = await this.retrieveShortVideo(videoId);
    await this.updateShortVideoes({ id: videoId, shares_count: video.shares_count + 1 });
  }

  async getSavedVideos(customerId) {
    const saves = await this.listVideoSaves({ customer_id: customerId });
    if (saves.length === 0) return [];
    const videoIds = saves.map((s) => s.video_id);
    return await this.listShortVideoes({ id: videoIds }, { order: { created_at: "DESC" } });
  }
}

exports.default = ShortVideoService;
