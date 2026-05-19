# Tasks: Realtime Chat

## Task List

- [x] 1. Installation de socket.io
  - [x] 1.1 Installer le package `socket.io` via npm : `npm install socket.io`
  - [x] 1.2 Installer les types `@types/socket.io` si nécessaire (socket.io v4 inclut ses propres types)

- [-] 2. Module Chat — Modèles et migration
  - [x] 2.1 Créer `src/modules/chat/models/conversation.ts` — modèle MikroORM avec `id`, `customer_id`, `vendor_id`, `last_message_at`, relation `hasMany` vers Message
  - [x] 2.2 Créer `src/modules/chat/models/message.ts` — modèle MikroORM avec `id`, `conversation_id`, `sender_type` (enum customer/vendor), `sender_id`, `content`, `type` (enum text/image/file), `file_url`, `is_read`, relation `belongsTo` vers Conversation
  - [x] 2.3 Créer `src/modules/chat/migrations/Migration_chat_init.ts` — tables `conversation` et `message`, contrainte d'unicité `(customer_id, vendor_id)`, index sur `(customer_id, vendor_id)`, `(conversation_id, created_at)`, `(conversation_id, is_read)`
  - [x] 2.4 Créer `src/modules/chat/service.ts` — `ChatModuleService extends MedusaService({ Conversation, Message })` avec les méthodes : `findOrCreateConversation`, `listConversations`, `retrieveConversation`, `createMessage` (avec validation `file_url`), `listMessages`, `markMessagesAsRead`
  - [x] 2.5 Créer `src/modules/chat/index.ts` — export `CHAT_MODULE = "chat"` et `Module(CHAT_MODULE, { service: ChatModuleService })`

- [ ] 3. Enregistrement du module dans medusa-config.ts
  - [x] 3.1 Ajouter `{ resolve: "./src/modules/chat" }` dans le tableau `modules` de `medusa-config.ts`

- [ ] 4. Loader Socket.io
  - [x] 4.1 Créer `src/loaders/socket.ts` — export default async function qui récupère le `httpServer` depuis le container Medusa et instancie `new Server(httpServer, { cors: { origin: process.env.STORE_CORS } })`
  - [x] 4.2 Implémenter le middleware d'authentification JWT dans le loader : tenter de vérifier le token comme "customer" puis comme "vendor", définir `socket.data.actor_id` et `socket.data.actor_type`, rejeter si invalide
  - [x] 4.3 Implémenter le handler `join_conversation` : ajouter le socket à la room `conversation:{id}`
  - [x] 4.4 Implémenter le handler `send_message` : valider les données, vérifier l'appartenance à la conversation, appeler `chatService.createMessage`, broadcaster `message_received` et `push_notification` (preview 50 chars) à la room
  - [x] 4.5 Implémenter le handler `mark_read` : appeler `chatService.markMessagesAsRead`, broadcaster `messages_read` à la room
  - [x] 4.6 Implémenter les handlers `typing` et `stop_typing` : broadcaster `user_typing` / `user_stop_typing` aux autres sockets de la room

- [ ] 5. Routes REST Store — Customer
  - [x] 5.1 Créer `src/api/store/chat/conversations/route.ts` — `GET` liste les conversations du customer (via `chatService.listConversations({ customer_id })`), `POST` appelle `findOrCreateConversation({ vendor_id })`
  - [x] 5.2 Créer `src/api/store/chat/conversations/[id]/messages/route.ts` — `GET` retourne les messages paginés (`limit`, `offset`), HTTP 404 si conversation inexistante

- [ ] 6. Routes REST Vendors — Vendor
  - [x] 6.1 Créer `src/api/vendors/chat/conversations/route.ts` — `GET` liste les conversations du vendor (via `chatService.listConversations({ vendor_id })`)
  - [x] 6.2 Créer `src/api/vendors/chat/conversations/[id]/messages/route.ts` — `GET` retourne les messages paginés (`limit`, `offset`), HTTP 404 si conversation inexistante

- [ ] 7. Mise à jour middlewares.ts
  - [x] 7.1 Ajouter l'entrée middleware pour `GET /store/chat/conversations` avec `authenticate("customer", ["session", "bearer"])`
  - [x] 7.2 Ajouter l'entrée middleware pour `POST /store/chat/conversations` avec `authenticate("customer", ["session", "bearer"])`
  - [x] 7.3 Ajouter l'entrée middleware pour `GET /store/chat/conversations/*` avec `authenticate("customer", ["session", "bearer"])`
