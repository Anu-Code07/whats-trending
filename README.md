# Pulse

> **Know what matters in tech.**

A premium mobile intelligence product that aggregates technology news into canonical stories, explains why they matter, and personalizes delivery based on an evolving interest graph.

## Architecture

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the full product and system architecture.

| Document | Description |
|----------|-------------|
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | System overview, modules, pipeline |
| [DATA_MODEL.md](docs/DATA_MODEL.md) | Database entities and relationships |
| [API.md](docs/API.md) | REST API specification |
| [RANKING.md](docs/RANKING.md) | Personalization and ranking strategy |
| [DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md) | Visual design tokens and components |
| [MVP_SCREENS.md](docs/MVP_SCREENS.md) | Screen inventory and user flows |

## Project Structure

```
├── backend/          # Node.js + TypeScript API (modular monolith)
├── mobile/           # Flutter app (Clean Architecture + BLoC)
└── docs/             # Architecture and product documentation
```

## Getting Started

### Backend

```bash
cd backend
npm install
npm run dev
```

API runs at `http://localhost:3000`. Health check: `GET /health`.

### Mobile

```bash
cd mobile
flutter pub get
flutter run
```

The mobile app uses mock data by default. Connect to the backend by updating `AppConstants.apiBaseUrl`.

## MVP Features

- [x] Architecture and data model design
- [x] Backend API skeleton with mock data
- [x] Deterministic ranking strategy
- [x] Flutter app with design system
- [x] Onboarding (interest selection)
- [x] Personalized home feed with "Since you last checked"
- [x] Story detail page (depth toggle, sources, timeline)
- [x] Daily brief tab
- [x] Discover tab with trend radar
- [x] Saved stories
- [x] Profile with Tech DNA
- [x] Search

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter, BLoC, go_router, Clean Architecture |
| Backend | Node.js, TypeScript, Express, Prisma, BullMQ |
| Database | PostgreSQL, Redis |
| AI (future) | Summarization, clustering, entity extraction |
