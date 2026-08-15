import { Migration } from "@medusajs/framework/mikro-orm/migrations";

export class Migration20260812001532 extends Migration {

  override async up(): Promise<void> {
    this.addSql(`create table if not exists "flash_sale" ("id" text not null, "vendor_id" text null, "title" text not null, "banner_color" text null, "product_ids" jsonb not null, "promotion_id" text not null, "campaign_id" text not null, "discount_type" text check ("discount_type" in ('percentage', 'fixed')) not null, "discount_value" integer not null, "starts_at" timestamptz not null, "ends_at" timestamptz not null, "is_active" boolean not null default true, "created_at" timestamptz not null default now(), "updated_at" timestamptz not null default now(), "deleted_at" timestamptz null, constraint "flash_sale_pkey" primary key ("id"));`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_flash_sale_deleted_at" ON "flash_sale" ("deleted_at") WHERE deleted_at IS NULL;`);
  }

  override async down(): Promise<void> {
    this.addSql(`drop table if exists "flash_sale" cascade;`);
  }

}
