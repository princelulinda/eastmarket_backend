import {
  AuthenticatedMedusaRequest,
  MedusaResponse,
} from "@medusajs/framework/http"
import { Modules } from "@medusajs/framework/utils"

export const POST = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  const fileService = req.scope.resolve(Modules.FILE)

  const files = (req as any).files as Express.Multer.File[]
   console.log(files)
  if (!files || files.length === 0) {
    return res.status(400).json({ message: "No file uploaded" })
  }

  const uploaded = await Promise.all(
    files.map((file) =>
      fileService.createFiles({
        filename: file.originalname,
        mimeType: file.mimetype,
        content: file.buffer.toString("base64"),
        access: "public",
      })
    )
  )

  res.json({
    files: uploaded.map((f: any) => ({
      id: f.id,
      url: f.url,
      filename: f.filename,
      mime_type: f.mime_type,
      size: f.size,
    })),
  })
}
