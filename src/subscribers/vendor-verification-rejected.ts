import { SubscriberArgs, SubscriberConfig } from "@medusajs/framework"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import {
  sendEmail,
  getVerificationRejectedTemplate,
} from "../modules/notification-center/email-service"
import { notifyVendor } from "../modules/notification-center/notify"

type EventData = { id: string; vendor_id: string; reason: string }

/**
 * Refus du dossier : le motif est transmis intégralement au vendeur, sans quoi
 * il ne sait pas quoi corriger et re-soumet à l'identique.
 */
export default async function vendorVerificationRejectedHandler({
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

  await notifyVendor(container, {
    vendorId: vendor.id,
    type: "system",
    title: "Dossier de vérification à corriger",
    body: data.reason,
    data: { verification_id: data.id },
  })

  const recipients = [
    ...(vendor.admins || []).map((a: { email: string }) => a.email),
    vendor.email,
  ].filter(Boolean)

  const html = getVerificationRejectedTemplate(vendor.name, data.reason)

  for (const to of [...new Set(recipients)]) {
    try {
      await sendEmail({
        to,
        subject: "Votre dossier de vérification nécessite une correction - East Market",
        html,
      })
    } catch (err) {
      console.error(`Failed to send verification-rejected email to ${to}:`, err)
    }
  }
}

export const config: SubscriberConfig = {
  event: "vendor.verification_rejected",
}
