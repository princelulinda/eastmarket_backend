import { Migration } from "@medusajs/framework/mikro-orm/migrations";

/**
 * `video_comment.customer_id` doit être nullable : une réponse publiée par le
 * vendeur n'a pas de client émetteur (c'est `vendor_id` qui est renseigné).
 *
 * Le modèle le déclarait déjà nullable, mais la table avait été créée en NOT NULL
 * par Migration20260418200000 et la migration suivante utilisait
 * `create table if not exists`, qui n'a donc rien modifié. Résultat : toute
 * réponse vendeur échouait au niveau de la base.
 */
export class Migration20260819170000 extends Migration {
  override async up(): Promise<void> {
    this.addSql(`alter table if exists "video_comment" alter column "customer_id" drop not null;`);
  }

  override async down(): Promise<void> {
    this.addSql(`delete from "video_comment" where "customer_id" is null;`);
    this.addSql(`alter table if exists "video_comment" alter column "customer_id" set not null;`);
  }
}
