import {
  createStep,
  StepResponse,
  createWorkflow,
  WorkflowResponse
} from "@medusajs/framework/workflows-sdk"
import { emitEventStep } from "@medusajs/core-flows"
import { SHORT_VIDEO_MODULE } from "../../../modules/short-video"
import ShortVideoService from "../../../modules/short-video/service"

export type ProcessVideoInput = {
  id: string
  video_url: string
}

const processVideoStep = createStep(
  "process-video-step",
  async (input: ProcessVideoInput, { container }) => {
    console.log(`[Video] Auto-processing video ${input.id}: using default format.`)

    const service = container.resolve(SHORT_VIDEO_MODULE) as ShortVideoService

    // On marque directement la vidéo comme publiée en utilisant l'URL d'origine
    const video = await service.markAsProcessed(input.id, input.video_url)

    return new StepResponse({
      id: input.id,
      status: "published",
      vendor_id: (video as any).vendor_id,
      title: (video as any).title,
      thumbnail_url: (video as any).thumbnail_url,
    })
  }
)

const processVideoWorkflow = createWorkflow(
  "process-short-video",
  (input: ProcessVideoInput) => {
    const result = processVideoStep(input)

    emitEventStep({
      eventName: "short_video.published",
      data: {
        video_id: result.id,
        vendor_id: result.vendor_id,
        title: result.title,
        thumbnail_url: result.thumbnail_url,
      },
    })

    return new WorkflowResponse(result)
  }
)

export default processVideoWorkflow
