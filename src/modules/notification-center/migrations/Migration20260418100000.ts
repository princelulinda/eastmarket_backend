import { Migration } from "@medusajs/framework/mikro-orm/migrations"

export class Migration20260418100000 extends Migration {
  override async up(): Promise<void> {
    this.addSql(`
      create table if not exists "app_notification" (
        "id" text not null,
        "recipient_id" text not null,
        "recipient_type" text check ("recipient_type" in ('customer', 'vendor')) not null,
        "type" text check ("type" in (
          'new_message','new_order','order_status','order_shipped',
          'order_delivered','order_cancelled','new_review','system'
        )) not null,
        "title" text not null,
        "body" text not null,
        "data" jsonb null,
        "is_read" boolean not null default false,
        "created_at" timestamptz not null default now(),
        "updated_at" timestamptz not null default now(),
        "deleted_at" timestamptz null,
        constraint "app_notification_pkey" primary key ("id")
      );
    `)
    this.addSql(`
      CREATE INDEX IF NOT EXISTS "IDX_app_notification_recipient"
      ON "app_notification" (recipient_id, is_read, created_at) WHERE deleted_at IS NULL;
    `)
  }

  override async down(): Promise<void> {
    this.addSql(`drop table if exists "app_notification" cascade;`)
  }
}
