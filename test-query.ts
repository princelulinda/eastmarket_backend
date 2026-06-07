import { MedusaApp } from "@medusajs/modules-sdk";
import * as medusaConfig from "./medusa-config";

async function run() {
  const { query } = await MedusaApp({
    modulesConfig: (medusaConfig as any).modules,
    sharedResourcesConfig: {
      database: { clientUrl: (medusaConfig as any).projectConfig.databaseUrl },
    },
  });

  const { data } = await query.graph({
    entity: "shipping_option",
    fields: ["id", "delivery_company.*"],
    filters: {
      id: "so_01KSWK0MGHVTE3D3GG9BEB4SYS"
    }
  });

  console.log("Result:", JSON.stringify(data, null, 2));
  process.exit(0);
}

run().catch(console.error);
