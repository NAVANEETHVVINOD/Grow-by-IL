## Grow~ by IdeaLab
Operational management platform for AICTE IdeaLab at MEC (Model Engineering College), Kerala.

## Product scope
- Manual-first lab presence and check-in, with supervised after-hours access
- Work requests, machine work/booking, and tools/components under separate approval flows
- Projects and creator-approved membership requests
- Events, including verified paid registration and event-head refund handling
- Member profiles and scoped administration

Some screens and local flows exist, but this list is **product scope, not a claim that each backend workflow is live**. Do not use seeded operational records or QR/demo paths as release evidence.

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
- `supabase/` — proposed migrations and database tests; compare with the deployed schema before applying
- `test/` and `integration_test/` — automated checks; device E2E remains a separate gate
- `docs/` — only individually reviewed, non-sensitive planning documents are tracked; most local docs remain ignored pending audit

See the [Grow V1 task board](docs/00_Project/GROW_V1_TASK_BOARD.md) and [Penpot acceptance matrix](docs/01_Design/PENPOT_ACCEPTANCE_MATRIX.md) for current gates and unverified work.

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
- Validate RLS, grants, and Storage policies against the deployed project before release; repository SQL alone is not proof of live authorization

## Current status
**RC5 development — not approved for production release.** Auth delivery and Google-provider configuration, private security review/deployment, real Storage access rules, Penpot parity, and exact-build Android E2E remain gates. Passing local tests or CI does not by itself close them. The current evidence and issue/PR dependencies are recorded in the [V1 task board](docs/00_Project/GROW_V1_TASK_BOARD.md).
