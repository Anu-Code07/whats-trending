# Pulse — API Specification (MVP)

Base URL: `/api/v1`

Auth: Bearer JWT (MVP uses mock auth header `X-User-Id` for development).

---

## Feed

### `GET /feed`
Personalized home feed.

**Query:** `cursor`, `limit` (default 20)

**Response:**
```json
{
  "greeting": "Good evening",
  "sinceLastChecked": {
    "count": 7,
    "stories": ["uuid", ...]
  },
  "items": [
    {
      "id": "uuid",
      "title": "React announces a major update",
      "summary": "...",
      "whyItMatters": "...",
      "category": "Programming",
      "sourceCount": 24,
      "relevanceScore": 0.96,
      "relevanceExplanation": "You frequently read React and frontend performance stories.",
      "impact": "high",
      "publishedAt": "2026-09-14T08:00:00Z",
      "primarySource": { "name": "React Blog", "url": "..." },
      "isSaved": false
    }
  ],
  "nextCursor": "..."
}
```

### `GET /feed/since-last-checked`
Stories since user's `lastActiveAt`.

### `GET /feed/brief`
Today's personalized daily brief.

---

## Stories

### `GET /stories/:id`
Full story detail with sources, timeline, community signal.

**Query:** `depth` = `quick` | `normal` | `deep`

### `POST /stories/:id/save`
**Body:** `{ "collection": "read_later" }`

### `DELETE /stories/:id/save`

### `POST /stories/:id/interactions`
**Body:** `{ "type": "opened", "durationMs": 45000 }`

### `POST /stories/:id/build-ideas`
Generate project ideas (clearly labeled as AI-generated).

---

## Search

### `GET /search`
**Query:** `q`, `type` (stories|companies|technologies|all)

Semantic search over indexed content.

---

## Discover

### `GET /discover/trending`
### `GET /discover/rising`
### `GET /discover/technologies`
### `GET /discover/companies`
### `GET /discover/research`
### `GET /discover/startups`

---

## Entities

### `GET /companies/:slug`
### `GET /technologies/:slug`

---

## Trends

### `GET /trends`
Trend radar data (only real measured metrics).

### `GET /trends/:slug`

---

## User / Profile

### `GET /me`
Profile + Tech DNA.

### `PATCH /me`
Update preferences (contentDepth, notificationFrequency, careerMode).

### `GET /me/interests`
### `PUT /me/interests`
Onboarding / interest management.

### `POST /me/interests/:id/follow`
### `POST /me/interests/:id/mute`
### `DELETE /me/personalization`
Reset learned personalization.

### `GET /me/saved`
Saved stories by collection.

---

## Notifications

### `GET /notifications`
### `PATCH /notifications/:id/read`

---

## WebSocket (Future)

`ws://.../feed/live` — real-time breaking story pushes.
