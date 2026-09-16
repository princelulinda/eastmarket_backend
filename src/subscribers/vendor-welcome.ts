import { SubscriberArgs, SubscriberConfig } from "@medusajs/framework"
import { ContainerRegistrationKeys, Modules } from "@medusajs/framework/utils"
import {
  sendEmail,
  getWelcomeEmailTemplate,
} from "../modules/notification-center/email-service"
import { vendorVerifiedCacheKey } from "../modules/notification-center/email-verification"

// À la création d'un admin vendeur : email de bienvenue. Couvre les deux
// chemins — création de la boutique (POST /vendors) et ajout d'un admin
// supplémentaire (POST /vendors/admins). Les deux chemins exigent en amont un
// email confirmé — requireVerifiedVendorEmail pour l'un, requireVerifiedInviteEmail
// pour l'autre — on consomme donc le ticket ici.
export default async function vendorWelcomeHandler({
  event: { data },
  container,
}: SubscriberArgs<{ id: string }>) {
  const query = container.resolve(ContainerRegistrationKeys.QUERY)

  const { data: [vendorAdmin] } = await query.graph({
    entity: "vendor_admin",
    fields: ["id", "email", "first_name", "last_name", "vendor.name"],
    filters: { id: data.id },
  })

  if (!vendorAdmin?.email) return

  const name =
    `${vendorAdmin.first_name || ""} ${vendorAdmin.last_name || ""}`.trim() ||
    vendorAdmin.vendor?.name ||
    vendorAdmin.email

  try {
    await sendEmail({
      to: vendorAdmin.email,
      subject: "Bienvenue sur East Market !",
      html: getWelcomeEmailTemplate(name, "vendor"),
    })
  } catch (err) {
    console.error(`Failed to send welcome email to vendor admin ${vendorAdmin.email}:`, err)
  }

  // Ticket à usage unique : il ne doit pas resservir pour une autre boutique.
  try {
    const cache = container.resolve(Modules.CACHE)
    await cache.invalidate(vendorVerifiedCacheKey(vendorAdmin.email))
  } catch (err) {
    console.error(`Failed to invalidate vendor verification ticket for ${vendorAdmin.email}:`, err)
  }
}

export const config: SubscriberConfig = {
  event: "vendor_admin.created",
}
