import { Migration } from "@medusajs/framework/mikro-orm/migrations";

export class Migration20260812013631 extends Migration {

  override async up(): Promise<void> {
    this.addSql(`create table if not exists "vendor_follow" ("id" text not null, "customer_id" text not null, "vendor_id" text not null, "created_at" timestamptz not null default now(), "updated_at" timestamptz not null default now(), "deleted_at" timestamptz null, constraint "vendor_follow_pkey" primary key ("id"));`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_vendor_follow_customer_id" ON "vendor_follow" ("customer_id") WHERE deleted_at IS NULL;`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_vendor_follow_vendor_id" ON "vendor_follow" ("vendor_id") WHERE deleted_at IS NULL;`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_vendor_follow_deleted_at" ON "vendor_follow" ("deleted_at") WHERE deleted_at IS NULL;`);
  }

  override async down(): Promise<void> {
    this.addSql(`drop table if exists "vendor_follow" cascade;`);
  }

}
