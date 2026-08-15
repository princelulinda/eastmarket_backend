import { Migration } from "@medusajs/framework/mikro-orm/migrations"

export class Migration20260813060000 extends Migration {
  override async up(): Promise<void> {
    this.addSql(`
      alter table if exists "loyalty_transaction" drop constraint if exists "loyalty_transaction_type_check";
      alter table if exists "loyalty_transaction"
        add constraint "loyalty_transaction_type_check"
        check ("type" in ('checkin', 'wheel_spin', 'redeem_adjustment', 'admin_adjust', 'chat_engagement'));
    `)
  }

  override async down(): Promise<void> {
    this.addSql(`
      alter table if exists "loyalty_transaction" drop constraint if exists "loyalty_transaction_type_check";
      alter table if exists "loyalty_transaction"
        add constraint "loyalty_transaction_type_check"
        check ("type" in ('checkin', 'wheel_spin', 'redeem_adjustment', 'admin_adjust'));
    `)
  }
}
