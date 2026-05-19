import { 
  createStep, 
  StepResponse, 
  createWorkflow, 
  WorkflowResponse 
} from "@medusajs/framework/workflows-sdk"

export type UploadImageInput = {
  file_path: string // Le chemin local ou l'URL temporaire
  folder?: string
}

export const openinaryUploadStep = createStep(
  "openinary-upload",
  async (input: UploadImageInput, { container }) => {
    const apiKey = process.env.OPENINARY_API_KEY
    const baseUrl = process.env.OPENINARY_API_URL || "https://api.openinary.dev"

    console.log(`[Openinary] Uploading image to folder: ${input.folder || "root"}`)

    // En production, nous utiliserions 'form-data' pour envoyer le fichier réel
    // Ici, nous simulons l'appel à l'endpoint /upload d'Openinary
    
    // Exemple d'appel réel avec fetch :
    /*
    const formData = new FormData();
    formData.append('file', file);
    const response = await fetch(`${baseUrl}/upload`, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${apiKey}` },
      body: formData
    });
    const data = await response.json();
    */

    return new StepResponse({
      public_id: `marketplace/${input.folder || "general"}/image_${Date.now()}`,
      url: `${baseUrl}/storage/path/to/image.jpg`,
      status: "success"
    })
  }
)

const openinaryUploadWorkflow = createWorkflow(
  "openinary-upload-workflow",
  (input: UploadImageInput) => {
    const result = openinaryUploadStep(input)
    return new WorkflowResponse(result)
  }
)

export default openinaryUploadWorkflow
