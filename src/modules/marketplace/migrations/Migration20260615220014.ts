import { Migration } from "@medusajs/framework/mikro-orm/migrations";

export class Migration20260615220014 extends Migration {

  override async up(): Promise<void> {
    this.addSql(`create table if not exists "vendor_payout" ("id" text not null, "amount" integer not null, "status" text check ("status" in ('pending', 'approved', 'rejected')) not null default 'pending', "payment_method" text not null, "payment_details" jsonb not null, "rejection_reason" text null, "vendor_id" text not null, "created_at" timestamptz not null default now(), "updated_at" timestamptz not null default now(), "deleted_at" timestamptz null, constraint "vendor_payout_pkey" primary key ("id"));`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_vendor_payout_vendor_id" ON "vendor_payout" ("vendor_id") WHERE deleted_at IS NULL;`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_vendor_payout_deleted_at" ON "vendor_payout" ("deleted_at") WHERE deleted_at IS NULL;`);

    this.addSql(`alter table if exists "vendor_payout" add constraint "vendor_payout_vendor_id_foreign" foreign key ("vendor_id") references "vendor" ("id") on update cascade;`);
  }

  override async down(): Promise<void> {
    this.addSql(`drop table if exists "vendor_payout" cascade;`);
  }

}
