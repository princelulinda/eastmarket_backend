import { MedusaContainer } from "@medusajs/framework/types";

export default async function ({ container }: { container: MedusaContainer }) {
  const db = container.resolve("db");
  console.log("Checking video_comment table for missing vendor_id column...");
  
  try {
    await db.execute(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 
          FROM information_schema.columns 
          WHERE table_name='video_comment' AND column_name='vendor_id'
        ) THEN
          ALTER TABLE "video_comment" ADD COLUMN "vendor_id" TEXT;
          RAISE NOTICE 'Added vendor_id column to video_comment';
        ELSE
          RAISE NOTICE 'vendor_id column already exists in video_comment';
        END IF;
      END $$;
    `);
    console.log("Database schema check/fix completed.");
  } catch (error) {
    console.error("Error fixing database schema:", error);
  }
}
