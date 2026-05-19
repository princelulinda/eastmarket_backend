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
        ],
      },
    },
    {
      resolve: "./src/modules/marketplace",
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
    }
  ]
})
