import { z } from "@medusajs/framework/zod"
import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, Modules, MedusaError } from "@medusajs/framework/utils"
import { checkVerificationCode } from "../../../../../modules/notification-center/email-verification"

export const PostVerifyEmailSchema = z.object({
  code: z.string().min(4).max(6),
}).strict()

type PostBody = z.infer<typeof PostVerifyEmailSchema>

export const POST = async (req: AuthenticatedMedusaRequest<PostBody>, res: MedusaResponse) => {
  const customerId = req.auth_context.actor_id
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const { data: [customer] } = await query.graph({
    entity: "customer",
    fields: ["id", "metadata"],
    filters: { id: customerId },
  })

  const metadata = customer?.metadata as Record<string, any> | null

  if (metadata?.email_verified) {
    return res.json({ verified: true })
  }

  const result = checkVerificationCode(metadata, req.validatedBody.code.trim())

  if (result.valid === false) {
    const messages: Record<typeof result.reason, string> = {
      no_pending_code: "Aucune vérification en attente. Demandez un nouveau code.",
      expired: "Ce code a expiré. Demandez un nouveau code.",
      mismatch: "Code incorrect.",
    }
    throw new MedusaError(MedusaError.Types.INVALID_DATA, messages[result.reason])
  }

  const customerModule = req.scope.resolve(Modules.CUSTOMER)
  await customerModule.updateCustomers(customerId, {
    metadata: {
      ...metadata,
      email_verified: true,
      verification_code_hash: null,
      verification_code_expires_at: null,
    },
  })

  res.json({ verified: true })
}
