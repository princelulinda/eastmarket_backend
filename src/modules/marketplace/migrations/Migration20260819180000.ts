import { Migration } from "@medusajs/framework/mikro-orm/migrations";

/** Horaires d'ouverture de la boutique, saisis par le vendeur. */
export class Migration20260819180000 extends Migration {
  override async up(): Promise<void> {
    this.addSql(`alter table if exists "vendor" add column if not exists "opening_hours" jsonb null;`);
  }

  override async down(): Promise<void> {
    this.addSql(`alter table if exists "vendor" drop column if exists "opening_hours";`);
  }
}
