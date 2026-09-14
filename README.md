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
flutter pub get
flutter run
```

### iOS (physical device)

Running on a real iPhone requires Apple code signing. The simulator does not.

1. Open the project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. Add your Apple ID: **Xcode → Settings → Accounts → +**
3. Select the **Runner** target → **Signing & Capabilities**
4. Enable **Automatically manage signing** and choose your **Team**
5. Connect your iPhone, trust the computer on the device, then run:
   ```bash
   flutter run
   ```

**Optional (CLI-only):** copy `ios/Flutter/Team.xcconfig.example` to `ios/Flutter/Team.xcconfig`, set your Team ID, then run `flutter run` again. You still need an Apple ID signed into Xcode.

**Simulator (no signing):**
```bash
flutter run -d "iPhone 16"
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
lib/        # Flutter app source
android/    # Android platform
ios/        # iOS platform
docs/       # Product & design documentation
```

## Tech stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter, BLoC, go_router |
| News | WhatsTrending API (direct from app) |
| AI | Groq API (optional, user-provided key) |
| Storage | SharedPreferences + flutter_secure_storage |
