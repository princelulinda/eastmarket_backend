import { Migration } from "@medusajs/framework/mikro-orm/migrations"

export class Migration20260813070000 extends Migration {
  override async up(): Promise<void> {
    this.addSql(`
      create table if not exists "notification_preference" (
        "id" text not null,
        "recipient_id" text not null,
        "recipient_type" text check ("recipient_type" in ('customer', 'vendor')) not null,
        "prefs" jsonb not null,
        "created_at" timestamptz not null default now(),
        "updated_at" timestamptz not null default now(),
        "deleted_at" timestamptz null,
        constraint "notification_preference_pkey" primary key ("id")
      );
    `)
    this.addSql(`
      CREATE INDEX IF NOT EXISTS "IDX_notification_preference_recipient"
      ON "notification_preference" (recipient_id) WHERE deleted_at IS NULL;
    `)
  }

  override async down(): Promise<void> {
    this.addSql(`drop table if exists "notification_preference" cascade;`)
  }
}
