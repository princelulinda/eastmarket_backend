import { Migration } from "@medusajs/framework/mikro-orm/migrations"

export class Migration20260813000000 extends Migration {
  override async up(): Promise<void> {
    this.addSql(`
      alter table if exists "message" add column if not exists "reactions" jsonb null;
    `)
    this.addSql(`
      alter table if exists "message" drop constraint if exists "message_type_check";
      alter table if exists "message"
        add constraint "message_type_check"
        check ("type" in ('text', 'image', 'file', 'audio'));
    `)
  }

  override async down(): Promise<void> {
    this.addSql(`
      alter table if exists "message" drop constraint if exists "message_type_check";
      alter table if exists "message"
        add constraint "message_type_check"
        check ("type" in ('text', 'image', 'file'));
    `)
    this.addSql(`
      alter table if exists "message" drop column if exists "reactions";
    `)
  }
}
