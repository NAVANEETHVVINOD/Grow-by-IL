## Grow~ by IdeaLab
One-line description: operational management platform for AICTE IdeaLab at MEC (Model Engineering College), Kerala.

## What it does
- Lab check-in/out with QR
- Tool booking and inventory
- Project and team management
- Event RSVP
- Role-based administration

## Tech stack
- Flutter 3.41.9 (Android + iOS)
- Supabase (Auth, Database, Storage, Realtime)
- Riverpod 2.x (state management)
- GoRouter (navigation)

## Project structure
- `lib/core/` - app configuration, routing, and theme
- `lib/features/` - main feature modules (auth, explore, lab, profile, projects)
- `lib/shared/` - reusable widgets, models, and repositories

## Getting started
**Prerequisites**
- Flutter SDK (3.41.9 or compatible)
- Dart SDK
- Supabase project access

**Setup**
```sh
flutter pub get
```

## Development
To run the app, you need to provide the Supabase URL and Anon Key via `dart-define`:
```sh
flutter run -d <device> --dart-define=SUPABASE_URL=YOUR_URL --dart-define=SUPABASE_ANON_KEY=YOUR_KEY
```

## Documentation
See `docs/` folder for architecture, database contract, and roadmap.

## Current status
RC2 — Operations layer in progress
