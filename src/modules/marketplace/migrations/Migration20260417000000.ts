import { Migration } from "@medusajs/framework/mikro-orm/migrations";

export class Migration20260417000000 extends Migration {

  override async up(): Promise<void> {
    this.addSql(`
      alter table if exists "vendor"
        add column if not exists "cover_image" text null,
        add column if not exists "description" text null,
        add column if not exists "phone" text null,
        add column if not exists "email" text null,
        add column if not exists "website" text null,
        add column if not exists "country" text null,
        add column if not exists "city" text null,
        add column if not exists "address" text null,
        add column if not exists "founded_year" integer null,
        add column if not exists "business_type" text null,
        add column if not exists "main_products" text null,
        add column if not exists "employee_count" text null,
        add column if not exists "social_links" jsonb null,
        add column if not exists "is_verified" boolean not null default false,
        add column if not exists "response_rate" numeric null,
        add column if not exists "response_time" text null;
    `)
  }

  override async down(): Promise<void> {
    this.addSql(`
      alter table if exists "vendor"
        drop column if exists "cover_image",
        drop column if exists "description",
        drop column if exists "phone",
        drop column if exists "email",
        drop column if exists "website",
        drop column if exists "country",
        drop column if exists "city",
        drop column if exists "address",
        drop column if exists "founded_year",
        drop column if exists "business_type",
        drop column if exists "main_products",
        drop column if exists "employee_count",
        drop column if exists "social_links",
        drop column if exists "is_verified",
        drop column if exists "response_rate",
        drop column if exists "response_time";
    `)
  }

}
