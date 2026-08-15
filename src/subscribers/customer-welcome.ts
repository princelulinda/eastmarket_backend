import { SubscriberArgs, SubscriberConfig } from "@medusajs/framework"
import { ContainerRegistrationKeys, Modules } from "@medusajs/framework/utils"
import {
  sendEmail,
  getWelcomeEmailTemplate,
  getVerifyEmailTemplate,
} from "../modules/notification-center/email-service"
import { generateVerificationCode, buildVerificationMetadata } from "../modules/notification-center/email-verification"

const verifiedCacheKey = (email: string) => `register_verified:${email.toLowerCase()}`

// À l'inscription : email de bienvenue à chaque nouveau client.
// Si l'email a déjà été confirmé via le flux en 3 étapes
// (/store/auth/register/{start,confirm}, étape 2), on marque directement
// email_verified — pas besoin d'un nouveau code. Sinon (ex. compte créé par
// un autre biais), on génère et envoie un code comme avant.
export default async function customerWelcomeHandler({
  event: { data },
  container,
}: SubscriberArgs<{ id: string }>) {
  const query = container.resolve(ContainerRegistrationKeys.QUERY)

  const { data: [customer] } = await query.graph({
    entity: "customer",
    fields: ["id", "email", "first_name", "last_name", "metadata"],
    filters: { id: data.id },
  })

  if (!customer?.email) return

  const name = `${customer.first_name || ""} ${customer.last_name || ""}`.trim() || customer.email

  try {
    await sendEmail({
      to: customer.email,
      subject: "Bienvenue sur East Market !",
      html: getWelcomeEmailTemplate(name, "customer"),
    })
  } catch (err) {
    console.error(`Failed to send welcome email to customer ${customer.email}:`, err)
  }

  const customerModule = container.resolve(Modules.CUSTOMER)
  const cache = container.resolve(Modules.CACHE)
  const alreadyVerified = await cache.get<boolean>(verifiedCacheKey(customer.email))

  if (alreadyVerified) {
    await customerModule.updateCustomers(customer.id, {
      metadata: {
        ...(customer.metadata as Record<string, any> | null),
        email_verified: true,
      },
    })
    return
  }

  try {
    const code = generateVerificationCode()
    await customerModule.updateCustomers(customer.id, {
      metadata: {
        ...(customer.metadata as Record<string, any> | null),
        ...buildVerificationMetadata(code),
      },
    })

    await sendEmail({
      to: customer.email,
      subject: "Confirmez votre adresse email - East Market",
      html: getVerifyEmailTemplate(name, code),
    })
  } catch (err) {
    console.error(`Failed to send verification email to customer ${customer.email}:`, err)
  }
}

export const config: SubscriberConfig = {
  event: "customer.created",
}
