import { AuthenticatedMedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { ContainerRegistrationKeys, Modules, MedusaError } from "@medusajs/framework/utils"
import { sendEmail, getVerifyEmailTemplate } from "../../../../../modules/notification-center/email-service"
import { generateVerificationCode, buildVerificationMetadata, canResend } from "../../../../../modules/notification-center/email-verification"

export const POST = async (req: AuthenticatedMedusaRequest, res: MedusaResponse) => {
  const customerId = req.auth_context.actor_id
  const query = req.scope.resolve(ContainerRegistrationKeys.QUERY)

  const { data: [customer] } = await query.graph({
    entity: "customer",
    fields: ["id", "email", "first_name", "last_name", "metadata"],
    filters: { id: customerId },
  })

  if (!customer?.email) {
    throw new MedusaError(MedusaError.Types.NOT_FOUND, "Customer not found")
  }

  const metadata = customer.metadata as Record<string, any> | null

  if (metadata?.email_verified) {
    return res.json({ verified: true })
  }

  if (!canResend(metadata)) {
    throw new MedusaError(MedusaError.Types.NOT_ALLOWED, "Veuillez patienter avant de redemander un code.")
  }

  const code = generateVerificationCode()
  const customerModule = req.scope.resolve(Modules.CUSTOMER)
  await customerModule.updateCustomers(customerId, {
    metadata: {
      ...metadata,
      ...buildVerificationMetadata(code),
    },
  })

  const name = `${customer.first_name || ""} ${customer.last_name || ""}`.trim() || customer.email

  await sendEmail({
    to: customer.email,
    subject: "Confirmez votre adresse email - East Market",
    html: getVerifyEmailTemplate(name, code),
  })

  res.json({ sent: true })
}
