import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { SHORT_VIDEO_MODULE } from "../../../../../modules/short-video"
import ShortVideoService from "../../../../../modules/short-video/service"

export const POST = async (req: MedusaRequest, res: MedusaResponse) => {
  const svc: ShortVideoService = req.scope.resolve(SHORT_VIDEO_MODULE)
  await svc.incrementShare(req.params.id)
  res.json({ success: true })
}
