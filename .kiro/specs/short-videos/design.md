# Design Document: Short Videos (TikTok-style pour vendeurs)

## Overview

Fonctionnalité de short videos style TikTok permettant aux vendeurs du marketplace Medusa v2 de publier des vidéos courtes liées à leurs produits. Les customers peuvent consulter un feed vertical paginé, interagir (like, commentaire, partage, sauvegarde) et accéder directement aux produits présentés dans chaque vidéo.

Le module `short-video` est autonome et suit les mêmes patterns que les modules `chat` et `marketplace` existants : `model.define()`, `MedusaService`, `Module()`, migration SQL explicite.

---

## Architecture

### Module `short-video`

```
src/modules/short-video/
  models/
    short-video.ts       — ShortVideo (vidéo + compteurs dénormalisés)
    video-like.ts        — VideoLike (customer ↔ video)
    video-comment.ts     — VideoComment (customer ↔ video)
    video-save.ts        — VideoSave (customer ↔ video)
  migrations/
    Migration20260418200000.ts
  service.ts             — ShortVideoService extends MedusaService
  index.ts               — Module("short-video", ...)
```

### Routes API

```
src/api/
  vendors/videos/
    route.ts             — GET (list), POST (create)
    [id]/route.ts        — GET (detail), PUT (update), DELETE (delete)
  store/videos/
    route.ts             — GET (feed public)
    saved/route.ts       — GET (vidéos sauvegardées)
    [id]/
      route.ts           — GET (detail)
      like/route.ts      — POST (toggle like)
      save/route.ts      — POST (toggle save)
      view/route.ts      — POST (incrémenter vues)
      share/route.ts     — POST (incrémenter partages)
      comments/route.ts  — GET (liste), POST (ajouter)
```

---

## Data Models

### ShortVideo

| Champ | Type | Notes |
|---|---|---|
| id | text PK | ULID auto |
| vendor_id | text | référence externe vers Vendor |
| title | text | description affichée sur la carte |
| description | text nullable | description longue |
| video_url | text | URL CDN (HLS ou MP4) |
| thumbnail_url | text nullable | preview image |
| duration | integer nullable | durée en secondes |
| tag | text nullable | catégorie affichée sur la carte |
| status | enum | draft / published / archived |
| likes_count | integer | compteur dénormalisé |
| comments_count | integer | compteur dénormalisé |
| shares_count | integer | compteur dénormalisé |
| views_count | integer | compteur dénormalisé |
| product_ids | jsonb nullable | tableau d'IDs produits liés |

**Index :**
- `(vendor_id, status)` — vidéos d'un vendor
- `(status, created_at DESC)` — feed chronologique

### VideoLike

| Champ | Type | Notes |
|---|---|---|
| id | text PK | |
| video_id | text | FK vers short_video |
| customer_id | text | référence externe |

**Index unique :** `(video_id, customer_id)` — un seul like par customer

### VideoComment

| Champ | Type | Notes |
|---|---|---|
| id | text PK | |
| video_id | text | FK vers short_video |
| customer_id | text | référence externe |
| content | text | contenu du commentaire |

**Index :** `(video_id, created_at DESC)` — commentaires paginés

### VideoSave

| Champ | Type | Notes |
|---|---|---|
| id | text PK | |
| video_id | text | FK vers short_video |
| customer_id | text | référence externe |

**Index unique :** `(video_id, customer_id)` — une seule sauvegarde par customer

---

## Service Design

`ShortVideoService` étend `MedusaService({ ShortVideo, VideoLike, VideoComment, VideoSave })`.

Méthodes métier :

| Méthode | Description |
|---|---|
| `createVideo(input)` | Crée une vidéo en statut draft |
| `updateVideo(id, update)` | Met à jour les champs d'une vidéo |
| `publishVideo(id)` | Passe le statut à published |
| `getFeed(limit, offset)` | Liste les vidéos published, tri created_at DESC |
| `getVendorVideos(vendorId)` | Liste toutes les vidéos d'un vendor |
| `toggleLike(videoId, customerId)` | Toggle like + met à jour likes_count |
| `toggleSave(videoId, customerId)` | Toggle save |
| `addComment(videoId, customerId, content)` | Crée un commentaire + incrémente comments_count |
| `getComments(videoId, limit, offset)` | Liste les commentaires paginés |
| `incrementView(videoId)` | Incrémente views_count |
| `incrementShare(videoId)` | Incrémente shares_count |
| `isLikedBy(videoId, customerId)` | Vérifie si le customer a liké |
| `isSavedBy(videoId, customerId)` | Vérifie si le customer a sauvegardé |
| `getSavedVideos(customerId)` | Liste les vidéos sauvegardées par un customer |

---

## Performance

- **Compteurs dénormalisés** : `likes_count`, `views_count`, `comments_count`, `shares_count` stockés directement sur `ShortVideo` → pas de `COUNT()` à chaque requête de feed.
- **Pagination offset** : le feed utilise `limit/offset` pour la simplicité. Pour des millions de vidéos, une pagination cursor-based sur `(status, created_at, id)` serait préférable.
- **Index composites** : `(status, created_at DESC)` pour le feed, `(vendor_id, status)` pour les vidéos d'un vendor.

---

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system — essentially, a formal statement about what the system should do.*

### Property 1: Toggle like idempotence

*For any* video and customer, toggling like twice should return the video to its original liked state and the likes_count should be unchanged.

**Validates: Requirements 3.1, 3.2**

### Property 2: Toggle save idempotence

*For any* video and customer, toggling save twice should return the video to its original saved state (no VideoSave record).

**Validates: Requirements 4.1, 4.2**

### Property 3: Feed ne contient que des vidéos publiées

*For any* call to `getFeed`, all returned videos should have `status = "published"`.

**Validates: Requirements 2.1**

### Property 4: Vidéos sauvegardées cohérentes

*For any* customer, the list returned by `getSavedVideos` should contain exactly the videos for which a VideoSave record exists for that customer.

**Validates: Requirements 4.3**

### Property 5: Isolation des vidéos par vendor

*For any* vendor, `getVendorVideos` should return only ShortVideo records where `vendor_id` matches that vendor.

**Validates: Requirements 1.3**

### Property 6: Commentaires isolés par vidéo

*For any* video, `getComments` should return only VideoComment records where `video_id` matches that video.

**Validates: Requirements 5.2**
