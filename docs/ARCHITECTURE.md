# Northstar — Architecture

> **Mobile-only.** No backend server required.

## System Overview

```
┌─────────────────────────────────────────────────┐
│              Flutter App (Northstar)            │
│                                                 │
│  Home │ Discover │ Brief │ Saved │ Profile    │
│         BLoC → Repository → WhatsTrending API     │
│                         ↓                       │
│              Local storage (prefs + secure)     │
│                         ↓                       │
│              Groq API (optional, for AI)        │
└─────────────────────────────────────────────────┘
         │                    │
         ▼                    ▼
  whatstrending.ai/api/articles    api.groq.com
     (free, no key)            (user's key)
```

## Data flow

1. **WhatsTrendingDatasource** fetches articles from `https://whatstrending.ai/api/articles`
2. **FeedRepository** maps articles to Story entities, applies interest-based ranking
3. **UserLocalStorage** persists name, interests, saved stories, read history
4. **SecureKeyStore** holds Groq API key (encrypted)
5. **GroqService** enriches story detail with "Why it matters" (optional)

## Mobile structure

```
mobile/lib/
├── core/           # theme, router, DI, constants, storage
├── shared/         # reusable widgets
└── features/
    ├── onboarding/
    ├── home/
    ├── story/
    ├── discover/
    ├── brief/
    ├── saved/
    ├── profile/
    └── search/
```

## Personalization (on-device)

Ranking uses interest matching + trendScore + coverage from WhatsTrending:

```
relevance = base score + interest boost + trend momentum
```

No server-side ML. Future: on-device embeddings.

## Future (if needed later)

A backend would only be added if you need:
- Multi-source ingestion & story clustering
- Push notifications
- Cross-device sync

For MVP, WhatsTrending API + local personalization is sufficient.
