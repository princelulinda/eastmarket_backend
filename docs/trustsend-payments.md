# Paiements mobile money TrustSend

> Sandbox : `https://sandbox-api.trustsend.africa/api/v1` — clés `ts_sandbox_…`
> Production : `https://api.trustsend.africa/api/v1` — clés `ts_live_…`
> Documentation TrustSend : https://docs.trustsend.africa

Un paiement TrustSend est un **dépôt** : le compte mobile money du client est débité et le wallet
business est crédité. L'opération est asynchrone — l'API répond immédiatement avec une transaction
`processing`, le client confirme sur son téléphone, puis le statut final arrive par webhook.

---

## 1. Configuration

### 1.1 Variables d'environnement

```bash
TRUSTSEND_API_URL=https://sandbox-api.trustsend.africa/api/v1
TRUSTSEND_API_KEY=ts_sandbox_xxxxxxxxxxxxxxxx
TRUSTSEND_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxxxxx
MEDUSA_BACKEND_URL=https://api.eastmarket.africa   # doit être joignable depuis internet
```

La clé API se génère depuis l'Espace client TrustSend (sandbox : compte actif dès l'inscription,
aucune vérification). Une clé sandbox envoyée à l'API de production est refusée, et inversement.

### 1.2 Abonnement webhook

Le secret n'est affiché qu'à la création de l'abonnement — le stocker immédiatement.

```bash
curl -X POST https://sandbox-api.trustsend.africa/api/v1/business/webhooks \
  -H "Authorization: Bearer $TRUSTSEND_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://api.eastmarket.africa/hooks/trustsend",
    "events": ["mobile_money_deposit.completed", "mobile_money_deposit.failed"]
  }'
```

### 1.3 Activer le fournisseur sur la région

```bash
npx medusa exec ./src/scripts/payment_seed.ts
```

Le script lie `pp_trustsend_trustsend` à la région. Un wallet actif doit exister côté TrustSend
dans la devise de la région, sinon le dépôt répond `404`.

---

## 2. Parcours de paiement côté storefront

### 2.1 Lister les opérateurs

`GET /store/trustsend/payment-methods?currency_code=CDF&operation_type=DEPOSIT`

La clé TrustSend ne sort jamais du backend : la route sert de relais.

**Réponse 200**
```json
{
  "currency_code": "USD",
  "payment_methods": [
    {
      "provider": "AIRTEL_COD",
      "display_name": "Airtel",
      "status": "OPERATIONAL",
      "min_amount": "10",
      "max_amount": "250000",
      "logo": "https://static-content.pawapay.io/provider_logos/airtel.png",
      "flag": "https://static-content.pawapay.io/country_flags/cod.svg",
      "country": "COD",
      "country_name": { "fr": "République démocratique du Congo", "en": "Democratic Republic of the Congo" },
      "phone_prefix": "243",
      "currency_symbol": "$",
      "authorization": { "pinPrompt": "AUTOMATIC", "pinPromptRevivable": true, "channels": [] }
    }
  ]
}
```

Ne proposer que les opérateurs dont le `status` vaut `OPERATIONAL`. `min_amount` et `max_amount`
sont en centièmes de la devise — la même unité que le montant envoyé au dépôt. `authorization`
décrit les étapes de confirmation propres à l'opérateur (USSD, lien rapide), en français et en anglais.

Les opérateurs dépendent du couple devise/pays, pas seulement de la devise : en USD, ce sont les
opérateurs de RDC (`AIRTEL_COD`, `ORANGE_COD`, `VODACOM_MPESA_COD`) qui acceptent les comptes en
dollars.

### 2.2 Créer la session de paiement

`POST /store/payment-collections/:id/payment-sessions`

```json
{
  "provider_id": "trustsend",
  "data": {
    "phone_number": "243813456789",
    "provider": "VODACOM_MPESA_COD",
    "country_code": "COD"
  }
}
```

| Champ | Requis | Règles |
|---|---|---|
| `phone_number` | oui | format international, chiffres uniquement, sans `+` ni zéro initial (8 à 15 chiffres) |
| `provider` | oui | code opérateur renvoyé en 2.1 — alias acceptés : `provider_code`, `network` |
| `country_code` | non | ISO 3166-1 alpha-3, par exemple `COD` |

`provider_id` peut être envoyé sous sa forme courte : un middleware le remappe vers
`pp_trustsend_trustsend` (voir `src/api/middlewares.ts`).

Le montant n'est pas à transmettre : il vient de la payment collection.

:warning: **East Market compte en centièmes, pas en unité principale.** La table `price`
contient `2020` pour un article à 20,20 $, et `formatAmount()` du storefront divise par 100 —
alors que Medusa v2 considère ce même nombre comme l'unité principale. Une session MBIYOPAY
réelle le confirme : `payment_session.amount = 21930` pour une commande de 219,30 $.

Le provider est donc configuré avec `amountUnit: "minor"` dans `medusa-config.ts` : le montant
part tel quel vers TrustSend, qui attend précisément des centièmes. Avec le réglage par défaut
`"major"`, il serait multiplié par 100 et facturerait cent fois trop.

Pour une boutique qui suit vraiment la convention Medusa (`10.5` = 10,50 $), laisser
`amountUnit` sur `"major"` : `1` part alors en `"100"`, ce qui a été vérifié en sandbox
(transaction `TXN-ZUXHXEV8`, `amount: "100"`, `fee: "0"`, wallet crédité de 1,00 $).

`phone_number` et `provider` sont normalisés par le provider : `"+243 973 456 789"` et
`"airtel_cod"` sont acceptés tels quels.

### 2.3 Attendre la confirmation du payeur

`GET /store/trustsend/status/:payment_collection_id`

```json
{
  "status": "pending",
  "deposit_id": "TXN-VSWC4SQ2",
  "deposit_status": "processing",
  "authorization": null
}
```

- `status` : `pending` tant que le payeur n'a pas confirmé, `authorized` ensuite — la commande
  ne peut être complétée qu'à partir de là —, `error` si le dépôt a échoué.
- `deposit_status` : l'état brut lu chez TrustSend sur cet appel (`processing`, `completed`,
  `failed`), ou `null` si la session n'avait pas à être interrogée.
- `authorization` contient, quand l'opérateur l'exige, les instructions à afficher au payeur
  (étapes USSD, lien rapide). Il vaut `null` s'il n'y a rien à faire d'autre que confirmer.

**La route ne se contente pas de lire la base.** Tant que la session est `pending`, elle demande
à TrustSend où en est le dépôt, et autorise la session elle-même dès qu'il est `completed`. Sans
ça, trois situations resteraient bloquées sur `pending` jusqu'à l'abandon du client : une
livraison webhook perdue, un abonnement webhook non configuré, et un dépôt refusé — que le
webhook ne marque volontairement pas.

C'est aussi ce qui permet de rattraper une confirmation tardive : le payeur qui valide après que
le storefront a cessé d'attendre obtient sa commande à la vérification suivante, au lieu de
relancer un second dépôt et de payer deux fois.

Le coût est un appel à TrustSend par interrogation tant que le paiement est en attente (deux
quand le dépôt est encore `processing`, à cause de la lecture `live-status`) : à régler par
l'intervalle de poll du storefront.

### 2.4 Compléter la commande

Une fois la session `authorized`, compléter le panier comme pour n'importe quel autre fournisseur.

---

## 3. Côté backend

| Fichier | Rôle |
|---|---|
| `src/modules/trustsend/service.ts` | Fournisseur de paiement : initie le dépôt, lit son statut |
| `src/modules/trustsend/client.ts` | Appels HTTP à l'API TrustSend et lecture de l'état d'un dépôt, partagés avec les routes store |
| `src/api/hooks/trustsend/route.ts` | Réception des webhooks, signature vérifiée, session autorisée |
| `src/api/store/trustsend/payment-methods/route.ts` | Liste des opérateurs |
| `src/api/store/trustsend/status/[id]/route.ts` | Suivi de la session pendant l'attente |

### 3.1 Deux chemins vers l'autorisation

1. **Webhook** — TrustSend appelle `/hooks/trustsend`. La signature `X-Webhook-Signature`
   (HMAC-SHA256 du corps brut) est vérifiée avant toute autre chose ; le corps brut est conservé
   grâce à `bodyParser: { preserveRawBody: true }` déclaré dans `src/api/middlewares.ts`.
   La livraison ne transporte que la référence TrustSend, donc la session est retrouvée par le
   `deposit_id` stocké dessus à l'initiation.
2. **Relecture** — `fetchDepositStatus()` (dans `client.ts`) relit le dépôt et interroge le
   réseau de paiement en direct tant qu'il est `processing`. Le fournisseur s'en sert quand
   Medusa autorise la session ; la route de statut s'en sert à chaque interrogation du
   storefront, et autorise la session elle-même sur un `completed`. Ce second chemin ne se
   contente pas de servir de filet : il suffit à faire aboutir un paiement sans aucun webhook.
   L'appel est idempotent, il ne crédite jamais deux fois.

   Un dépôt `failed` n'est écrit nulle part, ni par le webhook ni par la route : le marquer
   passerait par `updatePaymentSession`, donc par `updatePayment()`, qui relancerait un dépôt
   neuf. L'échec est rapporté au storefront, la session reste `pending`.

### 3.2 Correspondance des statuts

| TrustSend | Session Medusa |
|---|---|
| `processing` | `pending` |
| `completed` | `authorized` |
| `failed` | `error` |

### 3.3 Remboursements

TrustSend n'a pas d'endpoint de remboursement pour un dépôt : rendre l'argent passe par un
**payout** mobile money, qui débite le wallet et relève d'une décision commerciale. Le
fournisseur refuse donc explicitement `refundPayment` au lieu de faire semblant d'avoir remboursé.

---

## 4. Tester en sandbox

1. Créditer le wallet business si besoin (pour tester des payouts, pas nécessaire pour encaisser) :
   `POST /api/v1/business/sandbox/fund`.
2. Utiliser les numéros de test publiés par TrustSend
   (https://docs.trustsend.africa/mobile-money/test-numbers) : chaque numéro produit un résultat
   déterministe — réussite, échec avec un code précis, ou transaction qui reste en attente.
3. En local, exposer le backend avec un tunnel (ngrok…) et déclarer cette URL publique dans
   l'abonnement webhook, sinon aucune livraison n'arrive.
