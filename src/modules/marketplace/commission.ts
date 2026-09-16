/**
 * Part prélevée par la marketplace sur chaque vente.
 *
 * Était codée en dur dans subscribers/vendor-payout-on-delivery.ts. Un
 * remboursement doit reprendre au vendeur exactement ce qui lui a été crédité :
 * les deux calculs doivent donc lire la même valeur, sinon un aller-retour
 * commande → remboursement laisse de l'argent dans la balance du vendeur.
 */
export const MARKETPLACE_COMMISSION_RATE = 0.10

/** Montant revenant au vendeur sur une vente de `amount`. */
export function vendorShare(amount: number): number {
  return Math.round(Number(amount) * (1 - MARKETPLACE_COMMISSION_RATE))
}
