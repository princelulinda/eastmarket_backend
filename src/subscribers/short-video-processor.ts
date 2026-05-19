import { 
  type SubscriberConfig, 
  type SubscriberArgs 
} from "@medusajs/framework"
import processVideoWorkflow from "../workflows/short-video/process-video"

export default async function shortVideoProcessor({ 
  event, 
  container 
}: SubscriberArgs<any>) {
  const { id, video_url } = event.data

  console.log(`[Production] Nouvelle vidéo détectée : ${id}. Lancement du Workflow de traitement...`)

  await processVideoWorkflow(container).run({
    input: {
      id,
      video_url
    }
  })
}

export const config: SubscriberConfig = {
  event: "short_video.created",
}
