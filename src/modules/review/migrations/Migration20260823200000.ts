import { Migration } from "@medusajs/framework/mikro-orm/migrations";

/** Réponse publique du vendeur à un avis client. */
export class Migration20260823200000 extends Migration {

  override async up(): Promise<void> {
    this.addSql(`alter table if exists "review" add column if not exists "vendor_reply" text null, add column if not exists "vendor_replied_at" timestamptz null;`);
  }

  override async down(): Promise<void> {
    this.addSql(`alter table if exists "review" drop column if exists "vendor_reply", drop column if exists "vendor_replied_at";`);
  }

}
