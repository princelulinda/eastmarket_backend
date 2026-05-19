# Requirements Document — Short Videos

## Introduction

Le module Short Videos permet aux vendors du marketplace Medusa v2 de publier des vidéos courtes style TikTok liées à leurs produits. Les customers accèdent à un feed vertical paginé, peuvent interagir (like, commentaire, partage, sauvegarde) et ajouter les produits présentés directement au panier.

## Glossaire

- **ShortVideoService** : service du module `short-video`, étend `MedusaService`
- **Vendor** : vendeur authentifié via `actor_type = "vendor"`
- **Customer** : acheteur authentifié via `actor_type = "customer"`
- **Feed** : liste paginée de vidéos publiées, triée par date décroissante
- **VideoLike** : enregistrement d'un like d'un customer sur une vidéo
- **VideoSave** : enregistrement d'une sauvegarde d'un customer sur une vidéo
- **VideoComment** : commentaire d'un customer sur une vidéo
- **API** : couche HTTP Medusa (routes + middlewares)

---

## Requirements

### Requirement 1 : Gestion des vidéos par le vendor

**User Story :** En tant que vendor, je veux publier et gérer mes vidéos courtes, afin de promouvoir mes produits auprès des customers.

#### Acceptance Criteria

1. WHEN a vendor submits valid video data (title, video_url), THE ShortVideoService SHALL create a ShortVideo record with status "draft"
2. IF a vendor submits video data without a required field (title or video_url), THEN THE API SHALL return a 400 validation error
3. WHEN a vendor requests their video list, THE ShortVideoService SHALL return only ShortVideo records where vendor_id matches that vendor
4. WHEN a vendor updates a video, THE ShortVideoService SHALL persist the provided fields and leave other fields unchanged
5. WHEN a vendor deletes a video, THE ShortVideoService SHALL soft-delete the ShortVideo record and exclude it from all subsequent feed and vendor list queries
6. IF a vendor attempts to update or delete a video belonging to another vendor, THEN THE API SHALL return a 403 error

### Requirement 2 : Feed public de vidéos

**User Story :** En tant que customer, je veux consulter un feed de vidéos courtes, afin de découvrir des produits proposés par les vendors.

#### Acceptance Criteria

1. WHEN the store feed endpoint is called, THE ShortVideoService SHALL return only ShortVideo records with status "published"
2. THE ShortVideoService SHALL return feed results ordered by created_at descending
3. THE API SHALL support limit and offset query parameters for feed pagination
4. WHEN a video detail is requested by id, THE ShortVideoService SHALL return the ShortVideo record with all its fields

### Requirement 3 : Likes

**User Story :** En tant que customer, je veux liker des vidéos, afin d'exprimer mon intérêt pour un produit.

#### Acceptance Criteria

1. WHEN a customer likes a video they have not yet liked, THE ShortVideoService SHALL create a VideoLike record and increment the video's likes_count by 1
2. WHEN a customer likes a video they have already liked, THE ShortVideoService SHALL delete the VideoLike record and decrement the video's likes_count by 1
3. IF a like or unlike request is made without customer authentication, THEN THE API SHALL return a 401 error

### Requirement 4 : Sauvegardes

**User Story :** En tant que customer, je veux sauvegarder des vidéos, afin de les retrouver facilement plus tard.

#### Acceptance Criteria

1. WHEN a customer saves a video they have not yet saved, THE ShortVideoService SHALL create a VideoSave record
2. WHEN a customer saves a video they have already saved, THE ShortVideoService SHALL delete the VideoSave record
3. WHEN a customer requests their saved videos, THE ShortVideoService SHALL return exactly the ShortVideo records for which a VideoSave record exists for that customer
4. IF a save request is made without customer authentication, THEN THE API SHALL return a 401 error

### Requirement 5 : Commentaires

**User Story :** En tant que customer, je veux commenter des vidéos, afin d'interagir avec les vendors et les autres customers.

#### Acceptance Criteria

1. WHEN a customer adds a comment with non-empty content, THE ShortVideoService SHALL create a VideoComment record and increment the video's comments_count by 1
2. WHEN comments are requested for a video, THE ShortVideoService SHALL return only VideoComment records where video_id matches that video, ordered by created_at descending
3. THE API SHALL support limit and offset query parameters for comment pagination
4. IF a comment request is made without customer authentication, THEN THE API SHALL return a 401 error

### Requirement 6 : Vues et partages

**User Story :** En tant que vendor, je veux suivre les vues et partages de mes vidéos, afin de mesurer leur performance.

#### Acceptance Criteria

1. WHEN a view is recorded for a video, THE ShortVideoService SHALL increment the video's views_count by 1
2. WHEN a share is recorded for a video, THE ShortVideoService SHALL increment the video's shares_count by 1

### Requirement 7 : Sécurité et authentification

**User Story :** En tant qu'administrateur, je veux que les routes sensibles soient protégées, afin d'éviter les accès non autorisés.

#### Acceptance Criteria

1. IF a vendor route is accessed without a valid vendor session or bearer token, THEN THE API SHALL return a 401 error
2. IF a store interaction route (like, save, comment, view) is accessed without a valid customer session or bearer token, THEN THE API SHALL return a 401 error
3. THE store feed endpoint (GET /store/videos) SHALL be accessible without authentication
