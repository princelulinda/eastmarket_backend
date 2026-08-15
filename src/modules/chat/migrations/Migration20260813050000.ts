import { Migration } from "@medusajs/framework/mikro-orm/migrations"

export class Migration20260813050000 extends Migration {
  override async up(): Promise<void> {
    this.addSql(`
      alter table if exists "conversation" add column if not exists "type" text not null default 'direct';
      alter table if exists "conversation" drop constraint if exists "conversation_type_check";
      alter table if exists "conversation"
        add constraint "conversation_type_check"
        check ("type" in ('direct', 'broadcast'));
    `)
    this.addSql(`
      CREATE UNIQUE INDEX IF NOT EXISTS "IDX_conversation_broadcast_unique"
      ON "conversation" (vendor_id) WHERE type = 'broadcast' AND deleted_at IS NULL;
    `)
  }

  override async down(): Promise<void> {
    this.addSql(`drop index if exists "IDX_conversation_broadcast_unique";`)
    this.addSql(`
      alter table if exists "conversation" drop constraint if exists "conversation_type_check";
      alter table if exists "conversation" drop column if exists "type";
    `)
  }
}
