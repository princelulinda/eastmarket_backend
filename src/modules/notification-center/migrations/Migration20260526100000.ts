import { Migration } from "@medusajs/framework/mikro-orm/migrations"

export class Migration20260526100000 extends Migration {
  override async up(): Promise<void> {
    this.addSql(`
      create table if not exists "push_token" (
        "id" text not null,
        "recipient_id" text not null,
        "recipient_type" text check ("recipient_type" in ('customer', 'vendor')) not null,
        "token" text not null,
        "device_type" text null,
        "created_at" timestamptz not null default now(),
        "updated_at" timestamptz not null default now(),
        "deleted_at" timestamptz null,
        constraint "push_token_pkey" primary key ("id")
      );
    `)
    this.addSql(`
      CREATE INDEX IF NOT EXISTS "IDX_push_token_recipient_id"
      ON "push_token" (recipient_id) WHERE deleted_at IS NULL;
    `)
  }

  override async down(): Promise<void> {
    this.addSql(`drop table if exists "push_token" cascade;`)
  }
}
