import { 
  AuthenticatedMedusaRequest, 
  MedusaResponse 
} from "@medusajs/framework"
import { z } from "zod"
import openinaryImageUploadWorkflow from "../../../workflows/openinary-image/upload-image"
import { OPENINARY_IMAGE_MODULE } from "../../../modules/openinary-image"
import OpeninaryImageService from "../../../modules/openinary-image/service"

// Schéma pour la requête d'upload
export const UploadImageSchema = z.object({
  // Le chemin local du fichier ou une URL temporaire de l'image
  file_path: z.string().min(1), 
  folder: z.string().optional(), // Dossier pour organiser les images sur Openinary
})

// POST /store/images/upload
export const POST = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const validated = UploadImageSchema.parse(req.body)
  
  // Lancer le workflow d'upload
  const { result } = await openinaryImageUploadWorkflow(req.scope).run({
    input: {
      file_path: validated.file_path,
      folder: validated.folder,
    }
  })

  // Dans un scénario réel, vous enregistreriez aussi l'asset dans votre DB Medusa
  // via le service OpeninaryImageService.createOpeninaryAsset(...)

  res.json({
    asset: {
      public_id: result.public_id,
      url: result.url, // URL brute de l'image sur Openinary
    }
  })
}

// GET /store/images/optimized
export const GET = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const { public_id, transformations } = req.query as { public_id: string, transformations: string }
  
  // Ex: transformations = "w_500,h_500,c_fill,q_auto,f_webp"
  if (!public_id || !transformations) {
    return res.status(400).json({ message: "public_id and transformations are required" })
  }

  const openinaryService = req.scope.resolve(OPENINARY_IMAGE_MODULE) as OpeninaryImageService
  const optimizedUrl = openinaryService.getOptimizedImageUrl(public_id, transformations)

  res.json({
    optimized_url: optimizedUrl
  })
}
