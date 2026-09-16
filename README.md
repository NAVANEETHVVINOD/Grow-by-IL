# Grow by Idea Lab and Fab Lab
Flutter product for MEC Idea Lab and Fab Lab, operated as one organisation
across two rooms. It is being built for a supervised initial rollout and
eventual use by more than 4,000 students and external participants. The public
name is still to be confirmed.

## What it does
- Lab check-in/out (manual first; QR optional)
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

`--dart-define` passes public mobile configuration to the build. Its contents
can be extracted from a shipped app, so it must never hold a Supabase service
role key, signing secret, or payment credential.

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
- Mobile builds receive only public configuration through `--dart-define`.
- `google-services.json` is gitignored
- No `service_role` keys in frontend
- RLS and role boundaries must be verified against the live project before launch.

## Current status
This repository contains features at different stages of completion. Some
screens still use seeded local data, simulated actions, or fixed lab status.
These must not be presented as live operations. The current automated suite
does not establish real device and backend end-to-end readiness. See the
[launch audit](docs/audits/LAUNCH_READINESS.md) before enabling a workflow for
members.

Project governance and current approved product decisions are indexed in
[docs](docs/README.md). Changes to protected branches require a pull request,
current CI checks, and independent review.
