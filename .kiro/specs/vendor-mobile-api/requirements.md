# Requirements: Vendor Mobile API

## Introduction

Ce document définit les exigences fonctionnelles pour les APIs complètes de l'application mobile vendeur sur le marketplace Medusa v2. Il couvre les endpoints manquants pour la gestion du profil, des admins, des produits, des catégories et des commandes.

---

## Requirements

### 1. Profil Vendor

#### 1.1 GET /vendors/me — Récupérer le profil complet

**User Story**: En tant que vendor admin connecté, je veux récupérer le profil complet de mon vendor (avec la liste des admins) afin d'afficher les informations dans l'app mobile.

**Acceptance Criteria**:

- GIVEN un vendor admin authentifié
  WHEN il appelle GET /vendors/me
  THEN la réponse contient `{ vendor: { id, handle, name, logo, admins[] } }`

- GIVEN un vendor admin authentifié
  WHEN il appelle GET /vendors/me
  THEN tous les admins retournés appartiennent au même vendor que l'admin connecté

- GIVEN une requête sans token d'authentification
  WHEN elle appelle GET /vendors/me
  THEN la réponse est 401 Unauthorized

#### 1.2 PUT /vendors/me — Modifier le profil vendor

**User Story**: En tant que vendor admin connecté, je veux pouvoir modifier le nom et/ou le logo de mon vendor.

**Acceptance Criteria**:

- GIVEN un vendor admin authentifié avec un body `{ name: "Nouveau nom" }`
  WHEN il appelle PUT /vendors/me
  THEN la réponse contient le vendor avec `name` mis à jour

- GIVEN un vendor admin authentifié avec un body `{ logo: "https://..." }`
  WHEN il appelle PUT /vendors/me
  THEN un GET /vendors/me suivant retourne le vendor avec le nouveau `logo`

- GIVEN un body invalide (champ inconnu)
  WHEN il appelle PUT /vendors/me
  THEN la réponse est 400 Bad Request

- GIVEN une requête sans token d'authentification
  WHEN elle appelle PUT /vendors/me
  THEN la réponse est 401 Unauthorized

---

### 2. Gestion des Admins

#### 2.1 GET /vendors/admins — Lister les admins

**User Story**: En tant que vendor admin connecté, je veux lister tous les admins de mon vendor.

**Acceptance Criteria**:

- GIVEN un vendor admin authentifié
  WHEN il appelle GET /vendors/admins
  THEN la réponse contient `{ admins: VendorAdmin[] }` avec tous les admins du vendor

- GIVEN un vendor admin authentifié
  WHEN il appelle GET /vendors/admins
  THEN tous les admins retournés ont le même `vendor_id` que le vendor de l'admin connecté

#### 2.2 POST /vendors/admins — Créer un nouvel admin

**User Story**: En tant que vendor admin connecté, je veux pouvoir ajouter un nouvel admin à mon vendor.

**Acceptance Criteria**:

- GIVEN un vendor admin authentifié avec un body `{ email, password, first_name?, last_name? }`
  WHEN il appelle POST /vendors/admins
  THEN un nouvel admin est créé et associé au vendor de l'admin connecté

- GIVEN un body sans `email` ou sans `password`
  WHEN il appelle POST /vendors/admins
  THEN la réponse est 400 Bad Request

- GIVEN un email déjà utilisé par un autre admin
  WHEN il appelle POST /vendors/admins
  THEN la réponse est une erreur (conflit)

#### 2.3 PUT /vendors/admins/:id — Modifier un admin

**User Story**: En tant que vendor admin connecté, je veux modifier le prénom et/ou le nom d'un admin de mon vendor.

**Acceptance Criteria**:

- GIVEN un vendor admin authentifié avec un body `{ first_name?, last_name? }`
  WHEN il appelle PUT /vendors/admins/:id pour un admin de son vendor
  THEN l'admin est mis à jour et la réponse contient l'admin modifié

- GIVEN un vendor admin authentifié
  WHEN il appelle PUT /vendors/admins/:id pour un admin appartenant à un autre vendor
  THEN la réponse est 404 Not Found

- GIVEN un body invalide (champ inconnu)
  WHEN il appelle PUT /vendors/admins/:id
  THEN la réponse est 400 Bad Request

---

### 3. Gestion des Produits

#### 3.1 GET /vendors/products/:id — Détail d'un produit

**User Story**: En tant que vendor admin connecté, je veux consulter le détail d'un de mes produits.

**Acceptance Criteria**:

- GIVEN un vendor admin authentifié
  WHEN il appelle GET /vendors/products/:id pour un produit lié à son vendor
  THEN la réponse contient le produit avec ses variants

- GIVEN un vendor admin authentifié
  WHEN il appelle GET /vendors/products/:id pour un produit non lié à son vendor
  THEN la réponse est 404 Not Found

#### 3.2 PUT /vendors/products/:id — Modifier un produit

**User Story**: En tant que vendor admin connecté, je veux modifier un de mes produits.

**Acceptance Criteria**:

- GIVEN un vendor admin authentifié avec un body de mise à jour valide
  WHEN il appelle PUT /vendors/products/:id pour un produit de son vendor
  THEN le produit est mis à jour et la réponse contient le produit modifié

- GIVEN un vendor admin authentifié
  WHEN il appelle PUT /vendors/products/:id pour un produit non lié à son vendor
  THEN la réponse est 404 Not Found

#### 3.3 DELETE /vendors/products/:id — Supprimer un produit

**User Story**: En tant que vendor admin connecté, je veux supprimer un de mes produits.

**Acceptance Criteria**:

- GIVEN un vendor admin authentifié
  WHEN il appelle DELETE /vendors/products/:id pour un produit de son vendor
  THEN le produit est supprimé et la réponse indique le succès

- GIVEN un vendor admin authentifié
  WHEN il appelle DELETE /vendors/products/:id pour un produit non lié à son vendor
  THEN la réponse est 404 Not Found

---

### 4. Catégories

#### 4.1 GET /vendors/categories — Lister les catégories

**User Story**: En tant que vendor admin connecté, je veux lister toutes les catégories disponibles pour assigner mes produits.

**Acceptance Criteria**:

- GIVEN un vendor admin authentifié
  WHEN il appelle GET /vendors/categories
  THEN la réponse contient `{ categories: ProductCategory[] }` avec toutes les catégories actives

- GIVEN une requête sans token d'authentification
  WHEN elle appelle GET /vendors/categories
  THEN la réponse est 401 Unauthorized

#### 4.2 GET /vendors/categories/:id — Détail d'une catégorie

**User Story**: En tant que vendor admin connecté, je veux consulter le détail d'une catégorie.

**Acceptance Criteria**:

- GIVEN un vendor admin authentifié
  WHEN il appelle GET /vendors/categories/:id pour une catégorie existante
  THEN la réponse contient les détails de la catégorie

- GIVEN un vendor admin authentifié
  WHEN il appelle GET /vendors/categories/:id pour un id inexistant
  THEN la réponse est 404 Not Found

---

### 5. Commandes

#### 5.1 GET /vendors/orders/:id — Détail d'une commande

**User Story**: En tant que vendor admin connecté, je veux consulter le détail d'une commande de mon vendor.

**Acceptance Criteria**:

- GIVEN un vendor admin authentifié
  WHEN il appelle GET /vendors/orders/:id pour une commande liée à son vendor
  THEN la réponse contient la commande avec items, totaux, fulfillments et méthodes de paiement

- GIVEN un vendor admin authentifié
  WHEN il appelle GET /vendors/orders/:id pour une commande non liée à son vendor
  THEN la réponse est 404 Not Found

#### 5.2 POST /vendors/orders/:id/fulfill — Créer un fulfillment

**User Story**: En tant que vendor admin connecté, je veux créer un fulfillment pour une commande afin de marquer les articles comme expédiés.

**Acceptance Criteria**:

- GIVEN un vendor admin authentifié avec un body `{ location_id, items: [{ id, quantity }] }`
  WHEN il appelle POST /vendors/orders/:id/fulfill pour une commande de son vendor
  THEN un fulfillment est créé via `createOrderFulfillmentWorkflow` et la réponse contient la commande mise à jour

- GIVEN un vendor admin authentifié
  WHEN il appelle POST /vendors/orders/:id/fulfill pour une commande non liée à son vendor
  THEN la réponse est 404 Not Found

- GIVEN un body sans `location_id` ou sans `items`
  WHEN il appelle POST /vendors/orders/:id/fulfill
  THEN la réponse est 400 Bad Request

- GIVEN des items avec une quantité supérieure à la quantité commandée
  WHEN il appelle POST /vendors/orders/:id/fulfill
  THEN la réponse est une erreur métier Medusa

---

### 6. Middlewares et Sécurité

#### 6.1 Authentification sur toutes les nouvelles routes

**Acceptance Criteria**:

- GIVEN toutes les nouvelles routes listées dans ce document
  WHEN une requête est envoyée sans token valide
  THEN la réponse est 401 Unauthorized

- GIVEN le middleware existant `/vendors/*`
  WHEN une nouvelle route sous `/vendors/` est créée
  THEN elle est automatiquement protégée par `authenticate("vendor", ["session", "bearer"])`

#### 6.2 Validation des bodies

**Acceptance Criteria**:

- GIVEN un body avec des champs supplémentaires non définis dans le schéma zod (`.strict()`)
  WHEN il est envoyé sur une route POST/PUT
  THEN la réponse est 400 Bad Request

- GIVEN un body avec des types incorrects (ex: nombre à la place d'une string)
  WHEN il est envoyé sur une route POST/PUT
  THEN la réponse est 400 Bad Request
