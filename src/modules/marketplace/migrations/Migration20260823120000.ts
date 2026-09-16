import { Migration } from "@medusajs/framework/mikro-orm/migrations";

/**
 * Dossiers KYC vendeur + date de vérification sur la boutique.
 *
 * Schéma uniquement : aucune donnée existante n'est modifiée. La reprise des
 * boutiques déjà en ligne est une décision d'exploitation, isolée dans
 * src/scripts/grandfather-vendor-verifications.ts.
 */
export class Migration20260823120000 extends Migration {

  override async up(): Promise<void> {
    this.addSql(`create table if not exists "vendor_verification" ("id" text not null, "status" text check ("status" in ('pending', 'approved', 'rejected')) not null default 'pending', "legal_name" text not null, "id_document_type" text check ("id_document_type" in ('national_id', 'passport', 'driver_license')) not null, "id_document_number" text not null, "registration_number" text null, "tax_id" text null, "contact_phone" text not null, "contact_address" text not null, "documents" jsonb not null, "rejection_reason" text null, "reviewed_at" timestamptz null, "reviewed_by" text null, "vendor_id" text not null, "created_at" timestamptz not null default now(), "updated_at" timestamptz not null default now(), "deleted_at" timestamptz null, constraint "vendor_verification_pkey" primary key ("id"));`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_vendor_verification_vendor_id" ON "vendor_verification" ("vendor_id") WHERE deleted_at IS NULL;`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_vendor_verification_status" ON "vendor_verification" ("status") WHERE deleted_at IS NULL;`);
    this.addSql(`CREATE INDEX IF NOT EXISTS "IDX_vendor_verification_deleted_at" ON "vendor_verification" ("deleted_at") WHERE deleted_at IS NULL;`);

    this.addSql(`alter table if exists "vendor_verification" add constraint "vendor_verification_vendor_id_foreign" foreign key ("vendor_id") references "vendor" ("id") on update cascade;`);

    this.addSql(`alter table if exists "vendor" add column if not exists "verified_at" timestamptz null;`);
  }

  override async down(): Promise<void> {
    this.addSql(`drop table if exists "vendor_verification" cascade;`);
    this.addSql(`alter table if exists "vendor" drop column if exists "verified_at";`);
  }

}
