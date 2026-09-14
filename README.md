# Northstar

> **Your north star in tech.**

A Flutter mobile app for personalized tech news — no backend, no login.

## How it works

```
WhatsTrending API  →  Flutter app  →  Your feed
       (free)         (local prefs)     (personalized)
                              ↓
                         Groq API (optional)
                      AI "why it matters"
```

**Data source:** [WhatsTrending API](https://whatstrending.ai/api/articles) — free, no API key.

**Everything else runs on device:**
- Name, interests, saved stories → local storage
- Groq API key → secure storage (Keychain / Keystore)
- Personalization & ranking → computed in the app

## Run

```bash
cd mobile
flutter pub get
flutter run
```

Optional: add your Groq key in **Profile** for AI-powered story explanations.

## Features

- Onboarding (name + interests, no account)
- Personalized home feed + "Since you last checked"
- Trending discover with ranked stories
- Story detail with read original + related articles
- Daily brief, saved stories, search
- Offline profile data

## Project structure

```
mobile/     # Flutter app (the entire product)
docs/       # Product & design documentation
```

## Tech stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter, BLoC, go_router |
| News | WhatsTrending API (direct from app) |
| AI | Groq API (optional, user-provided key) |
| Storage | SharedPreferences + flutter_secure_storage |
