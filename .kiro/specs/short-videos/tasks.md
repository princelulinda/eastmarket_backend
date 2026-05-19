# Tasks — Short Videos

## Task List

- [x] 1. Module short-video
  - [x] 1.1 Corriger et compléter service.ts (ShortVideoService)
  - [x] 1.2 Créer src/modules/short-video/index.ts
  - [x] 1.3 Enregistrer le module dans medusa-config.ts

- [x] 2. Routes vendor (CRUD vidéos)
  - [x] 2.1 POST /vendors/videos — créer une vidéo
  - [x] 2.2 GET /vendors/videos — lister ses vidéos
  - [x] 2.3 GET /vendors/videos/:id — détail d'une vidéo
  - [x] 2.4 PUT /vendors/videos/:id — modifier une vidéo
  - [x] 2.5 DELETE /vendors/videos/:id — supprimer une vidéo

- [x] 3. Routes store (feed + interactions)
  - [x] 3.1 GET /store/videos — feed public paginé
  - [x] 3.2 GET /store/videos/saved — vidéos sauvegardées
  - [x] 3.3 GET /store/videos/:id — détail d'une vidéo
  - [x] 3.4 POST /store/videos/:id/like — toggle like
  - [x] 3.5 POST /store/videos/:id/save — toggle save
  - [x] 3.6 POST /store/videos/:id/view — incrémenter vues
  - [x] 3.7 POST /store/videos/:id/share — incrémenter partages
  - [x] 3.8 GET /store/videos/:id/comments — commentaires paginés
  - [x] 3.9 POST /store/videos/:id/comments — ajouter un commentaire

- [x] 4. Middlewares
  - [x] 4.1 Ajouter les middlewares d'auth pour /vendors/videos/*
  - [x] 4.2 Ajouter les middlewares d'auth pour /store/videos/* (interactions)
  - [x] 4.3 Ajouter la validation zod pour les routes POST/PUT

- [x] 5. Vérification TypeScript
  - [x] 5.1 Vérifier les diagnostics TypeScript sur tous les fichiers créés
