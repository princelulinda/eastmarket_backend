import { Migration } from "@medusajs/framework/mikro-orm/migrations";

export class Migration20260530095813 extends Migration {

  override async up(): Promise<void> {
    this.addSql(`alter table if exists "delivery_company" drop constraint if exists "delivery_company_email_unique";`);
    this.addSql(`create table if not exists "delivery_company" ("id" text not null, "name" text not null, "logo" text null, "phone" text null, "email" text not null, "website" text null, "is_active" boolean not null default true, "metadata" jsonb null, "created_at" timestamptz not null default now(), "updated_at" timestamptz not null default now(), "deleted_at" timestamptz null, constraint "delivery_company_pkey" primary key ("id"));`);
    this.addSql(`CREATE UNIQUE INDEX IF NOT EXISTS "IDX_delivery_company_email_unique" ON "delivery_company" ("email") WHERE deleted_at IS NULL;`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_delivery_company_deleted_at" ON "delivery_company" ("deleted_at") WHERE deleted_at IS NULL;`);

    this.addSql(`create table if not exists "delivery_driver" ("id" text not null, "name" text not null, "phone" text not null, "vehicle_details" text null, "is_active" boolean not null default true, "metadata" jsonb null, "delivery_company_id" text not null, "created_at" timestamptz not null default now(), "updated_at" timestamptz not null default now(), "deleted_at" timestamptz null, constraint "delivery_driver_pkey" primary key ("id"));`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_delivery_driver_delivery_company_id" ON "delivery_driver" ("delivery_company_id") WHERE deleted_at IS NULL;`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_delivery_driver_deleted_at" ON "delivery_driver" ("deleted_at") WHERE deleted_at IS NULL;`);

    this.addSql(`alter table if exists "delivery_driver" add constraint "delivery_driver_delivery_company_id_foreign" foreign key ("delivery_company_id") references "delivery_company" ("id") on update cascade;`);
  }

  override async down(): Promise<void> {
    this.addSql(`alter table if exists "delivery_driver" drop constraint if exists "delivery_driver_delivery_company_id_foreign";`);

    this.addSql(`drop table if exists "delivery_company" cascade;`);

    this.addSql(`drop table if exists "delivery_driver" cascade;`);
  }

}
