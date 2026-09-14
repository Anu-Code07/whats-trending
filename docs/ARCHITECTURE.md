# Pulse — Product Architecture

> **Core promise:** Know what matters in tech.

Pulse is a premium, mobile-first intelligence product that aggregates technology news into canonical stories, explains why they matter, and personalizes delivery based on an evolving interest graph.

---

## System Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           MOBILE (Flutter)                              │
│  Home │ Discover │ Brief │ Saved │ Profile                              │
│  BLoC → UseCase → Repository → API / Local Cache                        │
└───────────────────────────────┬─────────────────────────────────────────┘
                                │ REST + WebSocket (future)
┌───────────────────────────────▼─────────────────────────────────────────┐
│                     BACKEND (Node.js / TypeScript)                      │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐     │
│  │   API    │ │  Feed    │ │ Ranking  │ │ Search   │ │ Notify   │     │
│  │ Gateway  │ │ Service  │ │ Service  │ │ Service  │ │ Service  │     │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘     │
│       └────────────┴────────────┴────────────┴────────────┘            │
│                              │                                          │
│  ┌───────────────────────────▼──────────────────────────────────────┐  │
│  │                    Content Pipeline (BullMQ Workers)              │  │
│  │  Ingest → Normalize → Dedupe → Extract → Classify → Embed      │  │
│  │  → Cluster → Score → Personalize → Rank                          │  │
│  └───────────────────────────┬──────────────────────────────────────┘  │
└───────────────────────────────┼─────────────────────────────────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        ▼                       ▼                       ▼
   PostgreSQL               Redis                  External
   (primary data)      (cache, queues)         (RSS, HN, GitHub, AI)
```

---

## Architectural Principles

| Principle | Implementation |
|-----------|----------------|
| Modular monolith | Single deployable with clear module boundaries; extract services later |
| Story as canonical unit | Articles deduplicate into Stories; feed shows Stories, not raw articles |
| Source-backed AI | Summaries and explanations cite sources; never invent facts |
| Pluggable ranking | `RankingStrategy` interface; deterministic MVP → embeddings → ML later |
| Offline-first mobile | Hive/Drift cache for feed, stories, saved items, interests |
| Adapter pattern for sources | Each data source implements `SourceAdapter` |

---

## Backend Modules

| Module | Responsibility |
|--------|----------------|
| `ingestion` | Pull from RSS, HN, GitHub, blogs via adapters |
| `content-processing` | Normalize, extract entities, classify topics |
| `story-clustering` | Group similar articles into canonical stories |
| `ranking` | Importance + personalization scoring |
| `personalization` | Interest graph, behavior signals, relevance |
| `feed` | Home feed, since-you-last-checked, daily brief |
| `search` | Semantic + keyword search over stories/entities |
| `notifications` | Priority-based push delivery |
| `user-profile` | Tech DNA, preferences, career mode |

---

## Mobile Architecture

```
lib/
├── core/           # theme, router, DI, network, constants
├── shared/         # reusable widgets, extensions
└── features/
    ├── onboarding/
    ├── home/
    ├── story/
    ├── discover/
    ├── brief/
    ├── saved/
    ├── profile/
    ├── search/
    ├── company/
    └── technology/
```

Each feature follows Clean Architecture:

```
feature/
├── data/       models, datasources, repository impl
├── domain/     entities, repository contracts, usecases
└── presentation/  bloc, pages, widgets
```

---

## Content Pipeline Stages

1. **Ingestion** — Adapters fetch raw content on schedule
2. **Normalization** — Unified article schema (title, body, url, publishedAt, source)
3. **Deduplication** — URL hash + title similarity pre-filter
4. **Entity extraction** — Companies, technologies, people (AI-assisted)
5. **Topic classification** — Map to interest graph nodes
6. **Embedding generation** — Vector for semantic similarity (future)
7. **Story clustering** — Merge articles about same event
8. **Importance scoring** — Global significance (source quality, coverage breadth)
9. **Personalization** — Per-user relevance from interest graph + behavior
10. **Ranking** — Composite score for feed ordering
11. **Feed generation** — Materialized feed snapshots per user

---

## Key Differentiators (Technical)

### Story Clustering
- Articles with >0.85 title similarity OR shared primary entity within 48h window → same story
- Story evolves: new articles append to timeline, not new feed items
- `sourceCount` = distinct sources in cluster

### Interest Graph
- Nodes: topics, technologies, companies, ecosystems
- Edges: parent/child, related, co-occurrence
- User affinity weights on nodes (0–1), updated by behavior signals

### Ranking Abstraction
```typescript
interface RankingStrategy {
  score(story: Story, context: RankingContext): Promise<RankedStory>;
}
```
MVP uses `DeterministicRankingStrategy`. Future: `EmbeddingRankingStrategy`, `CollaborativeFilteringStrategy`.

---

## Deployment (Future)

- Backend: single Node process + worker process
- PostgreSQL: managed (RDS/Supabase)
- Redis: managed (Upstash/ElastiCache)
- Mobile: iOS + Android via Flutter

---

## MVP Scope

See [MVP_SCREENS.md](./MVP_SCREENS.md) for screen inventory.

MVP delivers: onboarding, personalized home feed, story pages, save, search, tech/company pages, since-you-last-checked, daily brief, basic notifications, behavior-based personalization.

**Not in MVP:** collaborative filtering, social features, advanced ML ranking, audio briefings.
