import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http";
import { z } from "zod";
import { MedusaError } from "@medusajs/framework/utils";

export const PostRequestOtpSchema = z.object({
  mobile: z.string(),
  payment_method: z.string(),
});

export const POST = async (req: MedusaRequest, res: MedusaResponse) => {
  try {
    const validated = PostRequestOtpSchema.parse(req.body);

    const apiUrl = process.env.KASHFLOW_API_URL || "https://api.kashflow-service.com";
    const apiKey = process.env.KASHFLOW_APP_KEY;
    const secretKey = process.env.KASHFLOW_SECRET_KEY;

    const response = await fetch(`${apiUrl}/api/v1/payments/request-otp`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-API-Key": apiKey || "",
        "X-Secret": secretKey || "",
      },
      body: JSON.stringify(validated),
    });

    const data = await response.json().catch(() => ({}));

    if (!response.ok) {
      console.error("KashFlow API Error:", data);
      // Propagate the actual error message from KashFlow
      throw new MedusaError(
        MedusaError.Types.INVALID_DATA,
        data.message || "Failed to request OTP from KashFlow"
      );
    }

    res.json(data);
  } catch (error: any) {
    if (error instanceof MedusaError) {
      throw error; // Let Medusa error handler process it
    }
    console.error("Route Error:", error);
    throw new MedusaError(MedusaError.Types.UNEXPECTED_STATE, error.message);
  }
};
