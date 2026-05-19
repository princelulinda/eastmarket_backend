import { Migration } from "@medusajs/framework/mikro-orm/migrations";

export class AddStreamingFieldsToVideo extends Migration {

  override async up(): Promise<void> {
    this.addSql(`
      alter table if exists "short_video" 
      add column if not exists "hls_url" text null,
      add column if not exists "is_processed" boolean not null default false;
    `)
  }

  override async down(): Promise<void> {
    this.addSql(`
      alter table if exists "short_video" 
      drop column if exists "hls_url",
      drop column if exists "is_processed";
    `)
  }

}
