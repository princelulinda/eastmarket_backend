import { Migration } from "@medusajs/framework/mikro-orm/migrations"

export class Migration20260813010000 extends Migration {
  override async up(): Promise<void> {
    this.addSql(`
      alter table if exists "message" add column if not exists "delivered_at" timestamptz null;
    `)
  }

  override async down(): Promise<void> {
    this.addSql(`
      alter table if exists "message" drop column if exists "delivered_at";
    `)
  }
}
