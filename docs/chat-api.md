# Chat API — Documentation d'intégration

> Système de messagerie temps réel entre **clients** et **vendors**
> Socket.io pour le temps réel + REST pour l'historique
---

## 1. CONNEXION SOCKET.IO

```javascript
import { io } from "socket.io-client"

const socket = io("https://your-api.com", {
  path: "/socket.io",
  auth: { token: "eyJhbGciOiJIUzI1NiJ9..." },
  transports: ["websocket"]
})

socket.on("connect", () => console.log("Connecté"))
socket.on("connect_error", (err) => console.error(err.message))
// "Authentication required" — pas de token
// "Invalid token" — token expiré ou invalide
```

---

## 2. REST API

### 2.1 Créer/récupérer une conversation (Customer)

`POST /store/chat/conversations`
> Header: `Authorization: Bearer <customer_token>`

**Payload**
```json
{ "vendor_id": "vendor_01JXYZ888HHH" }
```

**Réponse 200**
```json
{
  "conversation": {
    "id": "conv_01JXYZ111AAA",
    "customer_id": "cus_01JXYZ123ABC",
    "vendor_id": "vendor_01JXYZ888HHH",
    "last_message_at": null,
    "created_at": "2026-04-18T10:00:00.000Z",
    "updated_at": "2026-04-18T10:00:00.000Z"
  }
}
```

---

### 2.2 Lister les conversations (Customer)

`GET /store/chat/conversations`

**Réponse 200**
```json
{
  "conversations": [
    {
      "id": "conv_01JXYZ111AAA",
      "customer_id": "cus_01JXYZ123ABC",
      "vendor_id": "vendor_01JXYZ888HHH",
      "last_message_at": "2026-04-18T10:30:00.000Z",
      "created_at": "2026-04-18T10:00:00.000Z"
    }
  ]
}
```

---

### 2.3 Historique des messages (Customer)

`GET /store/chat/conversations/:id/messages?limit=50&offset=0`

**Réponse 200**
```json
{
  "messages": [
    {
      "id": "msg_01JXYZ333CCC",
      "sender_type": "customer",
      "sender_id": "cus_01JXYZ123ABC",
      "content": "Bonjour, disponible en taille L ?",
      "type": "text",
      "file_url": null,
      "is_read": true,
      "created_at": "2026-04-18T10:05:00.000Z"
    },
    {
      "id": "msg_02JXYZ444DDD",
      "sender_type": "vendor",
      "sender_id": "vendor_01JXYZ888HHH",
      "content": "Oui, taille L disponible !",
      "type": "text",
      "file_url": null,
      "is_read": true,
      "created_at": "2026-04-18T10:10:00.000Z"
    },
    {
      "id": "msg_03JXYZ555EEE",
      "sender_type": "vendor",
      "sender_id": "vendor_01JXYZ888HHH",
      "content": "Voici une photo",
      "type": "image",
      "file_url": "https://cdn.example.com/photo.jpg",
      "is_read": false,
      "created_at": "2026-04-18T10:11:00.000Z"
    }
  ],
  "count": 3,
  "limit": 50,
  "offset": 0
}
```

**Erreur 404**
```json
{ "message": "Conversation not found" }
```

---

### 2.4 Conversations Vendor

`GET /vendors/chat/conversations`
> Header: `Authorization: Bearer <vendor_token>`

**Réponse 200** — même structure que 2.2

---

### 2.5 Messages Vendor

`GET /vendors/chat/conversations/:id/messages?limit=50&offset=0`

**Réponse 200** — même structure que 2.3

---

## 3. SOCKET.IO — ÉVÉNEMENTS

### 3.1 Rejoindre une conversation

```javascript
socket.emit("join_conversation", {
  conversation_id: "conv_01JXYZ111AAA"
})

// Confirmation reçue
socket.on("joined", (data) => {
  // { conversation_id: "conv_01JXYZ111AAA" }
})
```

---

### 3.2 Envoyer un message texte

```javascript
socket.emit("send_message", {
  conversation_id: "conv_01JXYZ111AAA",
  content: "Bonjour, disponible en taille L ?",
  type: "text"
})
```

---

### 3.3 Envoyer une image

```javascript
socket.emit("send_message", {
  conversation_id: "conv_01JXYZ111AAA",
  content: "Voici une photo du produit",
  type: "image",
  file_url: "https://cdn.example.com/photo.jpg"
})
```

> `file_url` est **obligatoire** pour `type: "image"` ou `type: "file"`

---

### 3.4 Recevoir un message

```javascript
socket.on("message_received", (data) => {
  console.log(data)
})
```

**Données reçues**
```json
{
  "conversation_id": "conv_01JXYZ111AAA",
  "message": {
    "id": "msg_04JXYZ666FFF",
    "sender_type": "customer",
    "sender_id": "cus_01JXYZ123ABC",
    "content": "Bonjour, disponible en taille L ?",
    "type": "text",
    "file_url": null,
    "is_read": false,
    "created_at": "2026-04-18T10:05:00.000Z"
  }
}
```

---

### 3.5 Notification push (preview)

```javascript
socket.on("push_notification", (data) => {
  showNotification(data.preview)
})
```

**Données reçues**
```json
{
  "conversation_id": "conv_01JXYZ111AAA",
  "sender_type": "customer",
  "preview": "Bonjour, disponible en taille L ?"
}
```

> `preview` = 50 premiers caractères du message

---

### 3.6 Marquer comme lu

```javascript
// Émettre
socket.emit("mark_read", {
  conversation_id: "conv_01JXYZ111AAA"
})

// Tous les membres reçoivent
socket.on("messages_read", (data) => {
  updateReadReceipts(data)
})
```

**Données `messages_read`**
```json
{
  "conversation_id": "conv_01JXYZ111AAA",
  "reader_type": "customer"
}
```

> `reader_type: "customer"` → messages du vendor marqués lus
> `reader_type: "vendor"` → messages du customer marqués lus

---

### 3.7 Indicateur de frappe

```javascript
// Émettre
socket.emit("typing", { conversation_id: "conv_01JXYZ111AAA" })
socket.emit("stop_typing", { conversation_id: "conv_01JXYZ111AAA" })

// Recevoir
socket.on("user_typing", (data) => showTypingDots())
socket.on("user_stop_typing", (data) => hideTypingDots())
```

**Données `user_typing`**
```json
{
  "conversation_id": "conv_01JXYZ111AAA",
  "actor_type": "vendor"
}
```

---

### 3.8 Erreurs Socket.io

```javascript
socket.on("error", (data) => console.error(data.message))
```

| Message | Cause |
|---|---|
| `Unauthorized` | Conversation non autorisée |
| `Conversation not found` | ID invalide |
| `file_url required for type image/file` | Fichier sans URL |
| `Failed to send message` | Erreur serveur |

---

## 4. FLUX COMPLET — CUSTOMER

```javascript
// 1. Connexion
const socket = io("https://your-api.com", {
  auth: { token: customerToken }
})

// 2. Créer/récupérer la conversation
const { conversation } = await fetch("/store/chat/conversations", {
  method: "POST",
  headers: { "Authorization": `Bearer ${customerToken}`, "Content-Type": "application/json" },
  body: JSON.stringify({ vendor_id: "vendor_01JXYZ888HHH" })
}).then(r => r.json())

// 3. Charger l'historique
const { messages } = await fetch(
  `/store/chat/conversations/${conversation.id}/messages?limit=50`,
  { headers: { "Authorization": `Bearer ${customerToken}` } }
).then(r => r.json())

// 4. Rejoindre la room
socket.emit("join_conversation", { conversation_id: conversation.id })

// 5. Écouter les événements
socket.on("message_received", ({ message }) => appendMessage(message))
socket.on("user_typing", () => showTypingDots())
socket.on("user_stop_typing", () => hideTypingDots())
socket.on("messages_read", ({ reader_type }) => {
  if (reader_type === "vendor") markSentMessagesAsRead()
})

// 6. Envoyer un message
function sendMessage(content) {
  socket.emit("send_message", {
    conversation_id: conversation.id,
    content,
    type: "text"
  })
}

// 7. Indicateur de frappe avec debounce
let typingTimer
inputField.addEventListener("input", () => {
  socket.emit("typing", { conversation_id: conversation.id })
  clearTimeout(typingTimer)
  typingTimer = setTimeout(() => {
    socket.emit("stop_typing", { conversation_id: conversation.id })
  }, 1500)
})

// 8. Marquer comme lu à l'ouverture
socket.emit("mark_read", { conversation_id: conversation.id })
```

---

## 5. FLUX COMPLET — VENDOR

```javascript
// 1. Connexion
const socket = io("https://your-api.com", {
  auth: { token: vendorToken }
})

// 2. Lister les conversations
const { conversations } = await fetch("/vendors/chat/conversations", {
  headers: { "Authorization": `Bearer ${vendorToken}` }
}).then(r => r.json())

// 3. Rejoindre toutes les rooms
conversations.forEach(conv => {
  socket.emit("join_conversation", { conversation_id: conv.id })
})

// 4. Recevoir les messages
socket.on("message_received", ({ conversation_id, message }) => {
  updateConversationList(conversation_id, message)
  if (activeConversation === conversation_id) {
    appendMessage(message)
    socket.emit("mark_read", { conversation_id })
  }
})

// 5. Notifications pour les conversations non ouvertes
socket.on("push_notification", ({ conversation_id, preview }) => {
  showBadge(conversation_id)
  showSystemNotification(preview)
})
```

---

## 6. TABLEAU RÉCAPITULATIF

### Émettre (client → serveur)

| Événement | Payload obligatoire | Payload optionnel |
|---|---|---|
| `join_conversation` | `conversation_id` | — |
| `send_message` | `conversation_id`, `content`, `type` | `file_url` (requis si image/file) |
| `mark_read` | `conversation_id` | — |
| `typing` | `conversation_id` | — |
| `stop_typing` | `conversation_id` | — |

### Écouter (serveur → client)

| Événement | Données clés | Description |
|---|---|---|
| `joined` | `conversation_id` | Confirmation join |
| `message_received` | `conversation_id`, `message` | Nouveau message |
| `push_notification` | `conversation_id`, `sender_type`, `preview` | Notification |
| `messages_read` | `conversation_id`, `reader_type` | Messages lus |
| `user_typing` | `conversation_id`, `actor_type` | Frappe en cours |
| `user_stop_typing` | `conversation_id` | Frappe arrêtée |
| `error` | `message` | Erreur |

---

## 7. TYPES DE MESSAGES

| `type` | Description | `file_url` |
|---|---|---|
| `text` | Texte simple | Non requis |
| `image` | Image (JPEG, PNG, WebP) | **Obligatoire** |
| `file` | Fichier (PDF, DOC...) | **Obligatoire** |

> Upload des fichiers : gérer séparément (S3, Cloudinary, etc.)
> Uploader le fichier → récupérer l'URL → envoyer le message avec `file_url`
