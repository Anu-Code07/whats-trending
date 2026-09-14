# Pulse — Design System

## Visual Direction

**Feel:** Linear × Perplexity × high-end editorial. Intelligence tool, not news app.

| Attribute | Value |
|-----------|-------|
| Theme | Dark-first |
| Density | Generous whitespace |
| Corners | 12–16px cards, 20px hero |
| Motion | Subtle, purposeful (feed transitions, save feedback, relevance pulse) |
| Icons | Thin stroke, 1.5px weight |

---

## Color Palette (Dark)

| Token | Hex | Usage |
|-------|-----|-------|
| `background` | `#0A0A0B` | App background |
| `surface` | `#141416` | Cards, sheets |
| `surfaceElevated` | `#1C1C1F` | Modals, nav bar |
| `border` | `#2A2A2E` | Dividers, outlines |
| `textPrimary` | `#F5F5F7` | Headlines |
| `textSecondary` | `#98989F` | Metadata, captions |
| `textTertiary` | `#636366` | Placeholders |
| `accent` | `#5E8BFF` | Primary actions, links |
| `accentMuted` | `#5E8BFF33` | Accent backgrounds |
| `relevanceHigh` | `#34D399` | 90%+ relevance |
| `relevanceMid` | `#FBBF24` | 70–89% |
| `impactCritical` | `#EF4444` | Critical impact |
| `impactHigh` | `#F97316` | High impact |

---

## Typography

| Style | Font | Size | Weight |
|-------|------|------|--------|
| Display | SF Pro Display / Inter | 28–32 | 700 |
| Headline | Inter | 20–22 | 600 |
| Title | Inter | 17 | 600 |
| Body | Inter | 15 | 400 |
| Caption | Inter | 13 | 400 |
| Label | Inter | 11 | 500, uppercase tracking |

Line height: 1.4 body, 1.2 headlines.

---

## Components

### Story Card (Feed)
- Title (2 lines max)
- Relevance badge (percentage + color)
- Category chip
- Source count + timestamp
- One-line summary
- Subtle left border accent by relevance tier

### Relevance Badge
```
🔥 96% relevant   (green, high)
🧠 92% relevant  (green)
🚀 87% relevant  (amber)
🔐 84% relevant  (amber)
```

### Impact Pill
`Low` `Medium` `High` `Critical` — muted background, colored dot.

### Section Header
"Since you last checked" — display style, with count subtitle.

### Bottom Navigation
5 tabs: Home, Discover, Brief, Saved, Profile.
Floating bar with blur, 56px height, active = accent icon + label.

### Skeleton States
Shimmer on dark surface (`#1C1C1F` → `#242428`).

---

## Motion

| Interaction | Animation |
|-------------|-----------|
| Feed item appear | Fade + slide up 8px, staggered 50ms |
| Save story | Scale pulse + haptic |
| Tab switch | Cross-fade content, icon scale |
| Relevance badge | Subtle glow on first render |
| Pull to refresh | Custom indicator, accent color |

Duration: 200–300ms. Curve: `easeOutCubic`.

---

## Spacing Scale

4, 8, 12, 16, 20, 24, 32, 40, 48 (px).

Screen horizontal padding: 20px.
Card internal padding: 16px.
Section gap: 24px.
