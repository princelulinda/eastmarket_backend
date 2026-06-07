import { 
  AuthenticatedMedusaRequest, 
  MedusaResponse 
} from "@medusajs/framework"
import { z } from "zod"
import { Modules, MedusaError } from "@medusajs/framework/utils"
import { IPaymentModuleService } from "@medusajs/framework/types"

export const PostInitializePaymentSchema = z.object({
  amount: z.number(),
  currency: z.string(),
  payment_method: z.string(),
  initiator: z.string(),
  vendor_email: z.string().email(),
  otp: z.string().optional(),
})

export const POST = async (
  req: AuthenticatedMedusaRequest,
  res: MedusaResponse
) => {
  try {
    const validated = PostInitializePaymentSchema.parse(req.body)
    const paymentModule = req.scope.resolve(Modules.PAYMENT) as IPaymentModuleService

    // Note: The KashFlowPaymentService expect 'context' with amount, currency_code, resource_id
    const context = {
      amount: validated.amount,
      currency_code: validated.currency,
      resource_id: `payment_${Date.now()}`, // Temporary reference
      initiator: validated.initiator,
      otp: validated.otp,
      vendor_email: validated.vendor_email
    }

    // Direct provider invocation check
    throw new MedusaError(
      MedusaError.Types.NOT_ALLOWED,
      "Direct provider invocation is not supported. Please use Medusa's standard Payment Workflow to manage payment sessions."
    );
  } catch (error: any) {
    if (error instanceof MedusaError) {
      throw error;
    }
    console.error("Initialize Payment Route Error:", error);
    throw new MedusaError(MedusaError.Types.UNEXPECTED_STATE, error.message || "An unexpected error occurred during payment initialization.");
  }
}
