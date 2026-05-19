import { Migration } from "@medusajs/framework/mikro-orm/migrations"

export class Migration20260419000000 extends Migration {
  override async up(): Promise<void> {
    this.addSql(`
      alter table if exists "vendor_admin"
        drop column if exists "password";
    `)
  }

  override async down(): Promise<void> {
    this.addSql(`
      alter table if exists "vendor_admin"
        add column if not exists "password" text null;
    `)
  }
}
