import { Migration } from "@medusajs/framework/mikro-orm/migrations";

export class Migration20260526032822 extends Migration {

  override async up(): Promise<void> {
    this.addSql(`create table if not exists "short_video" ("id" text not null, "vendor_id" text not null, "title" text not null, "description" text null, "video_url" text not null, "hls_url" text null, "thumbnail_url" text null, "duration" integer null, "tag" text null, "status" text check ("status" in ('draft', 'published', 'archived')) not null default 'draft', "is_processed" boolean not null default false, "likes_count" integer not null default 0, "comments_count" integer not null default 0, "shares_count" integer not null default 0, "views_count" integer not null default 0, "product_ids" jsonb null, "created_at" timestamptz not null default now(), "updated_at" timestamptz not null default now(), "deleted_at" timestamptz null, constraint "short_video_pkey" primary key ("id"));`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_short_video_deleted_at" ON "short_video" ("deleted_at") WHERE deleted_at IS NULL;`);

    this.addSql(`create table if not exists "video_comment" ("id" text not null, "video_id" text not null, "customer_id" text null, "vendor_id" text null, "content" text not null, "parent_id" text null, "created_at" timestamptz not null default now(), "updated_at" timestamptz not null default now(), "deleted_at" timestamptz null, constraint "video_comment_pkey" primary key ("id"));`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_video_comment_deleted_at" ON "video_comment" ("deleted_at") WHERE deleted_at IS NULL;`);

    this.addSql(`create table if not exists "video_like" ("id" text not null, "video_id" text not null, "customer_id" text not null, "created_at" timestamptz not null default now(), "updated_at" timestamptz not null default now(), "deleted_at" timestamptz null, constraint "video_like_pkey" primary key ("id"));`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_video_like_deleted_at" ON "video_like" ("deleted_at") WHERE deleted_at IS NULL;`);

    this.addSql(`create table if not exists "video_save" ("id" text not null, "video_id" text not null, "customer_id" text not null, "created_at" timestamptz not null default now(), "updated_at" timestamptz not null default now(), "deleted_at" timestamptz null, constraint "video_save_pkey" primary key ("id"));`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_video_save_deleted_at" ON "video_save" ("deleted_at") WHERE deleted_at IS NULL;`);
  }

  override async down(): Promise<void> {
    this.addSql(`drop table if exists "short_video" cascade;`);

    this.addSql(`drop table if exists "video_comment" cascade;`);

    this.addSql(`drop table if exists "video_like" cascade;`);

    this.addSql(`drop table if exists "video_save" cascade;`);
  }

}
