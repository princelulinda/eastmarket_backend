import { Migration } from "@medusajs/framework/mikro-orm/migrations"

export class Migration20260418000000 extends Migration {
  override async up(): Promise<void> {
    this.addSql(`
      create table if not exists "conversation" (
        "id" text not null,
        "customer_id" text not null,
        "vendor_id" text not null,
        "last_message_at" timestamptz null,
        "created_at" timestamptz not null default now(),
        "updated_at" timestamptz not null default now(),
        "deleted_at" timestamptz null,
        constraint "conversation_pkey" primary key ("id")
      );
    `)
    this.addSql(`
      alter table if exists "conversation" alter column "customer_id" drop not null;
      alter table if exists "conversation" alter column "vendor_id" drop not null;
    `)
    this.addSql(`
      CREATE UNIQUE INDEX IF NOT EXISTS "IDX_conversation_customer_vendor_unique"
      ON "conversation" (customer_id, vendor_id) WHERE deleted_at IS NULL;
    `)
    this.addSql(`
      CREATE INDEX IF NOT EXISTS "IDX_conversation_customer_vendor"
      ON "conversation" (customer_id, vendor_id) WHERE deleted_at IS NULL;
    `)

    this.addSql(`
      create table if not exists "message" (
        "id" text not null,
        "conversation_id" text not null,
        "sender_type" text check ("sender_type" in ('customer', 'vendor')) not null,
        "sender_id" text not null,
        "content" text not null,
        "type" text check ("type" in ('text', 'image', 'file')) not null default 'text',
        "file_url" text null,
        "is_read" boolean not null default false,
        "created_at" timestamptz not null default now(),
        "updated_at" timestamptz not null default now(),
        "deleted_at" timestamptz null,
        constraint "message_pkey" primary key ("id")
      );
    `)
    this.addSql(`
      CREATE INDEX IF NOT EXISTS "IDX_message_conversation_created"
      ON "message" (conversation_id, created_at) WHERE deleted_at IS NULL;
    `)
    this.addSql(`
      CREATE INDEX IF NOT EXISTS "IDX_message_conversation_is_read"
      ON "message" (conversation_id, is_read) WHERE deleted_at IS NULL;
    `)
    this.addSql(`
      alter table if exists "message"
        add constraint "message_conversation_id_foreign"
        foreign key ("conversation_id") references "conversation" ("id") on update cascade;
    `)
  }

  override async down(): Promise<void> {
    this.addSql(`alter table if exists "message" drop constraint if exists "message_conversation_id_foreign";`)
    this.addSql(`drop table if exists "message" cascade;`)
    this.addSql(`drop table if exists "conversation" cascade;`)
  }
}
