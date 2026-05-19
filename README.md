## Grow~ by IdeaLab
Operational management platform for AICTE IdeaLab at MEC (Model Engineering College), Kerala.

## What it does
- Lab check-in/out with QR
- Tool booking and inventory
- Project and team management
- Event RSVP
- Role-based administration
- Google Sign-In (via Firebase + Supabase hybrid auth)

## Tech stack
- Flutter 3.41.9 (Android)
- Supabase (Auth, Database, Storage, Realtime)
- Firebase (Google Sign-In credential verification)
- Riverpod 2.x (state management)
- GoRouter (navigation)

## Project structure
- `lib/core/` — app configuration, routing, and theme
- `lib/features/` — main feature modules (auth, explore, lab, profile, projects, events, admin)
- `lib/shared/` — reusable widgets, models, and repositories

## Getting started

**Prerequisites**
- Flutter SDK (3.41.9 or compatible)
- Dart SDK
- Supabase project access
- Firebase project access (for Google Sign-In)

**Setup**
```sh
flutter pub get
```

**Firebase Setup** (one-time per developer):
1. Download `google-services.json` from [Firebase Console](https://console.firebase.google.com/) → Project Settings → Your Apps
2. Place it at `android/app/google-services.json`
3. This file is **gitignored** and must NOT be committed

## Development

All sensitive credentials are injected via `--dart-define` at build time. **No API keys are hardcoded in source.**

```sh
flutter run -d <device> \
  --dart-define=SUPABASE_URL=YOUR_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_KEY \
  --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_GOOGLE_WEB_CLIENT_ID \
  --dart-define=FIREBASE_API_KEY=YOUR_FIREBASE_API_KEY \
  --dart-define=FIREBASE_APP_ID=YOUR_FIREBASE_APP_ID \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=YOUR_SENDER_ID \
  --dart-define=FIREBASE_PROJECT_ID=YOUR_PROJECT_ID \
  --dart-define=FIREBASE_STORAGE_BUCKET=YOUR_BUCKET
```

See `.env.example` for a complete list of required values and where to find them.

## Security
- All secrets injected via `--dart-define` (compile-time only)
- `google-services.json` is gitignored
- No `service_role` keys in frontend
- RLS enforced on all protected tables
- See `docs/security.md` for full security policy

## Documentation
See `docs/` folder for architecture, database contract, and roadmap.

## Current status
RC3 — Auth Stabilization, Security Hardening, and Firebase Integration complete
