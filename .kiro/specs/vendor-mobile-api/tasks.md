# Tasks: Vendor Mobile API

## Task List

- [x] 1. Middlewares — ajouter les nouvelles routes dans `src/api/middlewares.ts`
  - [x] 1.1 Exporter les schémas zod des nouvelles routes (PutVendorMeSchema, PostVendorAdminSchema, PutVendorAdminSchema, PostFulfillOrderSchema)
  - [x] 1.2 Ajouter les entrées middleware pour PUT /vendors/me, GET /vendors/admins, POST /vendors/admins, PUT /vendors/admins/:id
  - [x] 1.3 Ajouter les entrées middleware pour GET/PUT/DELETE /vendors/products/:id
  - [x] 1.4 Ajouter les entrées middleware pour GET /vendors/categories, GET /vendors/categories/:id
  - [x] 1.5 Ajouter les entrées middleware pour GET /vendors/orders/:id, POST /vendors/orders/:id/fulfill

- [x] 2. Profil Vendor — `src/api/vendors/me/route.ts`
  - [x] 2.1 Créer le workflow `update-vendor` dans `src/workflows/marketplace/update-vendor/`
  - [x] 2.2 Implémenter GET /vendors/me (query.graph vendor_admin → vendor + admins)
  - [x] 2.3 Implémenter PUT /vendors/me (updateVendors via marketplace module)

- [x] 3. Gestion Admins — `src/api/vendors/admins/`
  - [x] 3.1 Créer le workflow `create-vendor-admin` dans `src/workflows/marketplace/create-vendor-admin/`
  - [x] 3.2 Créer le workflow `update-vendor-admin` dans `src/workflows/marketplace/update-vendor-admin/`
  - [x] 3.3 Implémenter GET /vendors/admins dans `src/api/vendors/admins/route.ts`
  - [x] 3.4 Implémenter POST /vendors/admins dans `src/api/vendors/admins/route.ts`
  - [x] 3.5 Implémenter PUT /vendors/admins/:id dans `src/api/vendors/admins/[id]/route.ts` (étendre le fichier existant)

- [x] 4. Produits — `src/api/vendors/products/[id]/route.ts`
  - [x] 4.1 Implémenter GET /vendors/products/:id (vérification ownership + query.graph)
  - [x] 4.2 Implémenter PUT /vendors/products/:id (vérification ownership + updateProductsWorkflow)
  - [x] 4.3 Implémenter DELETE /vendors/products/:id (vérification ownership + deleteProductsWorkflow)

- [x] 5. Catégories — `src/api/vendors/categories/`
  - [x] 5.1 Implémenter GET /vendors/categories dans `src/api/vendors/categories/route.ts`
  - [x] 5.2 Implémenter GET /vendors/categories/:id dans `src/api/vendors/categories/[id]/route.ts`

- [x] 6. Commandes — `src/api/vendors/orders/[id]/`
  - [x] 6.1 Implémenter GET /vendors/orders/:id dans `src/api/vendors/orders/[id]/route.ts`
  - [x] 6.2 Implémenter POST /vendors/orders/:id/fulfill dans `src/api/vendors/orders/[id]/fulfill/route.ts`
