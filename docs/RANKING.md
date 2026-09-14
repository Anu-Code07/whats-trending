# Pulse — Ranking & Personalization Strategy

## Composite Relevance Score

For each story `S` and user `U`:

```
relevance(S, U) =
  w_topic    × topicMatch(S, U)
+ w_behavior × behavioralAffinity(S, U)
+ w_entity   × entityAffinity(S, U)
+ w_fresh    × freshness(S)
+ w_import   × importance(S)
+ w_novelty  × novelty(S, U)
+ w_trend    × trendMomentum(S)
+ w_source   × sourceQuality(S)
+ w_dev      × developerImpact(S)
```

Weights are configurable per environment; MVP defaults sum to 1.0.

---

## Signal Definitions

### topicMatch (0–1)
Overlap between story's classified topics and user's interest graph nodes (including inferred interests via graph propagation).

```
topicMatch = Σ (storyTopicWeight × userAffinity[topic]) / maxPossible
```

### behavioralAffinity (0–1)
Recency-weighted sum of past interactions with related stories/entities.

| Interaction | Weight |
|-------------|--------|
| completed | 1.0 |
| saved | 0.8 |
| opened (>30s) | 0.5 |
| opened (<10s) | 0.1 |
| ignored | -0.3 |
| shared | 0.9 |

Decay: `weight × 0.95^daysSince`

### entityAffinity (0–1)
Direct affinity for companies/technologies mentioned in story.

### freshness (0–1)
```
freshness = exp(-λ × hoursSincePublished)    λ ≈ 0.02
```
Boost for breaking stories in first 2 hours.

### importance (0–1)
Global score from:
- Source count (log scale, capped)
- Presence of official/primary source
- Impact level
- Cross-ecosystem reach

### novelty (0–1)
Inverse similarity to stories user consumed in last 7 days. MVP: category diversity bonus.

### trendMomentum (0–1)
Only populated when measurable (discussion volume delta, GitHub star velocity). Null → excluded from score.

### sourceQuality (0–1)
Weighted average of source quality scores in cluster. Official sources weighted higher.

### developerImpact (0–1)
Heuristic: API changes, breaking changes, security CVEs, major releases score higher.

---

## Interest Graph Propagation

When user interacts with story tagged `React`:
1. `React` affinity += Δ
2. Propagate to parents: `Frontend` += Δ × 0.7
3. Propagate to related: `TypeScript`, `Next.js` += Δ × 0.5
4. Propagate to ecosystem: `Vercel` += Δ × 0.3

Muted topics block propagation and apply negative filter.

---

## "Why You're Seeing This"

Generated from top contributing signals:

| Condition | Template |
|-----------|----------|
| High topicMatch | "You frequently read {topics} stories." |
| High entityAffinity | "You follow {entity}." |
| High importance | "Major development with {N} sources reporting." |
| Breaking + relevant | "Breaking: related to {topics} you follow." |
| Career mode | "Relevant to your role as {role}." |

---

## RankingStrategy Interface

```typescript
interface RankingStrategy {
  rank(
    stories: Story[],
    context: RankingContext
  ): Promise<RankedStory[]>;
}

interface RankingContext {
  userId: string;
  userInterests: UserInterest[];
  recentInteractions: UserInteraction[];
  now: Date;
}
```

### Implementations

| Strategy | When |
|----------|------|
| `DeterministicRankingStrategy` | MVP |
| `EmbeddingRankingStrategy` | When embeddings available |
| `CollaborativeFilteringStrategy` | Future, sufficient user data |
| `PersonalizedModelStrategy` | Future ML model |

---

## Feed Generation Flow

1. Fetch candidate stories (last 72h, not muted sources/topics)
2. Score each with `RankingStrategy`
3. Apply diversity re-ranking (max 2 stories per category in top 10)
4. Cache result in Redis (`feed:{userId}`, TTL 5min)
5. Return with `sinceLastChecked` overlay

---

## Daily Brief Generation

1. Top 5 by relevance from last 24h
2. Ensure category diversity (AI, dev tools, security, startup, emerging)
3. "You might have missed": relevance > 0.7 but not in top 5
4. All claims map to story IDs (no hallucination)
