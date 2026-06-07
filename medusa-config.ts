import { loadEnv, defineConfig } from '@medusajs/framework/utils'

loadEnv(process.env.NODE_ENV || "development", process.cwd())

module.exports = defineConfig({
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
      resolve: "@medusajs/medusa/auth",
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
        ],
      },
    },
    {
      resolve: "@medusajs/medusa/event-bus-local",
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
      resolve: "./src/modules/notification-center",
    },
    {
      resolve: "./src/modules/payment-methods",
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
