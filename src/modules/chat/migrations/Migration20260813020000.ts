import { Migration } from "@medusajs/framework/mikro-orm/migrations"

export class Migration20260813020000 extends Migration {
  override async up(): Promise<void> {
    this.addSql(`
      alter table if exists "message" add column if not exists "reply_to_id" text null;
    `)
  }

  override async down(): Promise<void> {
    this.addSql(`
      alter table if exists "message" drop column if exists "reply_to_id";
    `)
  }
}
