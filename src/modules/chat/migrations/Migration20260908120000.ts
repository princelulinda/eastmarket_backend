import { Migration } from "@medusajs/framework/mikro-orm/migrations"

export class Migration20260908120000 extends Migration {
  override async up(): Promise<void> {
    // Synchronisation delta : l'app ne redemande que les messages créés ou
    // modifiés depuis son dernier passage (`?after=`). Le filtre porte sur
    // updated_at — et pas created_at — pour que les changements sur un message
    // existant (is_read, delivered_at, reactions) redescendent aussi.
    // L'index (conversation_id, created_at) déjà en place ne couvre pas ce tri.
    this.addSql(`
      CREATE INDEX IF NOT EXISTS "IDX_message_conversation_updated_at"
      ON "message" (conversation_id, updated_at) WHERE deleted_at IS NULL;
    `)
  }

  override async down(): Promise<void> {
    this.addSql(`drop index if exists "IDX_message_conversation_updated_at";`)
  }
}
