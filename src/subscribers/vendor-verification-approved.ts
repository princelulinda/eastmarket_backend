import { SubscriberArgs, SubscriberConfig } from "@medusajs/framework"
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { updateProductsWorkflow } from "@medusajs/medusa/core-flows"
import {
  sendEmail,
  getVerificationApprovedTemplate,
} from "../modules/notification-center/email-service"
import { notifyVendor } from "../modules/notification-center/notify"
import { PENDING_VERIFICATION_FLAG } from "../api/middlewares/require-approved-vendor"

type EventData = { id: string; vendor_id: string }

/**
 * À l'approbation du dossier : la boutique s'ouvre.
 *
 * On publie les produits que forceDraftUntilApproved avait retenus en
 * brouillon — et eux seuls : un brouillon que le vendeur a délibérément laissé
 * en brouillon (pas de flag) reste en brouillon.
 */
export default async function vendorVerificationApprovedHandler({
  event: { data },
  container,
}: SubscriberArgs<EventData>) {
  const query = container.resolve(ContainerRegistrationKeys.QUERY)

  const { data: [vendor] } = await query.graph({
    entity: "vendor",
    fields: [
      "id", "name", "email",
      "admins.email",
      "products.id", "products.status", "products.metadata",
    ],
    filters: { id: data.vendor_id },
  })

  if (!vendor) return

  const toPublish = (vendor.products || []).filter(
    (p: any) => p.status === "draft" && p.metadata?.[PENDING_VERIFICATION_FLAG] === true
  )

  if (toPublish.length > 0) {
    try {
      await updateProductsWorkflow(container).run({
        input: {
          products: toPublish.map((p: any) => ({
            id: p.id,
            status: "published" as const,
            // updateProducts FUSIONNE les métadonnées : omettre la clé la
            // laisserait en place. On l'annule explicitement, sinon le produit
            // resterait éligible à une republication lors d'une approbation
            // ultérieure — y compris après que le vendeur l'a remis en brouillon.
            metadata: { ...(p.metadata ?? {}), [PENDING_VERIFICATION_FLAG]: null },
          })),
        },
      })
    } catch (err) {
      console.error(`Failed to publish pending products for vendor ${vendor.id}:`, err)
    }
  }

  const publishedCount = toPublish.length

  await notifyVendor(container, {
    vendorId: vendor.id,
    type: "system",
    title: "Votre boutique est vérifiée",
    body: publishedCount > 0
      ? `Le badge « Vérifié » est actif et ${publishedCount} produit${publishedCount > 1 ? "s ont" : " a"} été mis en ligne.`
      : "Le badge « Vérifié » est actif. Vos prochains produits seront publiés directement.",
    data: { verification_id: data.id, published_products: publishedCount },
  })

  const recipients = [
    ...(vendor.admins || []).map((a: { email: string }) => a.email),
    vendor.email,
  ].filter(Boolean)

  const html = getVerificationApprovedTemplate(vendor.name, publishedCount)

  for (const to of [...new Set(recipients)]) {
    try {
      await sendEmail({
        to,
        subject: "Votre boutique est vérifiée - East Market",
        html,
      })
    } catch (err) {
      console.error(`Failed to send verification-approved email to ${to}:`, err)
    }
  }
}

export const config: SubscriberConfig = {
  event: "vendor.verification_approved",
}
