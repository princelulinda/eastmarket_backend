import { Migration } from "@medusajs/framework/mikro-orm/migrations";

/** Nouveau type de notification : alerte de stock bas ou de rupture. */
export class Migration20260824130500 extends Migration {

  override async up(): Promise<void> {
    this.addSql(`alter table if exists "app_notification" drop constraint if exists "app_notification_type_check";`);
    this.addSql(`alter table if exists "app_notification" add constraint "app_notification_type_check" check ("type" in ('new_message', 'new_order', 'order_status', 'order_shipped', 'order_delivered', 'order_cancelled', 'new_review', 'review_reply', 'reward_won', 'streak_milestone', 'new_video', 'referral_reward', 'offer_response', 'chat_reminder', 'cart_reminder', 'low_stock', 'system'));`);
  }

  override async down(): Promise<void> {
    this.addSql(`alter table if exists "app_notification" drop constraint if exists "app_notification_type_check";`);
    this.addSql(`alter table if exists "app_notification" add constraint "app_notification_type_check" check ("type" in ('new_message', 'new_order', 'order_status', 'order_shipped', 'order_delivered', 'order_cancelled', 'new_review', 'review_reply', 'reward_won', 'streak_milestone', 'new_video', 'referral_reward', 'offer_response', 'chat_reminder', 'cart_reminder', 'system'));`);
  }

}
