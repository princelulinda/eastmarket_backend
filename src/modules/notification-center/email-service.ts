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

// ── Email HTML Templates ──────────────────────────────────────────────────

export function getWelcomeEmailTemplate(name: string, role: "customer" | "vendor") {
  const roleText = role === "vendor" ? "Vendeur" : "Client"
  return `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Bienvenue sur East Market</title>
      <style>
        body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; background-color: #f3f4f6; color: #1f2937; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 20px auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); }
        .header { background-color: #1e3a8a; padding: 30px; text-align: center; color: #ffffff; }
        .header h1 { margin: 0; font-size: 24px; font-weight: bold; }
        .content { padding: 30px; line-height: 1.6; }
        .button { display: inline-block; padding: 12px 24px; background-color: #10b981; color: #ffffff; text-decoration: none; border-radius: 6px; font-weight: bold; margin-top: 20px; }
        .footer { background-color: #f9fafb; padding: 20px; text-align: center; font-size: 12px; color: #6b7280; border-top: 1px solid #e5e7eb; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>East Market</h1>
        </div>
        <div class="content">
          <h2>Bienvenue sur East Market, ${name} !</h2>
          <p>Nous sommes ravis de vous compter parmi nous en tant que <strong>${roleText}</strong>.</p>
          <p>Notre plateforme vous permet de découvrir les meilleurs produits et de gérer vos transactions en toute sécurité.</p>
          <p>Si vous avez des questions, notre support est à votre entière disposition.</p>
          <div style="text-align: center;">
            <a href="https://eastmarket.africa" class="button">Accéder à la plateforme</a>
          </div>
        </div>
        <div class="footer">
          &copy; 2026 East Market. Tous droits réservés.<br>
          Cet email a été envoyé automatiquement, merci de ne pas y répondre directement.
        </div>
      </div>
    </body>
    </html>
  `
}

export function getOrderPlacedEmailTemplate(order: any) {
  const itemsHtml = (order.items || []).map((item: any) => `
    <tr>
      <td style="padding: 12px; border-bottom: 1px solid #e5e7eb;">
        <strong>${item.title}</strong><br>
        <span style="font-size: 12px; color: #6b7280;">Qté: ${item.quantity}</span>
      </td>
      <td style="padding: 12px; border-bottom: 1px solid #e5e7eb; text-align: right;">
        ${(item.unit_price * item.quantity / 100).toFixed(2)} ${order.currency_code?.toUpperCase() || 'EUR'}
      </td>
    </tr>
  `).join("")

  const formattedTotal = (order.total / 100).toFixed(2)
  const formattedSubtotal = (order.subtotal / 100).toFixed(2)
  const formattedShipping = (order.shipping_total / 100).toFixed(2)
  const formattedTax = (order.tax_total / 100).toFixed(2)
  const currency = order.currency_code?.toUpperCase() || 'EUR'

  const address = order.shipping_address ? `
    <p>
      <strong>${order.shipping_address.first_name} ${order.shipping_address.last_name}</strong><br>
      ${order.shipping_address.address_1}<br>
      ${order.shipping_address.postal_code || ''} ${order.shipping_address.city}<br>
      ${order.shipping_address.country_code?.toUpperCase() || ''}<br>
      Tél: ${order.shipping_address.phone || ''}
    </p>
  ` : `<p>Aucune adresse de livraison spécifiée.</p>`

  return `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Confirmation de votre commande - East Market</title>
      <style>
        body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; background-color: #f3f4f6; color: #1f2937; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 20px auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); }
        .header { background-color: #1e3a8a; padding: 30px; text-align: center; color: #ffffff; }
        .header h1 { margin: 0; font-size: 24px; font-weight: bold; }
        .content { padding: 30px; line-height: 1.6; }
        .table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .footer { background-color: #f9fafb; padding: 20px; text-align: center; font-size: 12px; color: #6b7280; border-top: 1px solid #e5e7eb; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>East Market</h1>
        </div>
        <div class="content">
          <h2>Merci pour votre commande !</h2>
          <p>Bonjour,</p>
          <p>Nous avons bien reçu votre commande <strong>#${order.display_id}</strong> et elle est en cours de traitement.</p>
          
          <h3>Détail de la commande</h3>
          <table class="table">
            <thead>
              <tr style="background-color: #f9fafb;">
                <th style="padding: 12px; text-align: left; border-bottom: 2px solid #e5e7eb;">Produit</th>
                <th style="padding: 12px; text-align: right; border-bottom: 2px solid #e5e7eb;">Total</th>
              </tr>
            </thead>
            <tbody>
              ${itemsHtml}
              <tr>
                <td style="padding: 12px; font-weight: bold;">Sous-total</td>
                <td style="padding: 12px; text-align: right; font-weight: bold;">${formattedSubtotal} ${currency}</td>
              </tr>
              <tr>
                <td style="padding: 12px;">Livraison</td>
                <td style="padding: 12px; text-align: right;">${formattedShipping} ${currency}</td>
              </tr>
              <tr>
                <td style="padding: 12px;">Taxes</td>
                <td style="padding: 12px; text-align: right;">${formattedTax} ${currency}</td>
              </tr>
              <tr style="border-top: 2px solid #e5e7eb; font-size: 18px; font-weight: bold;">
                <td style="padding: 12px;">Total Général</td>
                <td style="padding: 12px; text-align: right; color: #10b981;">${formattedTotal} ${currency}</td>
              </tr>
            </tbody>
          </table>

          <div style="margin-top: 30px; padding: 20px; background-color: #f9fafb; border-radius: 6px;">
            <h3>Adresse de livraison</h3>
            ${address}
          </div>
        </div>
        <div class="footer">
          &copy; 2026 East Market. Tous droits réservés.<br>
          Cet email a été envoyé automatiquement, merci de ne pas y répondre directement.
        </div>
      </div>
    </body>
    </html>
  `
}

export function getVendorOrderEmailTemplate(order: any, vendorItems: any[]) {
  const itemsHtml = vendorItems.map((item: any) => `
    <tr>
      <td style="padding: 12px; border-bottom: 1px solid #e5e7eb;">
        <strong>${item.title}</strong><br>
        <span style="font-size: 12px; color: #6b7280;">Qté: ${item.quantity}</span>
      </td>
      <td style="padding: 12px; border-bottom: 1px solid #e5e7eb; text-align: right;">
        ${(item.unit_price * item.quantity / 100).toFixed(2)} ${order.currency_code?.toUpperCase() || 'EUR'}
      </td>
    </tr>
  `).join("")

  const totalVendorEarnings = vendorItems.reduce((acc, curr) => acc + (curr.unit_price * curr.quantity), 0)
  const formattedTotal = (totalVendorEarnings / 100).toFixed(2)
  const currency = order.currency_code?.toUpperCase() || 'EUR'

  return `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Nouvelle commande reçue - East Market</title>
      <style>
        body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; background-color: #f3f4f6; color: #1f2937; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 20px auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); }
        .header { background-color: #1e3a8a; padding: 30px; text-align: center; color: #ffffff; }
        .header h1 { margin: 0; font-size: 24px; font-weight: bold; }
        .content { padding: 30px; line-height: 1.6; }
        .table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        .footer { background-color: #f9fafb; padding: 20px; text-align: center; font-size: 12px; color: #6b7280; border-top: 1px solid #e5e7eb; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>East Market</h1>
        </div>
        <div class="content">
          <h2>Félicitations, vous avez reçu une nouvelle commande !</h2>
          <p>Bonjour,</p>
          <p>Un client vient de commander vos produits sur East Market (Commande <strong>#${order.display_id}</strong>).</p>
          
          <h3>Produits à préparer</h3>
          <table class="table">
            <thead>
              <tr style="background-color: #f9fafb;">
                <th style="padding: 12px; text-align: left; border-bottom: 2px solid #e5e7eb;">Produit</th>
                <th style="padding: 12px; text-align: right; border-bottom: 2px solid #e5e7eb;">Total</th>
              </tr>
            </thead>
            <tbody>
              ${itemsHtml}
              <tr style="border-top: 2px solid #e5e7eb; font-size: 16px; font-weight: bold;">
                <td style="padding: 12px;">Total de vos ventes</td>
                <td style="padding: 12px; text-align: right; color: #10b981;">${formattedTotal} ${currency}</td>
              </tr>
            </tbody>
          </table>

          <p style="margin-top: 20px;">Veuillez vous connecter à votre portail vendeur pour valider et expédier cette commande.</p>
        </div>
        <div class="footer">
          &copy; 2026 East Market. Tous droits réservés.<br>
          Cet email a été envoyé automatiquement, merci de ne pas y répondre directement.
        </div>
      </div>
    </body>
    </html>
  `
}

export function getOrderShippedEmailTemplate(order: any) {
  return `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Votre commande a été expédiée - East Market</title>
      <style>
        body { font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; background-color: #f3f4f6; color: #1f2937; margin: 0; padding: 0; }
        .container { max-width: 600px; margin: 20px auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); }
        .header { background-color: #10b981; padding: 30px; text-align: center; color: #ffffff; }
        .header h1 { margin: 0; font-size: 24px; font-weight: bold; }
        .content { padding: 30px; line-height: 1.6; }
        .footer { background-color: #f9fafb; padding: 20px; text-align: center; font-size: 12px; color: #6b7280; border-top: 1px solid #e5e7eb; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>East Market</h1>
        </div>
        <div class="content">
          <h2>Bonne nouvelle ! Votre commande est en route !</h2>
          <p>Bonjour,</p>
          <p>Nous avons le plaisir de vous informer que votre commande <strong>#${order.display_id}</strong> a été expédiée et est en cours de livraison.</p>
          <p>Notre transporteur vous contactera très prochainement pour convenir d'un moment de livraison précis.</p>
          <p style="margin-top: 20px;">Merci pour votre confiance !</p>
        </div>
        <div class="footer">
          &copy; 2026 East Market. Tous droits réservés.<br>
          Cet email a été envoyé automatiquement, merci de ne pas y répondre directement.
        </div>
      </div>
    </body>
    </html>
  `
}
