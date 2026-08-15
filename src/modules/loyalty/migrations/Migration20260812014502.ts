import { Migration } from "@medusajs/framework/mikro-orm/migrations";

export class Migration20260812014502 extends Migration {

  override async up(): Promise<void> {
    this.addSql(`alter table if exists "customer_loyalty" drop constraint if exists "customer_loyalty_referral_code_unique";`);
    this.addSql(`alter table if exists "referral" drop constraint if exists "referral_referred_customer_id_unique";`);
    this.addSql(`create table if not exists "referral" ("id" text not null, "referrer_customer_id" text not null, "referred_customer_id" text not null, "code_used" text not null, "status" text check ("status" in ('pending', 'rewarded')) not null default 'pending', "rewarded_at" timestamptz null, "referrer_coupon_id" text null, "referred_coupon_id" text null, "created_at" timestamptz not null default now(), "updated_at" timestamptz not null default now(), "deleted_at" timestamptz null, constraint "referral_pkey" primary key ("id"));`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_referral_referrer_customer_id" ON "referral" ("referrer_customer_id") WHERE deleted_at IS NULL;`);
    this.addSql(`CREATE UNIQUE INDEX IF NOT EXISTS "IDX_referral_referred_customer_id_unique" ON "referral" ("referred_customer_id") WHERE deleted_at IS NULL;`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_referral_deleted_at" ON "referral" ("deleted_at") WHERE deleted_at IS NULL;`);

    this.addSql(`alter table if exists "customer_loyalty" add column if not exists "referral_code" text null;`);
    this.addSql(`CREATE UNIQUE INDEX IF NOT EXISTS "IDX_customer_loyalty_referral_code_unique" ON "customer_loyalty" ("referral_code") WHERE deleted_at IS NULL;`);
  }

  override async down(): Promise<void> {
    this.addSql(`drop table if exists "referral" cascade;`);

    this.addSql(`drop index if exists "IDX_customer_loyalty_referral_code_unique";`);
    this.addSql(`alter table if exists "customer_loyalty" drop column if exists "referral_code";`);
  }

}
