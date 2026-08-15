import nodemailer from "nodemailer"

const host = process.env.SMTP_HOST
const port = parseInt(process.env.SMTP_PORT || "587")
const user = process.env.SMTP_USER
const pass = process.env.SMTP_PASS
const secure = process.env.SMTP_SECURE === "true"
const from = process.env.SMTP_FROM || "noreply@eastmarket.africa"

let transporter: nodemailer.Transporter | null = null

function getTransporter() {
  if (!transporter) {
    if (!host || !user || !pass) {
      console.warn("⚠️ SMTP environment variables are not fully configured. Email sending will be simulated and logged to the console.")
      return null
    }
    transporter = nodemailer.createTransport({
      host,
      port,
      secure,
      auth: {
        user,
        pass,
      },
    })
  }
  return transporter
}

export interface SendEmailInput {
  to: string
  subject: string
  html: string
  text?: string
}

export async function sendEmail({ to, subject, html, text }: SendEmailInput) {
  const client = getTransporter()
  if (!client) {
    console.log(`[EMAIL SEND SIMULATION]
To: ${to}
Subject: ${subject}
Body (HTML Snippet): ${html.substring(0, 300)}...
    `)
    return { messageId: "simulated-id" }
  }

  try {
    const info = await client.sendMail({
      from,
      to,
      subject,
      html,
      text: text || html.replace(/<[^>]*>/g, ""),
    })
    console.log(`📧 Email sent to ${to}: ${info.messageId}`)
    return info
  } catch (error) {
    console.error("❌ Failed to send email via SMTP:", error)
    throw error
  }
}

// ── Design system ────────────────────────────────────────────────────────
// Mêmes tokens que l'app mobile : orange de marque, fond chaud, encre douce.

const BRAND = "#FF5000"
const BRAND_DARK = "#E64500"
const CANVAS = "#F7F5F2"
const SURFACE = "#FFFFFF"
const LINE = "#EFEDE9"
const INK = "#1F2937"
const INK_SOFT = "#6B7280"
const LOGO_URL = "https://www.eastmarket.africa/logo.png"
const SITE_URL = "https://eastmarket.africa"
const CURRENT_YEAR = new Date().getFullYear()

function formatMoney(cents: number | undefined, currency: string | undefined) {
  const amount = ((cents ?? 0) / 100).toFixed(2)
  return `${amount} ${currency?.toUpperCase() || "USD"}`
}

/**
 * Coquille commune à tous les emails : en-tête avec logo, carte de contenu,
 * pied de page. Chaque template ne fournit que son contenu interne (bodyHtml).
 */
function emailShell(options: {
  title: string
  preheader?: string
  bodyHtml: string
  headerTag?: string
}) {
  const { title, preheader = "", bodyHtml, headerTag } = options

  return `
    <!DOCTYPE html>
    <html lang="fr">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <meta name="color-scheme" content="light">
      <title>${title}</title>
      <style>
        body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; background-color: ${CANVAS}; color: ${INK}; margin: 0; padding: 0; }
        .wrapper { width: 100%; background-color: ${CANVAS}; padding: 24px 0; }
        .container { max-width: 600px; margin: 0 auto; background-color: ${SURFACE}; border-radius: 16px; overflow: hidden; border: 1px solid ${LINE}; }
        .header { background-color: ${BRAND}; background-image: linear-gradient(135deg, #FF6B29, ${BRAND_DARK}); padding: 32px 30px; text-align: center; }
        .header img { height: 36px; width: auto; }
        .header .tag { margin: 10px 0 0; color: rgba(255,255,255,0.85); font-size: 12px; letter-spacing: 1px; text-transform: uppercase; }
        .content { padding: 32px; line-height: 1.65; }
        .content h2 { font-size: 20px; color: ${INK}; margin: 0 0 12px; }
        .content h3 { font-size: 15px; color: ${INK}; margin: 24px 0 10px; }
        .content p { margin: 0 0 14px; color: ${INK}; }
        .muted { color: ${INK_SOFT}; }
        .button { display: inline-block; padding: 14px 28px; background-color: ${BRAND}; color: #ffffff !important; text-decoration: none; border-radius: 10px; font-weight: bold; font-size: 15px; }
        .table { width: 100%; border-collapse: collapse; margin-top: 8px; }
        .card { margin-top: 20px; padding: 18px; background-color: ${CANVAS}; border: 1px solid ${LINE}; border-radius: 12px; }
        .footer { padding: 24px 32px; text-align: center; font-size: 12px; color: ${INK_SOFT}; border-top: 1px solid ${LINE}; }
        .footer a { color: ${INK_SOFT}; }
        .preheader { display: none; max-height: 0; overflow: hidden; }
      </style>
    </head>
    <body>
      <span class="preheader">${preheader}</span>
      <div class="wrapper">
        <div class="container">
          <div class="header">
            <img src="${LOGO_URL}" alt="East Market" />
            ${headerTag ? `<p class="tag">${headerTag}</p>` : ""}
          </div>
          <div class="content">
            ${bodyHtml}
          </div>
          <div class="footer">
            East Market — la marketplace qui connecte vendeurs et clients en toute confiance.<br>
            &copy; ${CURRENT_YEAR} East Market. Tous droits réservés.<br>
            Cet email a été envoyé automatiquement à votre adresse, merci de ne pas y répondre directement.
          </div>
        </div>
      </div>
    </body>
    </html>
  `
}

function itemsTable(items: { title: string; quantity: number; unit_price: number }[], currency?: string) {
  const rows = items.map((item) => `
    <tr>
      <td style="padding: 12px 0; border-bottom: 1px solid ${LINE};">
        <strong>${item.title}</strong><br>
        <span style="font-size: 12px; color: ${INK_SOFT};">Quantité : ${item.quantity}</span>
      </td>
      <td style="padding: 12px 0; border-bottom: 1px solid ${LINE}; text-align: right; white-space: nowrap;">
        ${formatMoney(item.unit_price * item.quantity, currency)}
      </td>
    </tr>
  `).join("")
  return `<table class="table"><tbody>${rows}</tbody></table>`
}

// ── Bienvenue ───────────────────────────────────────────────────────────

export function getWelcomeEmailTemplate(name: string, role: "customer" | "vendor") {
  const isVendor = role === "vendor"

  const body = `
    <h2>Bienvenue sur East Market, ${name} !</h2>
    <p>Votre compte ${isVendor ? "vendeur" : "client"} vient d'être créé. Nous sommes ravis de vous compter parmi nous.</p>

    ${isVendor ? `
      <div class="card">
        <h3 style="margin-top:0;">Pour bien démarrer</h3>
        <p class="muted" style="margin-bottom:8px;">📦 Ajoutez vos premiers produits depuis votre portail vendeur</p>
        <p class="muted" style="margin-bottom:8px;">💬 Répondez rapidement aux clients pour améliorer votre taux de réponse</p>
        <p class="muted" style="margin-bottom:0;">💳 Configurez vos coordonnées de paiement pour recevoir vos ventes</p>
      </div>
    ` : `
      <div class="card">
        <h3 style="margin-top:0;">Ce que vous pouvez faire dès maintenant</h3>
        <p class="muted" style="margin-bottom:8px;">🛍️ Parcourir des milliers de produits chez nos vendeurs vérifiés</p>
        <p class="muted" style="margin-bottom:8px;">💬 Discuter directement avec un vendeur avant d'acheter</p>
        <p class="muted" style="margin-bottom:0;">🔒 Payer en toute sécurité, uniquement via la plateforme</p>
      </div>
    `}

    <p style="margin-top: 24px;">Une question ? Notre équipe support est à votre disposition à tout moment.</p>
    <div style="text-align: center; margin-top: 28px;">
      <a href="${SITE_URL}" class="button">Accéder à la plateforme</a>
    </div>
  `

  return emailShell({
    title: "Bienvenue sur East Market",
    preheader: `Bienvenue ${name}, votre compte East Market est prêt.`,
    headerTag: "Bienvenue",
    bodyHtml: body,
  })
}

// ── Vérification d'email ───────────────────────────────────────────────

export function getVerifyEmailTemplate(name: string, code: string) {
  const body = `
    <h2>Confirmez votre adresse email</h2>
    <p>Bonjour ${name},</p>
    <p>Voici votre code de vérification pour confirmer votre adresse email sur East Market :</p>
    <div style="margin: 24px 0; padding: 24px; background-color: ${CANVAS}; border: 2px dashed ${BRAND}; border-radius: 12px; text-align: center;">
      <p style="margin: 0 0 8px; font-size: 12px; color: ${INK_SOFT}; text-transform: uppercase; letter-spacing: 2px;">Votre code de vérification</p>
      <p style="margin: 0; font-size: 36px; font-weight: bold; color: ${BRAND}; letter-spacing: 10px;">${code}</p>
    </div>
    <p class="muted">Ce code expire dans 15 minutes. Saisissez-le dans l'application pour activer votre compte.</p>
    <p class="muted">Si vous n'êtes pas à l'origine de cette demande, vous pouvez ignorer cet email en toute sécurité.</p>
  `

  return emailShell({
    title: "Vérifiez votre email - East Market",
    preheader: `Votre code de vérification East Market : ${code}`,
    headerTag: "Vérification d'email",
    bodyHtml: body,
  })
}

// ── Commande passée (client) ─────────────────────────────────────────────

export function getOrderPlacedEmailTemplate(order: any) {
  const currency = order.currency_code
  const orderDate = order.created_at
    ? new Date(order.created_at).toLocaleDateString("fr-FR", { day: "numeric", month: "long", year: "numeric" })
    : new Date().toLocaleDateString("fr-FR", { day: "numeric", month: "long", year: "numeric" })

  const address = order.shipping_address ? `
    <strong>${order.shipping_address.first_name} ${order.shipping_address.last_name}</strong><br>
    ${order.shipping_address.address_1}<br>
    ${order.shipping_address.postal_code || ""} ${order.shipping_address.city}<br>
    ${order.shipping_address.country_code?.toUpperCase() || ""}<br>
    ${order.shipping_address.phone ? `Tél : ${order.shipping_address.phone}` : ""}
  ` : `Aucune adresse de livraison spécifiée.`

  const body = `
    <h2>Merci pour votre commande !</h2>
    <p>Bonjour,</p>
    <p>Nous avons bien reçu votre commande <strong>#${order.display_id}</strong> du ${orderDate} et elle est en cours de traitement.</p>

    <h3>Détail de la commande</h3>
    ${itemsTable(order.items || [], currency)}
    <table class="table" style="margin-top: 4px;">
      <tbody>
        <tr>
          <td style="padding: 8px 0;">Sous-total</td>
          <td style="padding: 8px 0; text-align: right;">${formatMoney(order.subtotal, currency)}</td>
        </tr>
        <tr>
          <td style="padding: 8px 0;">Livraison</td>
          <td style="padding: 8px 0; text-align: right;">${formatMoney(order.shipping_total, currency)}</td>
        </tr>
        <tr>
          <td style="padding: 8px 0;">Taxes</td>
          <td style="padding: 8px 0; text-align: right;">${formatMoney(order.tax_total, currency)}</td>
        </tr>
        <tr style="border-top: 2px solid ${LINE};">
          <td style="padding: 12px 0 0; font-size: 17px; font-weight: bold;">Total</td>
          <td style="padding: 12px 0 0; text-align: right; font-size: 17px; font-weight: bold; color: ${BRAND};">${formatMoney(order.total, currency)}</td>
        </tr>
      </tbody>
    </table>

    <div class="card">
      <h3 style="margin-top:0;">Adresse de livraison</h3>
      <p style="margin:0;">${address}</p>
    </div>

    <h3>Et maintenant ?</h3>
    <p class="muted" style="margin-bottom:8px;">1. Le vendeur prépare votre commande</p>
    <p class="muted" style="margin-bottom:8px;">2. Vous recevrez un email dès l'expédition</p>
    <p class="muted" style="margin-bottom:0;">3. Suivez votre commande à tout moment depuis l'application</p>

    <div style="text-align: center; margin-top: 28px;">
      <a href="${SITE_URL}" class="button">Suivre ma commande</a>
    </div>
  `

  return emailShell({
    title: `Confirmation de commande #${order.display_id}`,
    preheader: `Votre commande #${order.display_id} est confirmée — total ${formatMoney(order.total, currency)}.`,
    headerTag: "Commande confirmée",
    bodyHtml: body,
  })
}

// ── Nouvelle commande (vendeur) ──────────────────────────────────────────

export function getVendorOrderEmailTemplate(order: any, vendorItems: any[]) {
  const currency = order.currency_code
  const totalVendorEarnings = vendorItems.reduce((acc, curr) => acc + (curr.unit_price * curr.quantity), 0)

  const body = `
    <h2>Félicitations, vous avez reçu une nouvelle commande !</h2>
    <p>Bonjour,</p>
    <p>Un client vient de commander vos produits sur East Market — commande <strong>#${order.display_id}</strong>.</p>

    <h3>Produits à préparer</h3>
    ${itemsTable(vendorItems, currency)}
    <table class="table" style="margin-top: 4px;">
      <tbody>
        <tr style="border-top: 2px solid ${LINE};">
          <td style="padding: 12px 0 0; font-size: 16px; font-weight: bold;">Total de vos ventes</td>
          <td style="padding: 12px 0 0; text-align: right; font-size: 16px; font-weight: bold; color: ${BRAND};">${formatMoney(totalVendorEarnings, currency)}</td>
        </tr>
      </tbody>
    </table>

    <div class="card">
      <h3 style="margin-top:0;">Prochaine étape</h3>
      <p style="margin:0;">Connectez-vous à votre portail vendeur pour valider cette commande et préparer l'expédition. Un traitement rapide améliore votre taux de réponse et votre visibilité auprès des clients.</p>
    </div>

    <div style="text-align: center; margin-top: 28px;">
      <a href="${SITE_URL}" class="button">Traiter la commande</a>
    </div>
  `

  return emailShell({
    title: `Nouvelle commande #${order.display_id}`,
    preheader: `Nouvelle commande #${order.display_id} — ${formatMoney(totalVendorEarnings, currency)} de ventes.`,
    headerTag: "Nouvelle commande",
    bodyHtml: body,
  })
}

// ── Commande expédiée ─────────────────────────────────────────────────────

export function getOrderShippedEmailTemplate(order: any) {
  const address = order.shipping_address ? `
    <strong>${order.shipping_address.first_name} ${order.shipping_address.last_name}</strong><br>
    ${order.shipping_address.address_1}<br>
    ${order.shipping_address.postal_code || ""} ${order.shipping_address.city}<br>
    ${order.shipping_address.country_code?.toUpperCase() || ""}
  ` : ""

  const body = `
    <h2>Bonne nouvelle ! Votre commande est en route</h2>
    <p>Bonjour,</p>
    <p>Votre commande <strong>#${order.display_id}</strong> a été expédiée et est maintenant en cours de livraison.</p>
    <p>Notre transporteur vous contactera très prochainement pour convenir d'un moment de livraison précis.</p>

    ${address ? `
      <div class="card">
        <h3 style="margin-top:0;">Livraison à</h3>
        <p style="margin:0;">${address}</p>
      </div>
    ` : ""}

    <p style="margin-top: 24px;">Merci pour votre confiance !</p>
    <div style="text-align: center; margin-top: 28px;">
      <a href="${SITE_URL}" class="button">Suivre ma commande</a>
    </div>
  `

  return emailShell({
    title: `Commande expédiée #${order.display_id}`,
    preheader: `Votre commande #${order.display_id} a été expédiée et arrive bientôt.`,
    headerTag: "Commande expédiée",
    bodyHtml: body,
  })
}

// ── Récompense (fidélité / parrainage) ────────────────────────────────────

export function getRewardEmailTemplate(input: {
  name: string
  heading: string
  message: string
  couponCode?: string | null
}) {
  const { name, heading, message, couponCode } = input
  const couponBlock = couponCode ? `
    <div style="margin: 24px 0; padding: 20px; background-color: ${CANVAS}; border: 2px dashed ${BRAND}; border-radius: 12px; text-align: center;">
      <p style="margin: 0 0 6px; font-size: 12px; color: ${INK_SOFT}; text-transform: uppercase; letter-spacing: 1px;">Votre code</p>
      <p style="margin: 0; font-size: 24px; font-weight: bold; color: ${BRAND}; letter-spacing: 3px;">${couponCode}</p>
    </div>
  ` : ""

  const body = `
    <h2>${heading}</h2>
    <p>Bonjour ${name},</p>
    <p>${message}</p>
    ${couponBlock}
    <div style="text-align: center; margin-top: 8px;">
      <a href="${SITE_URL}" class="button">Utiliser maintenant</a>
    </div>
  `

  return emailShell({
    title: `${heading} - East Market`,
    preheader: message,
    headerTag: "Récompense",
    bodyHtml: body,
  })
}
