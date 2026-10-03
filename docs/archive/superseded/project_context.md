# Grow~ — Project Context
> IdeaLab / FabLab Management Platform · MEC (Model Engineering College)
> Flutter · Supabase · Mobile-First · Neo-brutalist

---

## What Is This App

Grow~ is a mobile-first operational management platform for an AICTE IdeaLab
and FabLab at an engineering college in Kerala, India.

It is NOT a social app. It is a structured operational system for:
- Lab access tracking (QR check-in / check-out)
- Tool booking and hardware inventory management
- Project and team collaboration
- Event management and RSVP
- Student maker community management
- Role-based administration

Brand: The app is called **Grow~** (tilde is part of the brand).
"IdeaLab" only appears as subtext "by IdeaLab" in the logo. Never as primary label.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter 3.41.9 / Dart 3.11.5 |
| State | Riverpod 2.x (riverpod_annotation) |
| Navigation | GoRouter |
| Backend | Supabase (Auth + Realtime + PostgreSQL) |
| Storage | Supabase Storage |
| Push | Firebase Cloud Messaging (Task 13, not yet) |
| QR | mobile_scanner (scan) + qr_flutter (generate) |

---

## Design System — Neo-brutalist

- Background: `#F5F5F0` warm off-white
- Primary accent: `#FFD60A` electric yellow
- Dark: `#0D0F1C` deep navy
- Blue accent: `#1A56FF` cobalt
- Success: `#2ECC71` green
- Error: `#FF3B3B` red
- Borders: 2px solid navy on all cards
- Shadows: flat 4px offset (no blur), solid navy
- Typography: Space Grotesk Bold (headings), DM Sans (body)
- NO emojis anywhere — use Material Icons only
- Key widgets: NeoCard, NeoButton, NeoChip, NeoTextField, ShimmerSkeleton

---

## Role Architecture (Two-Layer System)

### base_role (user-selected at signup)
- `student` — default
- `faculty`

### system_role (admin-assigned only, never by user)
- `user` — default for all new users
- `admin`
- `operation_head` — manages inventory, approves bookings
- `machine_head` — manages specific machines/tools
- `event_head`
- `tech_head`

**Rule: Users CANNOT assign themselves admin roles. Only system/admin sets system_role.**

---

## Architecture Patterns

- Feature-first folder structure
- Repository pattern (data layer per feature)
- Riverpod providers in domain/ folder per feature
- Shared widgets in lib/shared/widgets/
- All strings in lib/core/constants/app_strings.dart
- All colors in lib/core/constants/app_colors.dart
- Logging via AppLogger (lib/core/utils/app_logger.dart)
- Error handling via handleSupabaseError() (lib/core/utils/supabase_error_handler.dart)

### Coding Rules
1. Run `flutter analyze` after every task. Must be 0 issues.
2. Never use packages not in pubspec.yaml without asking.
3. All screens handle 3 states: loading (ShimmerSkeleton), error, empty.
4. All strings in AppStrings, never hardcoded.
5. No emojis — Material Icons only.
6. No over-engineering. Keep it simple and modular.
7. Never disable RLS. Never expose service_role keys.

---

## File Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart       ✅
│   │   ├── app_sizes.dart        ✅
│   │   ├── app_strings.dart      ✅
│   │   └── supabase_keys.dart    ✅
│   ├── router/
│   │   └── app_router.dart       ✅
│   ├── theme/
│   │   └── app_theme.dart        ✅
│   └── utils/
│       ├── app_logger.dart       ✅
│       ├── extensions.dart       ✅
│       ├── supabase_error_handler.dart ✅
│       └── validators.dart       ✅
├── features/
│   ├── auth/
│   │   ├── data/auth_repository.dart     ✅
│   │   └── presentation/screens/
│   │       ├── splash_screen.dart        ✅
│   │       ├── onboarding_screen.dart    ✅
│   │       ├── login_screen.dart         ✅
│   │       ├── register_screen.dart      ✅
│   │       └── profile_setup_screen.dart ✅
│   ├── home/
│   │   ├── data/home_repository.dart     ✅
│   │   └── presentation/screens/
│   │       └── home_screen.dart          ✅
│   ├── lab/
│   │   ├── data/lab_repository.dart      ✅
│   │   ├── domain/lab_providers.dart     ✅
│   │   └── presentation/screens/
│   │       ├── lab_screen.dart           ✅
│   │       └── qr_scan_screen.dart       ✅
│   ├── profile/
│   │   └── presentation/screens/
│   │       └── profile_screen.dart       ✅
│   ├── events/
│   │   └── presentation/screens/
│   │       └── events_screen.dart        🔲 placeholder
│   ├── explore/
│   │   └── presentation/screens/
│   │       └── explore_screen.dart       🔲 placeholder
│   ├── projects/
│   │   └── presentation/screens/        🔲 placeholder
│   └── admin/
│       └── presentation/screens/
│           └── admin_panel_screen.dart   🔲 placeholder
├── shared/
│   ├── models/
│   │   ├── user_model.dart               ✅
│   │   ├── tool_model.dart               ✅
│   │   ├── booking_model.dart            ✅
│   │   ├── event_model.dart              ✅
│   │   ├── rsvp_model.dart               ✅
│   │   ├── project_model.dart            ✅
│   │   ├── lab_session_model.dart        ✅
│   │   └── notification_model.dart       ✅
│   ├── repositories/
│   │   └── supabase_client.dart          ✅
│   └── widgets/
│       ├── main_shell.dart               ✅
│       ├── neo_card.dart                 ✅
│       ├── neo_button.dart               ✅
│       ├── neo_chip.dart                 ✅
│       ├── neo_text_field.dart           ✅
│       ├── shimmer_skeleton.dart         ✅
│       └── user_qr_card.dart             ✅
└── main.dart                             ✅
```

---

## Routes (GoRouter)

| Route | Screen | Auth Required | Bottom Nav |
|---|---|---|---|
| /splash | SplashScreen | No | No |
| /onboarding | OnboardingScreen | No | No |
| /login | LoginScreen | No | No |
| /register | RegisterScreen | No | No |
| /profile-setup | ProfileSetupScreen | Yes | No |
| /home | HomeScreen | Yes | Yes |
| /explore | ExploreScreen | Yes | Yes |
| /events | EventsScreen | Yes | Yes |
| /lab | LabScreen | Yes | Yes |
| /profile | ProfileScreen | Yes | Yes |
| /lab/scan | QRScanScreen | Yes | No |
| /admin | AdminPanelScreen | Yes (op_head/faculty) | No |

Route guard: unauthenticated users → /login. Auth users on /login → /home.
Profile incomplete (profile_completed=false) → /profile-setup.

---

## Key Models (users table columns)

```dart
id, name, email, phone, college_roll,
username,           // unique @handle
base_role,          // student | faculty
system_role,        // user | admin | operation_head | machine_head | etc.
skills,             // TEXT[]
interests,          // TEXT[]
xp,                 // int, default 0
level,              // int, default 1
reputation_score,   // int, default 100
qr_code_data,       // unique string for QR
is_blocked,         // bool
profile_completed,  // bool
show_github_graph,  // bool
created_at
```

---

## Security Rules

- RLS enabled on ALL tables
- Route guards in app_router.dart redirect
- Role checks use system_role from users table
- Never trust frontend-only permissions
- DB constraints prevent double check-in (unique active session)
- signOut() auto-checks out active lab session first

---

## Logging Pattern (AppLogger)

```dart
AppLogger.action('Feature', 'ACTION_NAME', data: {'key': value});
AppLogger.info('Feature', 'Success message');
AppLogger.warn('Feature', 'Warning message');
AppLogger.error('Feature', 'Error message', error, stackTrace);
```

Examples already applied to: auth_repository, lab_repository, home_repository.

---

_Last updated: May 2026 | Version: Tasks 1–7 complete_
