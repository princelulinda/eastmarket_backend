import { loadEnv, defineConfig, Modules, ContainerRegistrationKeys } from '@medusajs/framework/utils'

loadEnv(process.env.NODE_ENV || "development", process.cwd())
console.log("NODE_ENV =", process.env.NODE_ENV)
console.log("STORE_CORS =", process.env.STORE_CORS) // restart nudge: pick up follow + referral routes
module.exports = defineConfig({
  admin: {
    disable: false,
    // A defaut, defineConfig met MEDUSA_BACKEND_URL ici — et comme cette variable porte l'URL
    // publique (elle sert au callback_url de MBIYOPAY), l'admin servi en local appelle la
    // production. MEDUSA_ADMIN_BACKEND_URL permet de le pointer sur le serveur local sans
    // toucher au reste ; absente, le comportement est exactement celui d'avant.
    backendUrl: process.env.MEDUSA_ADMIN_BACKEND_URL || process.env.MEDUSA_BACKEND_URL,
  },
  projectConfig: {
    databaseUrl: process.env.DATABASE_URL,
    http: {
      storeCors: process.env.STORE_CORS!,
      adminCors: process.env.ADMIN_CORS!,
      authCors: process.env.AUTH_CORS!,
      jwtSecret: process.env.JWT_SECRET || "supersecret",
      cookieSecret: process.env.COOKIE_SECRET || "supersecret",
    }
  },
  modules: [
    {
      resolve: "./src/modules/stock-alert",
    },
    {
      resolve: "@medusajs/medusa/auth",
            dependencies: [Modules.CACHE, ContainerRegistrationKeys.LOGGER],
      options: {
        providers: [
          {
            resolve: "@medusajs/medusa/auth-emailpass",
            id: "emailpass",
          },
          {
            resolve: "@medusajs/medusa/auth-google",
            id: "google",
            options: {
              clientId: process.env.GOOGLE_CLIENT_ID,
              clientSecret: process.env.GOOGLE_CLIENT_SECRET,
              callbackUrl: process.env.GOOGLE_CALLBACK_URL,
            },
          },
          {
            resolve: "./src/modules/google-one-tap",
            id: "google-onetap",
            options: {
              clientId: process.env.GOOGLE_CLIENT_ID,
            },
          },
        ],
      },
    },
    {
      resolve: "@medusajs/medusa/event-bus-local",
    },
    {
      resolve: "@medusajs/medusa/file",
      options: {
        providers: [
          {
            resolve: "@medusajs/medusa/file-s3",
            id: "s3",
            options: {
              file_url: process.env.MINIO_FILE_URL,
              access_key_id: process.env.MINIO_ACCESS_KEY,
              secret_access_key: process.env.MINIO_SECRET_KEY,
              region: process.env.MINIO_REGION || "us-east-1",
              bucket: process.env.MINIO_BUCKET,
              endpoint: process.env.MINIO_ENDPOINT,
              additional_client_config: {
                forcePathStyle: true,
              },
            },
          },
        ],
      },
    },
    {
      resolve: "@medusajs/medusa/fulfillment",
      options: {
        providers: [
          {
            resolve: "./src/modules/delivery/providers/delivery-company-provider",
            id: "delivery-company-provider",
          }
        ],
      },
    },
    {
      resolve: "./src/modules/marketplace",
    },
    {
      resolve: "./src/modules/delivery",
      key: "delivery",
    },
    {
      resolve: "./src/modules/chat",
    },
    {
      resolve: "./src/modules/follow",
    },
    {
      resolve: "./src/modules/activity",
    },
    {
      resolve: "./src/modules/notification-center",
    },
    {
      resolve: "./src/modules/payment-methods",
    },
    {
      resolve: "./src/modules/loyalty",
    },
    {
      // flash sales (time-boxed vendor promotions)
      resolve: "./src/modules/flash-sale",
    },
    {
      resolve: "./src/modules/short-video",
    },
    {
      resolve: "./src/modules/socket",
    },
    // Module Openinary
    {
      resolve: "./src/modules/openinary-image",
    },
    {
      resolve: "./src/modules/review",
    },
    {
      resolve: "./src/modules/analytics",
    },
    {
      resolve: "@medusajs/medusa/payment",
      options: {
        providers: [
          {
            resolve: "./src/modules/kashflow",
            id: "kashflow",
            options: {
              apiUrl: process.env.KASHFLOW_API_URL || "https://api.kashflow-service.com",
              apiKey: process.env.KASHFLOW_APP_KEY,
              secretKey:""
            },
          },
          {
            resolve: "@medusajs/medusa/payment-stripe",
            id: "stripe",
            options: {
              apiKey: process.env.STRIPE_API_KEY,
            },
          },
          {
            resolve: "./src/modules/mbiyopay",
            id: "mbiyopay",
            options: {
              apiUrl: process.env.MBIYOPAY_API_URL || "https://dashboard.mbiyo.africa/api/v1/merchant",
              apiKey: process.env.MBIYOPAY_API_KEY,
            },
          },
          {
            // TrustSend mobile money — sandbox by default; point TRUSTSEND_API_URL at
            // https://api.trustsend.africa/api/v1 with a ts_live_ key to go to production.
            resolve: "./src/modules/trustsend",
            id: "trustsend",
            options: {
              apiUrl: process.env.TRUSTSEND_API_URL || "https://sandbox-api.trustsend.africa/api/v1",
              apiKey: process.env.TRUSTSEND_API_KEY,
              // East Market enregistre ses prix en centièmes (price.amount = 2020 pour 20,20 $,
              // et le storefront divise par 100 à l'affichage), alors que Medusa v2 considère
              // ce nombre comme l'unité principale. Les montants arrivent donc déjà dans
              // l'unité de TrustSend et ne doivent PAS être multipliés par 100.
              amountUnit: "minor",
            },
          },
        ],
      },
    },
    {
      resolve: "@medusajs/translation",
    },
  ],
  featureFlags: {
    translation: true,
  },
})
