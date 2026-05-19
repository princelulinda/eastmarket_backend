# Requirements Document

## Introduction

Système de messagerie temps réel 1-to-1 entre un `customer` (acheteur) et un `vendor` (vendeur), intégré nativement dans Medusa v2 via un module custom `chat`. Le système repose sur Socket.io pour la communication temps réel, MikroORM pour la persistance, et des routes REST pour l'historique. Il s'inspire du chat professionnel Alibaba Trade : conversations persistantes, statut lu/non lu, envoi de fichiers, indicateur de frappe, et notifications push.

## Glossary

- **Chat_Module**: Module Medusa custom `src/modules/chat` gérant la persistance des conversations et messages
- **ChatModuleService**: Service MedusaService exposant le CRUD Conversation et Message
- **Socket_Server**: Serveur Socket.io attaché au serveur HTTP Medusa via un loader
- **Conversation**: Entité représentant un fil de discussion unique entre un customer et un vendor
- **Message**: Entité représentant un message individuel dans une Conversation
- **Customer**: Acheteur authentifié via JWT Medusa (actor_type = "customer")
- **Vendor**: Vendeur authentifié via JWT Medusa (actor_type = "vendor")
- **REST_API**: Routes HTTP Medusa exposant l'historique et la création de conversations
- **Loader**: Fichier `src/loaders/socket.ts` initialisé automatiquement au démarrage Medusa

## Requirements

### Requirement 1: Module Chat — Persistance des données

**User Story:** As a developer, I want a dedicated chat module with MikroORM models, so that conversations and messages are persisted in PostgreSQL with proper indexing.

#### Acceptance Criteria

1. THE Chat_Module SHALL définir un modèle `Conversation` avec les champs `id`, `customer_id`, `vendor_id`, `last_message_at`
2. THE Chat_Module SHALL définir un modèle `Message` avec les champs `id`, `conversation_id`, `sender_type`, `sender_id`, `content`, `type`, `file_url`, `is_read`
3. THE Chat_Module SHALL appliquer une contrainte d'unicité sur la paire `(customer_id, vendor_id)` dans la table `conversation`
4. THE Chat_Module SHALL créer un index sur `(customer_id, vendor_id)` pour optimiser `findOrCreateConversation`
5. THE Chat_Module SHALL créer un index sur `(conversation_id, created_at)` pour optimiser la pagination de l'historique
6. THE Chat_Module SHALL créer un index sur `(conversation_id, is_read)` pour optimiser `markMessagesAsRead`
7. THE Chat_Module SHALL être enregistré dans `medusa-config.ts` avec la résolution `./src/modules/chat`

### Requirement 2: ChatModuleService — Logique métier

**User Story:** As a developer, I want a service layer for chat operations, so that business logic is centralized and reusable across REST routes and Socket.io handlers.

#### Acceptance Criteria

1. WHEN `findOrCreateConversation(customerId, vendorId)` est appelé, THE ChatModuleService SHALL retourner la conversation existante si elle existe déjà pour cette paire
2. WHEN `findOrCreateConversation(customerId, vendorId)` est appelé et qu'aucune conversation n'existe, THE ChatModuleService SHALL créer et retourner une nouvelle conversation
3. WHEN `createMessage(data)` est appelé avec `type = "image"` ou `type = "file"` et sans `file_url`, THE ChatModuleService SHALL rejeter la création avec une erreur descriptive
4. WHEN `markMessagesAsRead(conversationId, readerType)` est appelé avec `readerType = "customer"`, THE ChatModuleService SHALL mettre à jour uniquement les messages dont `sender_type = "vendor"`
5. WHEN `markMessagesAsRead(conversationId, readerType)` est appelé avec `readerType = "vendor"`, THE ChatModuleService SHALL mettre à jour uniquement les messages dont `sender_type = "customer"`
6. WHEN `listMessages(conversationId, options)` est appelé, THE ChatModuleService SHALL retourner les messages paginés selon `limit` et `offset`
7. THE ChatModuleService SHALL mettre à jour `last_message_at` sur la Conversation à chaque appel à `createMessage`

### Requirement 3: Loader Socket.io — Initialisation

**User Story:** As a developer, I want Socket.io to be initialized via a Medusa loader, so that the WebSocket server shares the same HTTP port as the REST API.

#### Acceptance Criteria

1. WHEN Medusa démarre, THE Loader SHALL attacher le Socket_Server au serveur HTTP Medusa existant
2. WHEN un client se connecte au Socket_Server sans token JWT, THE Socket_Server SHALL rejeter la connexion avec l'erreur "Authentication required"
3. WHEN un client se connecte avec un token JWT valide de type "customer", THE Socket_Server SHALL authentifier la connexion et définir `socket.data.actor_type = "customer"`
4. WHEN un client se connecte avec un token JWT valide de type "vendor", THE Socket_Server SHALL authentifier la connexion et définir `socket.data.actor_type = "vendor"`
5. IF le token JWT est invalide ou expiré, THEN THE Socket_Server SHALL rejeter la connexion avec l'erreur "Invalid token"
6. THE Socket_Server SHALL configurer CORS depuis `process.env.STORE_CORS`

### Requirement 4: Socket.io — Gestion des rooms et messages

**User Story:** As a customer or vendor, I want to join a conversation room and exchange messages in real time, so that I can communicate instantly without polling.

#### Acceptance Criteria

1. WHEN un socket authentifié émet `join_conversation { conversation_id }`, THE Socket_Server SHALL ajouter le socket à la room `conversation:{id}`
2. WHEN un socket authentifié émet `send_message` avec un `conversation_id` valide et un contenu valide, THE Socket_Server SHALL persister le message via ChatModuleService
3. WHEN un message est persisté, THE Socket_Server SHALL broadcaster `message_received` à tous les sockets de la room `conversation:{id}`
4. WHEN un message est persisté, THE Socket_Server SHALL broadcaster `push_notification` avec les 50 premiers caractères du contenu à tous les sockets de la room
5. IF un socket émet `send_message` pour une conversation dont il n'est pas membre, THEN THE Socket_Server SHALL émettre `error { message: "Unauthorized" }` au socket émetteur uniquement
6. IF un socket émet `send_message` avec `type = "image"` ou `type = "file"` sans `file_url`, THEN THE Socket_Server SHALL émettre `error { message: "file_url required for type image/file" }`

### Requirement 5: Socket.io — Indicateur de frappe et statut lu

**User Story:** As a customer or vendor, I want to see when the other party is typing and when my messages have been read, so that I have a richer chat experience.

#### Acceptance Criteria

1. WHEN un socket authentifié émet `typing { conversation_id }`, THE Socket_Server SHALL broadcaster `user_typing { conversation_id, actor_type }` aux autres sockets de la room
2. WHEN un socket authentifié émet `stop_typing { conversation_id }`, THE Socket_Server SHALL broadcaster `user_stop_typing { conversation_id }` aux autres sockets de la room
3. WHEN un socket authentifié émet `mark_read { conversation_id }`, THE Socket_Server SHALL appeler `markMessagesAsRead` via ChatModuleService
4. WHEN `markMessagesAsRead` est complété, THE Socket_Server SHALL broadcaster `messages_read { conversation_id }` à tous les sockets de la room

### Requirement 6: REST API — Routes Store (Customer)

**User Story:** As a customer, I want REST endpoints to manage my conversations and retrieve message history, so that I can load past messages when opening the chat.

#### Acceptance Criteria

1. WHEN un customer authentifié envoie `GET /store/chat/conversations`, THE REST_API SHALL retourner la liste des conversations du customer avec HTTP 200
2. WHEN un customer authentifié envoie `POST /store/chat/conversations { vendor_id }`, THE REST_API SHALL appeler `findOrCreateConversation` et retourner la conversation avec HTTP 200
3. WHEN un customer authentifié envoie `GET /store/chat/conversations/:id/messages`, THE REST_API SHALL retourner les messages paginés avec `{ messages, count }` et HTTP 200
4. IF un customer envoie `GET /store/chat/conversations/:id/messages` avec un `id` inexistant, THEN THE REST_API SHALL retourner HTTP 404 avec `{ message: "Conversation not found" }`
5. THE REST_API SHALL exiger une authentification customer (bearer/session) pour toutes les routes `/store/chat/*`

### Requirement 7: REST API — Routes Vendor

**User Story:** As a vendor, I want REST endpoints to list my conversations and retrieve message history, so that I can manage customer inquiries efficiently.

#### Acceptance Criteria

1. WHEN un vendor authentifié envoie `GET /vendors/chat/conversations`, THE REST_API SHALL retourner la liste des conversations du vendor avec HTTP 200
2. WHEN un vendor authentifié envoie `GET /vendors/chat/conversations/:id/messages`, THE REST_API SHALL retourner les messages paginés avec `{ messages, count }` et HTTP 200
3. IF un vendor envoie `GET /vendors/chat/conversations/:id/messages` avec un `id` inexistant, THEN THE REST_API SHALL retourner HTTP 404 avec `{ message: "Conversation not found" }`
4. THE REST_API SHALL exiger une authentification vendor (bearer/session) pour toutes les routes `/vendors/chat/*` via le middleware existant `/vendors/*`
