import {
  createStep,
  StepResponse,
  createWorkflow,
  WorkflowResponse
} from "@medusajs/framework/workflows-sdk"
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
    await service.markAsProcessed(input.id, input.video_url)
    
    return new StepResponse({ id: input.id, status: "published" })
  }
)

const processVideoWorkflow = createWorkflow(
  "process-short-video",
  (input: ProcessVideoInput) => {
    const result = processVideoStep(input)
    return new WorkflowResponse(result)
  }
)

export default processVideoWorkflow
