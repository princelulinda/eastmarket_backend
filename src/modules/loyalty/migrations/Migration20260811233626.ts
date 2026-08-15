import { Migration } from "@medusajs/framework/mikro-orm/migrations";

export class Migration20260811233626 extends Migration {

  override async up(): Promise<void> {
    this.addSql(`alter table if exists "loyalty_coupon" drop constraint if exists "loyalty_coupon_code_unique";`);
    this.addSql(`alter table if exists "customer_loyalty" drop constraint if exists "customer_loyalty_customer_id_unique";`);
    this.addSql(`create table if not exists "customer_loyalty" ("id" text not null, "customer_id" text not null, "points_balance" integer not null default 0, "lifetime_points" integer not null default 0, "tier" text check ("tier" in ('bronze', 'silver', 'gold', 'platinum')) not null default 'bronze', "current_streak" integer not null default 0, "longest_streak" integer not null default 0, "last_checkin_date" text null, "last_wheel_spin_date" text null, "created_at" timestamptz not null default now(), "updated_at" timestamptz not null default now(), "deleted_at" timestamptz null, constraint "customer_loyalty_pkey" primary key ("id"));`);
    this.addSql(`CREATE UNIQUE INDEX IF NOT EXISTS "IDX_customer_loyalty_customer_id_unique" ON "customer_loyalty" ("customer_id") WHERE deleted_at IS NULL;`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_customer_loyalty_deleted_at" ON "customer_loyalty" ("deleted_at") WHERE deleted_at IS NULL;`);

    this.addSql(`create table if not exists "daily_check_in" ("id" text not null, "checkin_date" text not null, "streak_count_at_checkin" integer not null, "points_earned" integer not null, "loyalty_id" text not null, "created_at" timestamptz not null default now(), "updated_at" timestamptz not null default now(), "deleted_at" timestamptz null, constraint "daily_check_in_pkey" primary key ("id"));`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_daily_check_in_loyalty_id" ON "daily_check_in" ("loyalty_id") WHERE deleted_at IS NULL;`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_daily_check_in_deleted_at" ON "daily_check_in" ("deleted_at") WHERE deleted_at IS NULL;`);

    this.addSql(`create table if not exists "loyalty_coupon" ("id" text not null, "customer_id" text not null, "promotion_id" text not null, "code" text not null, "source" text check ("source" in ('wheel', 'checkin_milestone', 'referral', 'manual')) not null, "discount_type" text check ("discount_type" in ('percentage', 'fixed', 'free_shipping')) not null, "discount_value" integer null, "status" text check ("status" in ('issued', 'redeemed', 'expired')) not null default 'issued', "expires_at" timestamptz null, "redeemed_at" timestamptz null, "redeemed_order_id" text null, "source_ref_id" text null, "created_at" timestamptz not null default now(), "updated_at" timestamptz not null default now(), "deleted_at" timestamptz null, constraint "loyalty_coupon_pkey" primary key ("id"));`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_loyalty_coupon_customer_id" ON "loyalty_coupon" ("customer_id") WHERE deleted_at IS NULL;`);
    this.addSql(`CREATE UNIQUE INDEX IF NOT EXISTS "IDX_loyalty_coupon_code_unique" ON "loyalty_coupon" ("code") WHERE deleted_at IS NULL;`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_loyalty_coupon_deleted_at" ON "loyalty_coupon" ("deleted_at") WHERE deleted_at IS NULL;`);

    this.addSql(`create table if not exists "loyalty_transaction" ("id" text not null, "customer_id" text not null, "type" text check ("type" in ('checkin', 'wheel_spin', 'redeem_adjustment', 'admin_adjust')) not null, "points_delta" integer not null, "balance_after" integer not null, "description" text null, "ref_id" text null, "created_at" timestamptz not null default now(), "updated_at" timestamptz not null default now(), "deleted_at" timestamptz null, constraint "loyalty_transaction_pkey" primary key ("id"));`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_loyalty_transaction_customer_id" ON "loyalty_transaction" ("customer_id") WHERE deleted_at IS NULL;`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_loyalty_transaction_deleted_at" ON "loyalty_transaction" ("deleted_at") WHERE deleted_at IS NULL;`);

    this.addSql(`create table if not exists "wheel_prize" ("id" text not null, "label" text not null, "prize_type" text check ("prize_type" in ('points', 'coupon_percentage', 'coupon_fixed', 'free_shipping', 'no_win')) not null, "points_value" integer null, "coupon_discount_value" integer null, "coupon_validity_days" integer null, "weight" integer not null default 1, "color" text null, "icon" text null, "is_active" boolean not null default true, "sort_order" integer not null default 0, "created_at" timestamptz not null default now(), "updated_at" timestamptz not null default now(), "deleted_at" timestamptz null, constraint "wheel_prize_pkey" primary key ("id"));`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_wheel_prize_deleted_at" ON "wheel_prize" ("deleted_at") WHERE deleted_at IS NULL;`);

    this.addSql(`create table if not exists "wheel_spin" ("id" text not null, "prize_id" text not null, "spin_date" text not null, "points_earned" integer not null default 0, "coupon_id" text null, "loyalty_id" text not null, "created_at" timestamptz not null default now(), "updated_at" timestamptz not null default now(), "deleted_at" timestamptz null, constraint "wheel_spin_pkey" primary key ("id"));`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_wheel_spin_loyalty_id" ON "wheel_spin" ("loyalty_id") WHERE deleted_at IS NULL;`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_wheel_spin_deleted_at" ON "wheel_spin" ("deleted_at") WHERE deleted_at IS NULL;`);

    this.addSql(`alter table if exists "daily_check_in" add constraint "daily_check_in_loyalty_id_foreign" foreign key ("loyalty_id") references "customer_loyalty" ("id") on update cascade;`);

    this.addSql(`alter table if exists "wheel_spin" add constraint "wheel_spin_loyalty_id_foreign" foreign key ("loyalty_id") references "customer_loyalty" ("id") on update cascade;`);
  }

  override async down(): Promise<void> {
    this.addSql(`alter table if exists "daily_check_in" drop constraint if exists "daily_check_in_loyalty_id_foreign";`);

    this.addSql(`alter table if exists "wheel_spin" drop constraint if exists "wheel_spin_loyalty_id_foreign";`);

    this.addSql(`drop table if exists "customer_loyalty" cascade;`);

    this.addSql(`drop table if exists "daily_check_in" cascade;`);

    this.addSql(`drop table if exists "loyalty_coupon" cascade;`);

    this.addSql(`drop table if exists "loyalty_transaction" cascade;`);

    this.addSql(`drop table if exists "wheel_prize" cascade;`);

    this.addSql(`drop table if exists "wheel_spin" cascade;`);
  }

}
