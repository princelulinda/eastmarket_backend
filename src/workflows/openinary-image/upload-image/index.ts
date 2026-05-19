import { 
  createStep, 
  StepResponse, 
  createWorkflow, 
  WorkflowResponse 
} from "@medusajs/framework/workflows-sdk"

export type UploadImageInput = {
  file_path: string // Le chemin local ou l'URL temporaire de l'image à uploader
  folder?: string   // Dossier de destination sur Openinary
}

export const openinaryImageUploadStep = createStep(
  "openinary-image-upload",
  async (input: UploadImageInput, { container }) => {
    const apiKey = process.env.OPENINARY_API_KEY
    const baseUrl = process.env.OPENINARY_API_URL || "http://l36hrqg92zk0lgnpfrjiiv79.187.124.26.34.sslip.io:3000"

    console.log(`[Openinary] Uploading image from ${input.file_path} to folder: ${input.folder || "root"}`)

    // Dans un vrai projet, ceci utiliserait la bibliothèque Openinary ou fetch
    // pour uploader le fichier depuis input.file_path vers l'endpoint /upload.
    // Openinary renvoie un 'public_id' unique et une URL de base.
    
    // Simulation de la réponse :
    const simulatedPublicId = `marketplace/${input.folder || "general"}/${Date.now()}_${Math.random().toString(36).substring(7)}`
    const simulatedUrl = `${baseUrl}/storage/${simulatedPublicId}` // URL source

    // Ici, on pourrait aussi créer l'asset dans la DB Medusa
    // const asset = await imageService.create({ public_id: simulatedPublicId, url: simulatedUrl, resource_type: 'image' })

    return new StepResponse({
      public_id: simulatedPublicId,
      url: simulatedUrl, // L'URL brute de l'image
      status: "success"
    })
  }
)

const openinaryImageUploadWorkflow = createWorkflow(
  "openinary-image-upload-workflow",
  (input: UploadImageInput) => {
    const result = openinaryImageUploadStep(input)
    return new WorkflowResponse(result)
  }
)

export default openinaryImageUploadWorkflow
