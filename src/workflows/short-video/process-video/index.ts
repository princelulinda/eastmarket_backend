import {
  createStep,
  StepResponse,
  createWorkflow,
  WorkflowResponse
} from "@medusajs/framework/workflows-sdk"

export type ProcessVideoInput = {
  id: string
  video_url: string
}

// Placeholder step — integrate with your video processing service (FFmpeg, Cloudinary, etc.)
const processVideoStep = createStep(
  "process-video-step",
  async (input: ProcessVideoInput) => {
    console.log(`[Video] Processing video ${input.id}: ${input.video_url}`)
    // TODO: integrate FFmpeg / Cloudinary / AWS MediaConvert here
    return new StepResponse({ id: input.id, status: "processed" })
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
