import { Migration } from "@medusajs/framework/mikro-orm/migrations";

export class Migration20260812131826 extends Migration {

  override async up(): Promise<void> {
    this.addSql(`alter table if exists "flash_sale" alter column "product_ids" type jsonb using ("product_ids"::jsonb);`);
    this.addSql(`alter table if exists "flash_sale" alter column "product_ids" drop not null;`);
  }

  override async down(): Promise<void> {
    this.addSql(`alter table if exists "flash_sale" alter column "product_ids" type jsonb using ("product_ids"::jsonb);`);
    this.addSql(`alter table if exists "flash_sale" alter column "product_ids" set not null;`);
  }

}
