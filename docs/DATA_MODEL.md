# Pulse — Data Model

## Entity Relationship Overview

```
User ──┬── UserInterest ── Interest/Topic
       ├── UserInteraction ── Story
       ├── SavedStory ── Story
       ├── Notification
       └── UserProfile (Tech DNA)

Story ──┬── StorySource ── Article ── Source
        ├── StoryEntity ── Entity (Company|Technology|Topic)
        ├── StoryTimeline
        └── Embedding (future)

Article ── Source
Trend ── Topic
Company ── Story (via entities)
Technology ── Story (via entities)
```

---

## Core Entities

### User
| Field | Type | Notes |
|-------|------|-------|
| id | UUID | Primary key |
| email | string | Auth |
| displayName | string? | |
| careerMode | boolean | Prioritize career-relevant content |
| role | string? | e.g. "Frontend Engineer" |
| contentDepth | enum | `quick` \| `normal` \| `deep` |
| notificationFrequency | enum | `critical` \| `relevant` \| `daily` \| `digest` \| `off` |
| lastActiveAt | timestamp | For "since you last checked" |
| createdAt | timestamp | |

### Story (canonical content object)
| Field | Type | Notes |
|-------|------|-------|
| id | UUID | |
| slug | string | URL-friendly |
| title | string | Canonical headline |
| summary | text | 2–4 sentence "what happened" |
| whyItMatters | text | Practical significance |
| whoShouldCare | string[] | e.g. ["Developers", "AI engineers"] |
| impact | enum | `low` \| `medium` \| `high` \| `critical` |
| category | string | Primary category |
| sourceCount | int | Distinct sources in cluster |
| importanceScore | float | Global significance 0–1 |
| trendMomentum | float? | Only if measurable |
| isBreaking | boolean | |
| publishedAt | timestamp | First article time |
| updatedAt | timestamp | Last cluster update |
| status | enum | `active` \| `evolving` \| `archived` |

### Article
| Field | Type | Notes |
|-------|------|-------|
| id | UUID | |
| storyId | UUID? | Null until clustered |
| sourceId | UUID | |
| externalId | string? | Source-native ID |
| url | string | Unique |
| title | string | |
| body | text? | |
| author | string? | |
| publishedAt | timestamp | |
| contentType | enum | `official` \| `journalism` \| `community` \| `analysis` |
| urlHash | string | Dedup key |

### Source
| Field | Type | Notes |
|-------|------|-------|
| id | UUID | |
| name | string | e.g. "GitHub Blog" |
| url | string | |
| type | enum | `rss` \| `api` \| `scraper` |
| qualityScore | float | 0–1 editorial weight |
| logoUrl | string? | |

### StorySource (join)
Links articles to stories with ordering (primary source first).

### Entity (polymorphic via type)
| Field | Type | Notes |
|-------|------|-------|
| id | UUID | |
| type | enum | `company` \| `technology` \| `topic` |
| name | string | |
| slug | string | |
| description | text? | |
| logoUrl | string? | |
| metadata | jsonb | Type-specific fields |

### Interest / Topic
| Field | Type | Notes |
|-------|------|-------|
| id | UUID | |
| name | string | e.g. "React", "AI" |
| slug | string | |
| parentId | UUID? | Graph hierarchy |
| icon | string? | |

### UserInterest
| Field | Type | Notes |
|-------|------|-------|
| userId | UUID | |
| interestId | UUID | |
| affinity | float | 0–1, learned weight |
| isFollowed | boolean | Explicit follow |
| isMuted | boolean | Explicit mute |
| source | enum | `onboarding` \| `explicit` \| `inferred` |

### UserInteraction (behavior signals)
| Field | Type | Notes |
|-------|------|-------|
| id | UUID | |
| userId | UUID | |
| storyId | UUID | |
| type | enum | `opened` \| `completed` \| `saved` \| `shared` \| `ignored` |
| durationMs | int? | Reading time |
| createdAt | timestamp | |

### SavedStory
| Field | Type | Notes |
|-------|------|-------|
| userId | UUID | |
| storyId | UUID | |
| collection | enum | `read_later` \| `learn` \| `career` \| `build_ideas` \| `interesting` |
| savedAt | timestamp | |

### StoryTimeline
| Field | Type | Notes |
|-------|------|-------|
| id | UUID | |
| storyId | UUID | |
| type | enum | `breaking` \| `updated` \| `reaction` \| `analysis` |
| title | string | |
| articleId | UUID? | |
| occurredAt | timestamp | |

### Trend
| Field | Type | Notes |
|-------|------|-------|
| id | UUID | |
| name | string | |
| direction | enum | `rising` \| `stable` \| `falling` |
| volumeChange | float? | Only if measured |
| interestId | UUID? | Link to topic |

### Notification
| Field | Type | Notes |
|-------|------|-------|
| id | UUID | |
| userId | UUID | |
| storyId | UUID? | |
| type | enum | `critical` \| `relevant` \| `brief` \| `digest` |
| title | string | |
| body | string | |
| sentAt | timestamp? | |
| readAt | timestamp? | |

### DailyBrief
| Field | Type | Notes |
|-------|------|-------|
| id | UUID | |
| userId | UUID | |
| date | date | |
| topStories | UUID[] | Ordered story IDs |
| missedStories | UUID[] | |
| generatedAt | timestamp | |

---

## Interest Graph (in-memory + persisted)

Stored as adjacency list in `Interest` table (`parentId`) plus `InterestRelation` for cross-links:

```
InterestRelation: fromId, toId, relationType (parent|related|ecosystem)
```

User affinity propagates along edges with decay factor (e.g. 0.7 per hop).

---

## Caching Strategy (Redis)

| Key pattern | TTL | Content |
|-------------|-----|---------|
| `feed:{userId}` | 5 min | Ranked story IDs |
| `story:{id}` | 1 hr | Full story payload |
| `brief:{userId}:{date}` | 24 hr | Daily brief |
| `since:{userId}` | until read | Since-you-last-checked |
| `trending` | 15 min | Global trending list |
