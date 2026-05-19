# Customer API — Documentation Complète

> Base URL: `https://your-api.com`
> Tous les montants sont en **centimes** (ex: `2999` = 29,99€)
> Header d'auth: `Authorization: Bearer <token>`

---

## 1. AUTHENTIFICATION

### 1.1 Inscription

`POST /auth/customer/emailpass/register`

Crée une identité d'authentification. À appeler **avant** `POST /store/customers`.

**Payload**
```json
{
  "email": "jean.dupont@email.com",
  "password": "MotDePasse123!"
}
```

**Réponse 200**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Erreur 400** — email déjà utilisé
```json
{ "message": "Identity with email already exists" }
```

---

### 1.2 Connexion

`POST /auth/customer/emailpass`

**Payload**
```json
{
  "email": "jean.dupont@email.com",
  "password": "MotDePasse123!"
}
```

**Réponse 200**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Erreur 401**
```json
{ "message": "Invalid credentials" }
```

---

### 1.3 Rafraîchir le token

`POST /auth/token/refresh`

> Header: `Authorization: Bearer <refresh_token>`

**Réponse 200**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

## 2. PROFIL CLIENT

### 2.1 Créer le profil client

`POST /store/customers`

> À appeler juste après l'inscription avec le token obtenu.

**Payload**
```json
{
  "first_name": "Jean",
  "last_name": "Dupont",
  "email": "jean.dupont@email.com",
  "phone": "+33612345678"
}
```

**Réponse 200**
```json
{
  "customer": {
    "id": "cus_01JXYZ123ABC",
    "first_name": "Jean",
    "last_name": "Dupont",
    "email": "jean.dupont@email.com",
    "phone": "+33612345678",
    "has_account": true,
    "addresses": [],
    "created_at": "2026-04-17T10:00:00.000Z",
    "updated_at": "2026-04-17T10:00:00.000Z"
  }
}
```

---

### 2.2 Récupérer le profil connecté

`GET /store/customers/me`

**Réponse 200**
```json
{
  "customer": {
    "id": "cus_01JXYZ123ABC",
    "first_name": "Jean",
    "last_name": "Dupont",
    "email": "jean.dupont@email.com",
    "phone": "+33612345678",
    "has_account": true,
    "default_billing_address_id": "addr_01JXYZ456DEF",
    "default_shipping_address_id": "addr_01JXYZ456DEF",
    "addresses": [
      {
        "id": "addr_01JXYZ456DEF",
        "first_name": "Jean",
        "last_name": "Dupont",
        "address_1": "12 rue de la Paix",
        "address_2": "Apt 3B",
        "city": "Paris",
        "postal_code": "75001",
        "country_code": "fr",
        "province": "Île-de-France",
        "phone": "+33612345678",
        "is_default_shipping": true,
        "is_default_billing": true
      }
    ],
    "created_at": "2026-04-17T10:00:00.000Z",
    "updated_at": "2026-04-17T10:00:00.000Z"
  }
}
```

---

### 2.3 Modifier le profil

`POST /store/customers/me`

**Payload** (tous les champs sont optionnels)
```json
{
  "first_name": "Jean-Pierre",
  "last_name": "Dupont",
  "phone": "+33699999999"
}
```

**Réponse 200**
```json
{
  "customer": {
    "id": "cus_01JXYZ123ABC",
    "first_name": "Jean-Pierre",
    "last_name": "Dupont",
    "email": "jean.dupont@email.com",
    "phone": "+33699999999",
    "updated_at": "2026-04-17T11:00:00.000Z"
  }
}
```

---

## 3. GESTION DES ADRESSES

### 3.1 Ajouter une adresse

`POST /store/customers/me/addresses`

**Payload**
```json
{
  "first_name": "Jean",
  "last_name": "Dupont",
  "address_1": "12 rue de la Paix",
  "address_2": "Apt 3B",
  "city": "Paris",
  "postal_code": "75001",
  "country_code": "fr",
  "province": "Île-de-France",
  "phone": "+33612345678",
  "is_default_shipping": true,
  "is_default_billing": true
}
```

**Réponse 200**
```json
{
  "customer": {
    "id": "cus_01JXYZ123ABC",
    "addresses": [
      {
        "id": "addr_01JXYZ456DEF",
        "first_name": "Jean",
        "last_name": "Dupont",
        "address_1": "12 rue de la Paix",
        "address_2": "Apt 3B",
        "city": "Paris",
        "postal_code": "75001",
        "country_code": "fr",
        "province": "Île-de-France",
        "phone": "+33612345678",
        "is_default_shipping": true,
        "is_default_billing": true,
        "created_at": "2026-04-17T10:00:00.000Z"
      }
    ]
  }
}
```

---

### 3.2 Lister les adresses

`GET /store/customers/me/addresses`

**Réponse 200**
```json
{
  "addresses": [
    {
      "id": "addr_01JXYZ456DEF",
      "first_name": "Jean",
      "last_name": "Dupont",
      "address_1": "12 rue de la Paix",
      "address_2": "Apt 3B",
      "city": "Paris",
      "postal_code": "75001",
      "country_code": "fr",
      "province": "Île-de-France",
      "phone": "+33612345678",
      "is_default_shipping": true,
      "is_default_billing": true
    }
  ],
  "count": 1
}
```

---

### 3.3 Modifier une adresse

`POST /store/customers/me/addresses/:address_id`

**Payload** (tous les champs sont optionnels)
```json
{
  "address_1": "15 rue de Rivoli",
  "postal_code": "75004",
  "is_default_shipping": true
}
```

**Réponse 200**
```json
{
  "customer": {
    "id": "cus_01JXYZ123ABC",
    "addresses": [
      {
        "id": "addr_01JXYZ456DEF",
        "address_1": "15 rue de Rivoli",
        "city": "Paris",
        "postal_code": "75004",
        "country_code": "fr",
        "is_default_shipping": true,
        "updated_at": "2026-04-17T12:00:00.000Z"
      }
    ]
  }
}
```

---

### 3.4 Supprimer une adresse

`DELETE /store/customers/me/addresses/:address_id`

**Réponse 200**
```json
{
  "id": "addr_01JXYZ456DEF",
  "deleted": true,
  "parent": { "id": "cus_01JXYZ123ABC" }
}
```

---

## 4. CATALOGUE

### 4.1 Lister les régions

`GET /store/regions`

**Réponse 200**
```json
{
  "regions": [
    {
      "id": "reg_01JXYZ111AAA",
      "name": "Europe",
      "currency_code": "eur",
      "countries": [
        { "iso_2": "fr", "name": "France" },
        { "iso_2": "be", "name": "Belgium" }
      ]
    }
  ]
}
```

---

### 4.2 Lister les catégories

`GET /store/product-categories`

**Réponse 200**
```json
{
  "product_categories": [
    {
      "id": "cat_01JXYZ222BBB",
      "name": "Vêtements",
      "handle": "vetements",
      "description": "Tous les vêtements",
      "rank": 0,
      "parent_category_id": null,
      "category_children": [
        { "id": "cat_02JXYZ333CCC", "name": "T-shirts", "handle": "t-shirts" },
        { "id": "cat_03JXYZ444DDD", "name": "Robes", "handle": "robes" }
      ]
    }
  ],
  "count": 1
}
```

---

### 4.3 Lister les produits

`GET /store/products?region_id=reg_01JXYZ111AAA&limit=20&offset=0`

**Paramètres disponibles**

| Paramètre | Type | Description |
|---|---|---|
| `region_id` | string | Obligatoire pour les prix |
| `category_id[]` | string[] | Filtrer par catégorie |
| `q` | string | Recherche textuelle |
| `limit` | number | Résultats par page (défaut: 20) |
| `offset` | number | Pagination |
| `order` | string | `created_at` ou `-created_at` |

**Réponse 200**
```json
{
  "products": [
    {
      "id": "prod_01JXYZ555EEE",
      "title": "T-shirt Premium",
      "handle": "t-shirt-premium",
      "description": "T-shirt en coton bio, coupe moderne",
      "thumbnail": "https://cdn.example.com/tshirt-thumb.jpg",
      "status": "published",
      "variants": [
        {
          "id": "var_01JXYZ666FFF",
          "title": "S / Blanc",
          "sku": "TSH-S-WHT",
          "inventory_quantity": 50,
          "prices": [{ "amount": 2999, "currency_code": "eur" }]
        },
        {
          "id": "var_02JXYZ777GGG",
          "title": "M / Blanc",
          "sku": "TSH-M-WHT",
          "inventory_quantity": 30,
          "prices": [{ "amount": 2999, "currency_code": "eur" }]
        }
      ],
      "options": [
        {
          "id": "opt_01J...",
          "title": "Taille",
          "values": [{ "value": "S" }, { "value": "M" }, { "value": "L" }]
        },
        {
          "id": "opt_02J...",
          "title": "Couleur",
          "values": [{ "value": "Blanc" }, { "value": "Noir" }]
        }
      ],
      "images": [
        { "id": "img_01J...", "url": "https://cdn.example.com/tshirt-1.jpg" },
        { "id": "img_02J...", "url": "https://cdn.example.com/tshirt-2.jpg" }
      ],
      "categories": [{ "id": "cat_02JXYZ333CCC", "name": "T-shirts" }],
      "tags": [{ "value": "coton" }, { "value": "bio" }]
    }
  ],
  "count": 1,
  "limit": 20,
  "offset": 0
}
```

---

### 4.4 Détail d'un produit

`GET /store/products/:id?region_id=reg_01JXYZ111AAA`

**Réponse 200** — même structure que ci-dessus mais objet unique
```json
{
  "product": { "id": "prod_01JXYZ555EEE", "title": "T-shirt Premium", "..." : "..." }
}
```

---

## 5. VENDORS (custom)

### 5.1 Lister les vendors

`GET /store/vendors`

**Réponse 200**
```json
{
  "vendors": [
    {
      "id": "vendor_01JXYZ888HHH",
      "handle": "boutique-mode",
      "name": "Boutique Mode Paris",
      "logo": "https://cdn.example.com/logo.jpg",
      "cover_image": "https://cdn.example.com/cover.jpg",
      "description": "Spécialiste de la mode depuis 2018",
      "country": "FR",
      "city": "Paris",
      "business_type": "retailer",
      "is_verified": true,
      "response_rate": 98,
      "response_time": "within 1 hour",
      "founded_year": 2018,
      "employee_count": "11-50"
    }
  ]
}
```

---

### 5.2 Profil complet d'un vendor

`GET /store/vendors/:id`

**Réponse 200**
```json
{
  "vendor": {
    "id": "vendor_01JXYZ888HHH",
    "handle": "boutique-mode",
    "name": "Boutique Mode Paris",
    "logo": "https://cdn.example.com/logo.jpg",
    "cover_image": "https://cdn.example.com/cover.jpg",
    "description": "Spécialiste de la mode depuis 2018. Nous proposons des vêtements de qualité.",
    "phone": "+33612345678",
    "email": "contact@boutique-mode.com",
    "website": "https://boutique-mode.com",
    "country": "FR",
    "city": "Paris",
    "address": "12 rue de la Paix, 75001 Paris",
    "founded_year": 2018,
    "business_type": "retailer",
    "main_products": "T-shirts, Robes, Pantalons, Accessoires",
    "employee_count": "11-50",
    "social_links": {
      "instagram": "https://instagram.com/boutique-mode",
      "facebook": "https://facebook.com/boutique-mode",
      "whatsapp": "+33612345678",
      "tiktok": "https://tiktok.com/@boutique-mode"
    },
    "is_verified": true,
    "response_rate": 98,
    "response_time": "within 1 hour"
  }
}
```

---

### 5.3 Produits d'un vendor

`GET /store/vendors/:id/products`

**Réponse 200**
```json
{
  "products": [
    {
      "id": "prod_01JXYZ555EEE",
      "title": "T-shirt Premium",
      "handle": "t-shirt-premium",
      "thumbnail": "https://cdn.example.com/tshirt-thumb.jpg",
      "variants": [
        {
          "id": "var_01JXYZ666FFF",
          "title": "S / Blanc",
          "prices": [{ "amount": 2999, "currency_code": "eur" }]
        }
      ],
      "images": [{ "url": "https://cdn.example.com/tshirt-1.jpg" }],
      "categories": [{ "name": "T-shirts" }]
    }
  ]
}
```

---

### 5.4 Détail d'un produit d'un vendor

`GET /store/vendors/:vendor_id/products/:product_id`

**Réponse 200**
```json
{
  "product": {
    "id": "prod_01JXYZ555EEE",
    "title": "T-shirt Premium",
    "handle": "t-shirt-premium",
    "description": "T-shirt en coton bio, coupe moderne",
    "thumbnail": "https://cdn.example.com/tshirt-thumb.jpg",
    "variants": [
      {
        "id": "var_01JXYZ666FFF",
        "title": "S / Blanc",
        "sku": "TSH-S-WHT",
        "inventory_quantity": 50,
        "prices": [{ "amount": 2999, "currency_code": "eur" }]
      }
    ],
    "options": [
      { "title": "Taille", "values": [{ "value": "S" }, { "value": "M" }] }
    ],
    "images": [
      { "url": "https://cdn.example.com/tshirt-1.jpg" },
      { "url": "https://cdn.example.com/tshirt-2.jpg" }
    ],
    "categories": [{ "id": "cat_02JXYZ333CCC", "name": "T-shirts" }]
  }
}
```

---

## 6. PANIER

### 6.1 Créer un panier

`POST /store/carts`

**Payload**
```json
{
  "region_id": "reg_01JXYZ111AAA",
  "customer_id": "cus_01JXYZ123ABC"
}
```

**Réponse 200**
```json
{
  "cart": {
    "id": "cart_01JXYZ999III",
    "customer_id": "cus_01JXYZ123ABC",
    "region_id": "reg_01JXYZ111AAA",
    "currency_code": "eur",
    "items": [],
    "subtotal": 0,
    "shipping_total": 0,
    "tax_total": 0,
    "total": 0,
    "created_at": "2026-04-17T10:00:00.000Z"
  }
}
```

---

### 6.2 Ajouter un article

`POST /store/carts/:cart_id/line-items`

**Payload**
```json
{
  "variant_id": "var_01JXYZ666FFF",
  "quantity": 2
}
```

**Réponse 200**
```json
{
  "cart": {
    "id": "cart_01JXYZ999III",
    "items": [
      {
        "id": "item_01JXYZ000JJJ",
        "title": "T-shirt Premium",
        "variant_id": "var_01JXYZ666FFF",
        "variant": { "title": "S / Blanc", "sku": "TSH-S-WHT" },
        "thumbnail": "https://cdn.example.com/tshirt-thumb.jpg",
        "quantity": 2,
        "unit_price": 2999,
        "subtotal": 5998,
        "total": 5998
      }
    ],
    "subtotal": 5998,
    "shipping_total": 0,
    "tax_total": 0,
    "total": 5998
  }
}
```

---

### 6.3 Modifier la quantité d'un article

`POST /store/carts/:cart_id/line-items/:item_id`

**Payload**
```json
{ "quantity": 3 }
```

**Réponse 200** — même structure que 6.2

---

### 6.4 Supprimer un article

`DELETE /store/carts/:cart_id/line-items/:item_id`

**Réponse 200**
```json
{
  "id": "item_01JXYZ000JJJ",
  "deleted": true,
  "parent": { "id": "cart_01JXYZ999III" }
}
```

---

### 6.5 Ajouter l'adresse de livraison au panier

`POST /store/carts/:cart_id`

**Payload**
```json
{
  "email": "jean.dupont@email.com",
  "shipping_address": {
    "first_name": "Jean",
    "last_name": "Dupont",
    "address_1": "12 rue de la Paix",
    "address_2": "Apt 3B",
    "city": "Paris",
    "postal_code": "75001",
    "country_code": "fr",
    "phone": "+33612345678"
  },
  "billing_address": {
    "first_name": "Jean",
    "last_name": "Dupont",
    "address_1": "12 rue de la Paix",
    "city": "Paris",
    "postal_code": "75001",
    "country_code": "fr"
  }
}
```

**Réponse 200**
```json
{
  "cart": {
    "id": "cart_01JXYZ999III",
    "email": "jean.dupont@email.com",
    "shipping_address": {
      "first_name": "Jean",
      "last_name": "Dupont",
      "address_1": "12 rue de la Paix",
      "city": "Paris",
      "postal_code": "75001",
      "country_code": "fr"
    }
  }
}
```

---

### 6.6 Récupérer les options de livraison

`GET /store/shipping-options?cart_id=cart_01JXYZ999III`

**Réponse 200**
```json
{
  "shipping_options": [
    {
      "id": "so_01JXYZ111KKK",
      "name": "Livraison standard",
      "amount": 499,
      "currency_code": "eur",
      "provider_id": "manual"
    },
    {
      "id": "so_02JXYZ222LLL",
      "name": "Livraison express",
      "amount": 999,
      "currency_code": "eur",
      "provider_id": "manual"
    }
  ]
}
```

---

### 6.7 Choisir la méthode de livraison

`POST /store/carts/:cart_id/shipping-methods`

**Payload**
```json
{ "option_id": "so_01JXYZ111KKK" }
```

**Réponse 200**
```json
{
  "cart": {
    "id": "cart_01JXYZ999III",
    "shipping_methods": [
      {
        "id": "sm_01J...",
        "name": "Livraison standard",
        "amount": 499
      }
    ],
    "subtotal": 5998,
    "shipping_total": 499,
    "tax_total": 0,
    "total": 6497
  }
}
```

---

## 7. PAIEMENT

### 7.1 Créer une collection de paiement

`POST /store/payment-collections`

**Payload**
```json
{ "cart_id": "cart_01JXYZ999III" }
```

**Réponse 200**
```json
{
  "payment_collection": {
    "id": "paycol_01JXYZ333MMM",
    "status": "not_paid",
    "amount": 6497,
    "currency_code": "eur"
  }
}
```

---

### 7.2 Initier une session de paiement

`POST /store/payment-collections/:paycol_id/payment-sessions`

**Payload**
```json
{ "provider_id": "pp_stripe_stripe" }
```

**Réponse 200**
```json
{
  "payment_collection": {
    "id": "paycol_01JXYZ333MMM",
    "status": "not_paid",
    "payment_sessions": [
      {
        "id": "ps_01JXYZ444NNN",
        "provider_id": "pp_stripe_stripe",
        "status": "pending",
        "data": {
          "client_secret": "pi_3OxYZ_secret_AbCdEfGhIj"
        }
      }
    ]
  }
}
```

> Le `client_secret` est utilisé par le SDK Stripe côté mobile pour afficher le formulaire de paiement.

---

### 7.3 Finaliser la commande

`POST /store/carts/:cart_id/complete-vendor`

> Appeler après confirmation du paiement côté Stripe.

**Réponse 200**
```json
{
  "type": "order",
  "order": {
    "id": "order_01JXYZ555OOO",
    "status": "pending",
    "display_id": 1042,
    "email": "jean.dupont@email.com",
    "currency_code": "eur",
    "subtotal": 5998,
    "shipping_total": 499,
    "tax_total": 0,
    "total": 6497,
    "items": [
      {
        "id": "item_01JXYZ000JJJ",
        "title": "T-shirt Premium",
        "variant_id": "var_01JXYZ666FFF",
        "quantity": 2,
        "unit_price": 2999,
        "total": 5998,
        "thumbnail": "https://cdn.example.com/tshirt-thumb.jpg"
      }
    ],
    "shipping_address": {
      "first_name": "Jean",
      "last_name": "Dupont",
      "address_1": "12 rue de la Paix",
      "city": "Paris",
      "postal_code": "75001",
      "country_code": "fr"
    },
    "shipping_methods": [
      { "name": "Livraison standard", "amount": 499 }
    ],
    "payment_collections": [
      { "status": "authorized", "amount": 6497 }
    ],
    "fulfillments": [],
    "created_at": "2026-04-17T10:30:00.000Z"
  }
}
```

---

## 8. COMMANDES CLIENT

### 8.1 Historique des commandes

`GET /store/customers/me/orders`

**Réponse 200**
```json
{
  "orders": [
    {
      "id": "order_01JXYZ555OOO",
      "status": "pending",
      "display_id": 1042,
      "currency_code": "eur",
      "total": 6497,
      "subtotal": 5998,
      "shipping_total": 499,
      "items": [
        {
          "id": "item_01JXYZ000JJJ",
          "title": "T-shirt Premium",
          "quantity": 2,
          "unit_price": 2999,
          "thumbnail": "https://cdn.example.com/tshirt-thumb.jpg"
        }
      ],
      "fulfillments": [],
      "payment_collections": [{ "status": "authorized" }],
      "created_at": "2026-04-17T10:30:00.000Z"
    }
  ],
  "count": 1,
  "limit": 10,
  "offset": 0
}
```

---

## 9. MOYENS DE PAIEMENT ENREGISTRÉS

### 9.1 Lister les moyens de paiement

`GET /store/payment-methods`

**Réponse 200**
```json
{
  "payment_methods": [
    {
      "id": "pm_01JXYZ...",
      "provider_id": "stripe",
      "label": "Ma carte Visa",
      "is_default": true,
      "data": {
        "last4": "4242",
        "brand": "visa",
        "exp_month": 12,
        "exp_year": 2028
      }
    }
  ],
  "count": 1
}
```

### 9.2 Ajouter un moyen de paiement

`POST /store/payment-methods`

**Payload**
```json
{
  "provider_id": "stripe",
  "label": "Ma nouvelle carte",
  "is_default": true,
  "data": {
    "token": "tok_123...",
    "last4": "1234",
    "brand": "mastercard"
  }
}
```

**Réponse 200**
```json
{
  "payment_method": {
    "id": "pm_01JXYZ...",
    "provider_id": "stripe",
    "label": "Ma nouvelle carte",
    "is_default": true,
    "data": { "last4": "1234", "brand": "mastercard" }
  }
}
```

### 9.3 Définir comme moyen par défaut

`POST /store/payment-methods/:id/default`

**Réponse 200**
```json
{
  "payment_method": { "id": "pm_01JXYZ...", "is_default": true }
}
```

### 9.4 Supprimer un moyen de paiement

`DELETE /store/payment-methods/:id`

**Réponse 200**
```json
{
  "id": "pm_01JXYZ...",
  "deleted": true
}
```

---

## 10. FLUX COMPLET D'ACHAT

```
1. POST /auth/customer/emailpass/register     → obtenir token
2. POST /store/customers                       → créer profil
3. POST /store/customers/me/addresses          → ajouter adresse
4. GET  /store/regions                         → récupérer region_id
5. GET  /store/products?region_id=...          → parcourir catalogue
6. GET  /store/vendors                         → voir les vendeurs
7. POST /store/carts                           → créer panier
8. POST /store/carts/:id/line-items            → ajouter articles
9. POST /store/carts/:id                       → adresse livraison + email
10. GET  /store/shipping-options?cart_id=...   → options livraison
11. POST /store/carts/:id/shipping-methods     → choisir livraison
12. POST /store/payment-collections            → créer paiement
13. POST /store/payment-collections/:id/payment-sessions → initier Stripe
14. [Stripe SDK mobile confirme le paiement]
15. POST /store/carts/:id/complete-vendor      → finaliser commande
16. GET  /store/customers/me/orders            → voir la commande
```
