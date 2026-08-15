import { Migration } from "@medusajs/framework/mikro-orm/migrations";

export class Migration20260812153041 extends Migration {

  override async up(): Promise<void> {
    this.addSql(`create table if not exists "user_activity" ("id" text not null, "customer_id" text not null, "action_type" text check ("action_type" in ('product_view', 'add_to_cart', 'remove_from_cart', 'wishlist_add', 'wishlist_remove', 'search', 'checkout_step', 'purchase')) not null, "entity_type" text null, "entity_id" text null, "metadata" jsonb null, "created_at" timestamptz not null default now(), "updated_at" timestamptz not null default now(), "deleted_at" timestamptz null, constraint "user_activity_pkey" primary key ("id"));`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_user_activity_customer_id" ON "user_activity" ("customer_id") WHERE deleted_at IS NULL;`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_user_activity_deleted_at" ON "user_activity" ("deleted_at") WHERE deleted_at IS NULL;`);
  }

  override async down(): Promise<void> {
    this.addSql(`drop table if exists "user_activity" cascade;`);
  }

}
