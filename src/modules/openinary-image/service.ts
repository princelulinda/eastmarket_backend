import { MedusaService } from "@medusajs/framework/utils"
import OpeninaryAsset from "./models/openinary-asset"

class OpeninaryImageService extends MedusaService({
  OpeninaryAsset,
}) {

  /**
   * Récupère une URL optimisée pour une image donnée.
   * @param publicId L'identifiant unique de l'image sur Openinary.
   * @param transformations Les transformations à appliquer (ex: 'w_500,h_500,c_fill,q_auto,f_webp').
   * @returns L'URL de l'image transformée.
   */
  public getOptimizedImageUrl(publicId: string, transformations: string): string {
    const baseUrl = process.env.OPENINARY_API_URL || "https://api.openinary.dev"
    // La documentation d'Openinary suggère un format d'URL pour les transformations
    return `${baseUrl}/t/${transformations}/${publicId}`
  }
}

export default OpeninaryImageService
