import { SubscriberArgs, SubscriberConfig } from "@medusajs/framework"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import {
  sendEmail,
  getVerificationSubmittedTemplate,
} from "../modules/notification-center/email-service"

type EventData = { id: string; vendor_id: string }

/**
 * Accusé de réception du dossier KYC. L'email part vers les admins de la
 * boutique : l'adresse `vendor.email` est facultative et souvent une adresse
 * de contact publique, pas celle du compte.
 */
export default async function vendorVerificationSubmittedHandler({
  event: { data },
  container,
}: SubscriberArgs<EventData>) {
  const query = container.resolve(ContainerRegistrationKeys.QUERY)

  const { data: [vendor] } = await query.graph({
    entity: "vendor",
    fields: ["id", "name", "email", "admins.email"],
    filters: { id: data.vendor_id },
  })

  if (!vendor) return

  const recipients = [
    ...(vendor.admins || []).map((a: { email: string }) => a.email),
    vendor.email,
  ].filter(Boolean)

  const html = getVerificationSubmittedTemplate(vendor.name)

  for (const to of [...new Set(recipients)]) {
    try {
      await sendEmail({
        to,
        subject: "Dossier de vérification reçu - East Market",
        html,
      })
    } catch (err) {
      console.error(`Failed to send verification-submitted email to ${to}:`, err)
    }
  }

  // Signalement à l'équipe de revue, si une adresse est configurée.
  const reviewInbox = process.env.VENDOR_VERIFICATION_INBOX
  if (reviewInbox) {
    try {
      await sendEmail({
        to: reviewInbox,
        subject: `Nouveau dossier vendeur à vérifier : ${vendor.name}`,
        html: `<p>La boutique <strong>${vendor.name}</strong> (${vendor.id}) a soumis un dossier de vérification.</p>
               <p>Dossier : ${data.id}</p>
               <p>À traiter depuis l'admin, section « Vérifications vendeurs ».</p>`,
      })
    } catch (err) {
      console.error("Failed to notify verification review inbox:", err)
    }
  }
}

export const config: SubscriberConfig = {
  event: "vendor.verification_submitted",
}
