import { Migration } from "@medusajs/framework/mikro-orm/migrations"

export class Migration20260813030000 extends Migration {
  override async up(): Promise<void> {
    this.addSql(`
      alter table if exists "message" add column if not exists "metadata" jsonb null;
    `)
    this.addSql(`
      alter table if exists "message" drop constraint if exists "message_type_check";
      alter table if exists "message"
        add constraint "message_type_check"
        check ("type" in ('text', 'image', 'file', 'audio', 'product', 'offer', 'coupon', 'order_update', 'flash_sale', 'video', 'system'));
    `)
  }

  override async down(): Promise<void> {
    this.addSql(`
      alter table if exists "message" drop constraint if exists "message_type_check";
      alter table if exists "message"
        add constraint "message_type_check"
        check ("type" in ('text', 'image', 'file', 'audio'));
    `)
    this.addSql(`
      alter table if exists "message" drop column if exists "metadata";
    `)
  }
}
