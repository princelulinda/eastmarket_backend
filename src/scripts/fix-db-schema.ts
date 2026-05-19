import { Modules } from "@medusajs/framework/utils";
import { MedusaContainer } from "@medusajs/framework/types";

export default async function (container: MedusaContainer) {
  // Accéder directement au driver Knex/MikroORM pour exécuter le SQL
  const db = container.resolve("db");
  console.log("Fixing DB schema: altering customer_id and vendor_id to be nullable...");
  
  await db.execute(`
    ALTER TABLE "conversation" ALTER COLUMN "customer_id" DROP NOT NULL;
    ALTER TABLE "conversation" ALTER COLUMN "vendor_id" DROP NOT NULL;
  `);
  
  console.log("Schema fix completed.");
}
