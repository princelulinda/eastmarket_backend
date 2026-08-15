import {
  AuthenticatedMedusaRequest,
  MedusaResponse
} from "@medusajs/framework"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { SHORT_VIDEO_MODULE } from "../../../modules/short-video"
import ShortVideoService from "../../../modules/short-video/service"
import { FOLLOW_MODULE } from "../../../modules/follow"
import FollowModuleService from "../../../modules/follow/service"

// Minimum candidate pool to rank over — big enough that a few pages of
// pagination land within the same ranked pool without re-ranking mid-scroll.
const MIN_POOL_SIZE = 40

export const GET = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const service = req.scope.resolve(SHORT_VIDEO_MODULE) as ShortVideoService
  const followService = req.scope.resolve(FOLLOW_MODULE) as FollowModuleService
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)
  const { limit = 10, offset = 0, filter, customer_id } = req.query as any

  const numLimit = Number(limit)
  const numOffset = Number(offset)

  const followedVendorIds = customer_id
    ? await followService.listFollowedVendorIds(customer_id as string)
    : []

  let videos: any[]

  if (filter === "following") {
    // A real "Following" feed — was purely cosmetic before, always showed
    // the generic feed regardless of this tab.
    if (followedVendorIds.length === 0) {
      videos = []
    } else {
      const pool = await service.getFeedForVendors(followedVendorIds, numOffset + numLimit + MIN_POOL_SIZE)
      videos = pool.slice(numOffset, numOffset + numLimit)
    }
  } else {
    // "For You" — weighted ranking over a recent candidate pool: followed
    // vendors get the strongest boost, then engagement (likes/views), with
    // recency as the tiebreaker/base signal.
    const poolSize = Math.max(numOffset + numLimit, MIN_POOL_SIZE)
    const pool = await service.getCandidateFeed(poolSize)

    const scored = pool.map((v: any, idx: number) => {
      let score = pool.length - idx
      if (v.vendor_id && followedVendorIds.includes(v.vendor_id)) {
        score += pool.length * 2
      }
      score += (v.likes_count || 0) * 0.5 + (v.views_count || 0) * 0.05
      return { video: v, score }
    })
    scored.sort((a, b) => b.score - a.score)
    videos = scored.slice(numOffset, numOffset + numLimit).map((s) => s.video)
  }

  // Populate liked/saved for the requesting customer — the frontend Video
  // type already expects these fields, but nothing ever set them before.
  if (customer_id && videos.length > 0) {
    const videoIds = videos.map((v: any) => v.id)
    const [likedSet, savedSet] = await Promise.all([
      service.getCustomerLikedVideoIds(customer_id as string, videoIds),
      service.getCustomerSavedVideoIds(customer_id as string, videoIds),
    ])
    for (const video of videos) {
      video.liked = likedSet.has(video.id)
      video.saved = savedSet.has(video.id)
    }
  }

  // Extract all unique vendor IDs
  const vendorIds = Array.from(
    new Set(videos.map((v: any) => v.vendor_id).filter(Boolean))
  )

  if (vendorIds.length > 0) {
    const { data: vendors } = await query.graph({
      entity: "vendor",
      fields: ["id", "name", "logo"],
      filters: { id: vendorIds }
    })

    const vendorMap = new Map(vendors.map((v: any) => [v.id, v]))
    for (const video of videos) {
      if (video.vendor_id) {
        (video as any).vendor = vendorMap.get(video.vendor_id)
      }
    }
  }

  // Extract all unique product IDs from the videos
  const productIds = Array.from(
    new Set(videos.flatMap((v: any) => v.product_ids || []))
  )

  if (productIds.length > 0) {
    const { data: products } = await query.graph({
      entity: "product",
      fields: ["id", "title", "thumbnail", "variants.prices.*"],
      filters: { id: productIds }
    })

    // Map products to videos
    const productMap = new Map(products.map((p: any) => [p.id, p]))

    for (const video of videos) {
      if (video.product_ids) {
        (video as any).products = video.product_ids
          .map((id: string) => productMap.get(id))
          .filter(Boolean)
      }
    }
  }

  res.json({
    videos,
  })
}
