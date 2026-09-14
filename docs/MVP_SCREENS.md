# Pulse — MVP Screens & Navigation

## Navigation

```
Bottom Tabs: [Home] [Discover] [Brief] [Saved] [Profile]
```

Stack navigation within each tab for detail screens.

---

## Screen Inventory

### 1. Onboarding (first launch only)
| Step | Content |
|------|---------|
| Welcome | Value prop: "Know what matters in tech" |
| Interests | Multi-select chips (AI, React, Flutter, etc.) |
| Depth | Choose default explanation depth |
| Notifications | Permission + frequency preference |

### 2. Home Feed
- Time-based greeting ("Good evening")
- **Since you last checked** section (if returning user)
- Personalized story list (ranked)
- Pull to refresh
- Tap → Story Detail

### 3. Story Detail
- What happened? (summary)
- Why it matters
- Who should care (chips)
- Impact level
- Your relevance + explanation
- Depth toggle (30s / 3min / 10min)
- Sources list (primary first)
- Timeline (if evolving)
- Community reaction (if available)
- Actions: Save, Share, Build Ideas
- Save feedback animation

### 4. Discover
- Trending stories
- Rising topics
- Technology grid
- Company grid
- Research / Startups sections
- Tap entity → Company/Technology page

### 5. Brief
- "Your Tech Brief" header with date
- Top 5 things you should know
- "You might have missed" section
- Generated from real stories only

### 6. Saved
- Collection tabs: Read Later, Learn, Career, Build Ideas, Interesting
- Story cards with collection badge
- Swipe to remove

### 7. Profile
- Tech DNA visualization (interest bars)
- Top companies, technologies, topics
- Reading patterns summary
- Settings: depth, notifications, career mode, reset personalization

### 8. Search
- Semantic search bar
- Recent searches
- Results: stories, companies, technologies
- Accessible from Home (search icon)

### 9. Company Page
- Logo, description
- Latest announcements, launches, funding
- Timeline of major events
- Related stories

### 10. Technology Page
- Description, ecosystem
- Latest updates, releases
- Related technologies
- Official resources

---

## User Flows

### First Open
```
Splash → Onboarding (interests) → Home Feed (personalized)
```

### Return Visit
```
Home → "Since you last checked" (7 stories) → Scroll feed → Tap story
```

### Morning Routine
```
Brief tab → Top 5 → Tap to read → Save for later
```

### Deep Dive
```
Story → Change depth to 10min → Read sources → Follow technology
```

---

## States (Every Screen)

| State | Treatment |
|-------|-----------|
| Loading | Skeleton shimmer |
| Empty | Illustration + helpful copy + CTA |
| Error | Retry button + message |
| Offline | Cached content + offline banner |
