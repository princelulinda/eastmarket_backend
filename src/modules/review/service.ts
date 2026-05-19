import { MedusaService } from "@medusajs/framework/utils"
import Review from "./models/review"

export class ReviewModuleService extends MedusaService({
  Review,
}) {}
