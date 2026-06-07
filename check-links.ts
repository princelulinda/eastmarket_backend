import { MedusaApp } from "@medusajs/modules-sdk";
import * as medusaConfig from "./medusa-config";
import { ContainerRegistrationKeys } from "@medusajs/framework/utils";

async function run() {
  const { query, link } = await MedusaApp({
    modulesConfig: (medusaConfig as any).modules,
    sharedResourcesConfig: {
      database: { clientUrl: (medusaConfig as any).projectConfig.databaseUrl },
    },
  });

  try {
    const { data } = await query.graph({
      entity: "shipping_option",
      fields: ["id", "delivery_company.*"],
    });
    console.log("All Shipping Options and Links:", JSON.stringify(data, null, 2));
  } catch(e) {
    console.error("Query Error:", e);
  }

  process.exit(0);
}

run().catch(console.error);
