import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { Modules, MedusaError } from "@medusajs/framework/utils"

const ALLOWED_MIME_TYPES = [
  "image/jpeg",
  "image/png",
  "image/webp",
  "image/heic",
  "application/pdf",
]

const MAX_FILE_SIZE_BYTES = 10 * 1024 * 1024 // 10 Mo

/**
 * Upload des pièces d'un dossier KYC.
 *
 * Volontairement séparé de POST /vendors/upload : cette route-là crée les
 * fichiers en `access: "public"`, ce qui est correct pour un logo mais
 * inacceptable pour une pièce d'identité. Ici les fichiers sont privés et la
 * réponse ne contient aucune URL — seulement la clé, que seul l'admin pourra
 * échanger contre une URL signée à durée limitée.
 */
export const POST = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const fileService = req.scope.resolve(Modules.FILE)

  const files = (req as any).files as Express.Multer.File[]
  if (!files || files.length === 0) {
    throw new MedusaError(MedusaError.Types.INVALID_DATA, "Aucun fichier envoyé.")
  }

  for (const file of files) {
    if (!ALLOWED_MIME_TYPES.includes(file.mimetype)) {
      throw new MedusaError(
        MedusaError.Types.INVALID_DATA,
        `Format non accepté : ${file.mimetype}. Envoyez une image (JPEG, PNG, WebP, HEIC) ou un PDF.`
      )
    }
    if (file.size > MAX_FILE_SIZE_BYTES) {
      throw new MedusaError(
        MedusaError.Types.INVALID_DATA,
        `${file.originalname} dépasse la taille maximale de 10 Mo.`
      )
    }
  }

  const uploaded = await Promise.all(
    files.map((file) =>
      fileService.createFiles({
        filename: file.originalname,
        mimeType: file.mimetype,
        content: file.buffer.toString("base64"),
        access: "private",
      })
    )
  )

  res.json({
    files: uploaded.map((f: any, i: number) => ({
      file_id: f.id,
      filename: files[i].originalname,
    })),
  })
}
