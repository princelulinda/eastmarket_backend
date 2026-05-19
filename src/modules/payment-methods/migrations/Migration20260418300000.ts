import { Migration } from "@medusajs/framework/mikro-orm/migrations";

export class Migration20260418300000 extends Migration {

  override async up(): Promise<void> {
    this.addSql(`
      create table if not exists "customer_payment_method" (
        "id" text not null,
        "customer_id" text not null,
        "provider_id" text not null,
        "data" jsonb null,
        "is_default" boolean not null default false,
        "label" text null,
        "created_at" timestamptz not null default now(),
        "updated_at" timestamptz not null default now(),
        "deleted_at" timestamptz null,
        constraint "customer_payment_method_pkey" primary key ("id")
      );

      create index if not exists "IDX_customer_payment_method_customer_id" 
      on "customer_payment_method" ("customer_id") where "deleted_at" is null;
    `)
  }

  override async down(): Promise<void> {
    this.addSql(`drop table if exists "customer_payment_method" cascade;`)
  }

}
