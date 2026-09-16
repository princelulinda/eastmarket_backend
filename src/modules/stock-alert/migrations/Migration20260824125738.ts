import { Migration } from "@medusajs/framework/mikro-orm/migrations";

export class Migration20260824125738 extends Migration {

  override async up(): Promise<void> {
    this.addSql(`alter table if exists "stock_alert_setting" drop constraint if exists "stock_alert_setting_vendor_id_unique";`);
    this.addSql(`create table if not exists "stock_alert_rule" ("id" text not null, "vendor_id" text not null, "variant_id" text not null, "threshold" integer null, "last_level" text null, "last_notified_at" timestamptz null, "created_at" timestamptz not null default now(), "updated_at" timestamptz not null default now(), "deleted_at" timestamptz null, constraint "stock_alert_rule_pkey" primary key ("id"));`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_stock_alert_rule_vendor_id" ON "stock_alert_rule" ("vendor_id") WHERE deleted_at IS NULL;`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_stock_alert_rule_variant_id" ON "stock_alert_rule" ("variant_id") WHERE deleted_at IS NULL;`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_stock_alert_rule_deleted_at" ON "stock_alert_rule" ("deleted_at") WHERE deleted_at IS NULL;`);

    this.addSql(`create table if not exists "stock_alert_setting" ("id" text not null, "vendor_id" text not null, "enabled" boolean not null default true, "default_threshold" integer not null default 5, "created_at" timestamptz not null default now(), "updated_at" timestamptz not null default now(), "deleted_at" timestamptz null, constraint "stock_alert_setting_pkey" primary key ("id"));`);
    this.addSql(`CREATE UNIQUE INDEX IF NOT EXISTS "IDX_stock_alert_setting_vendor_id_unique" ON "stock_alert_setting" ("vendor_id") WHERE deleted_at IS NULL;`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_stock_alert_setting_deleted_at" ON "stock_alert_setting" ("deleted_at") WHERE deleted_at IS NULL;`);
  }

  override async down(): Promise<void> {
    this.addSql(`drop table if exists "stock_alert_rule" cascade;`);

    this.addSql(`drop table if exists "stock_alert_setting" cascade;`);
  }

}
