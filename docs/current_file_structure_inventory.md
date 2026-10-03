# Grow~ Current File Structure Inventory

Last updated: 2026-08-02  
Branch when written: `feature/work-request-create-flow`

This document is local-only. The `docs/` folder is ignored by Git and is meant
for planning, AI handoff, cleanup review, and product/architecture notes.

## Repository Root

```text
.github/                 # Tracked GitHub automation: CI, PR template, issue templates, architecture guard config.
android/                 # Tracked Android app project. Required for builds; do not delete.
assets/fonts/            # Tracked app fonts used by RC5 theme.
docs/                    # Ignored local planning/handoff docs. Not uploaded to GitHub.
integration_test/        # Tracked device/integration tests.
lib/                     # Tracked Flutter application source.
supabase/                # Tracked schema and migration SQL files.
test/                    # Tracked unit/widget tests.
.env                     # Local secrets; should stay ignored.
.env.example             # Tracked template for required env values.
README.md                # Tracked public repo overview.
CONTRIBUTING.md          # Tracked contributor workflow.
SECURITY.md              # Tracked GitHub security policy.
CODEOWNERS               # Tracked GitHub review ownership.
BRANCH_PROTECTION.md     # Tracked branch protection policy.
DEV_WORKFLOW.md          # Tracked PR-first workflow rules.
CODING_STANDARD.md       # Tracked engineering standards.
DEFINITION_OF_DONE.md    # Tracked completion gate.
SYSTEM_BOUNDARIES.md     # Tracked scope boundaries.
ARCHITECTURE_DECISIONS.md # Tracked high-level ADR index.
pubspec.yaml             # Flutter dependencies and app metadata.
pubspec.lock             # Locked dependency versions; keep tracked.
```

## `lib/` Application Map

```text
lib/main.dart                         # App bootstrap, Firebase/Supabase init, ProviderScope.
lib/firebase_options.dart             # Firebase config via dart-define/env-safe defaults.

lib/core/constants/                   # Cross-app constants, roles, feature flags, QR helpers.
lib/core/router/app_router.dart       # Central GoRouter route table and auth/admin/onboarding guards.
lib/core/services/                    # Shared media service abstractions.
lib/core/theme/                       # RC4 theme and RC5 design token/theme system.
lib/core/utils/                       # Logging, validators, provider observer, Supabase error helpers.

lib/shared/models/                    # Existing app data models shared across features.
lib/shared/providers/                 # App-wide utility providers.
lib/shared/repositories/              # Shared Supabase client wrapper.
lib/shared/services/                  # Shared services such as media upload.
lib/shared/widgets/                   # Reusable RC4 widgets and RC5 component library.

lib/features/admin/                   # Admin dashboard, maintenance UI, admin providers/repository.
lib/features/akathalam/               # RC5 Akathalam tab shell.
lib/features/auth/                    # Auth repository, Google auth, login/onboarding/splash screens.
lib/features/events/                  # Events screen.
lib/features/explore/                 # Event repository/providers/details/search; older Explore-era module.
lib/features/home/                    # RC5 Home plus mentorship/knowledge/donation placeholders.
lib/features/lab/                     # Lab check-in, tools, booking bottom sheet, lab/tool repositories.
lib/features/notifications/           # Notification repository/providers/inbox.
lib/features/profile/                 # RC5 profile, edit hub, profile migration/offline sync work.
lib/features/projects/                # Projects repository/providers/list/detail/create screens.
lib/features/work_requests/           # Work Request operations UI and local-only Create Flow.
```

## Work Request Module Map

```text
lib/features/work_requests/presentation/screens/work_requests_screen.dart
  # Operations hub/overview. Links to Create Flow. Uses preview/mock content.

lib/features/work_requests/presentation/screens/create_work_request_screen.dart
  # UI-only multi-step Create Work Request wizard.
  # No Supabase, no repository, no schema writes.

lib/features/work_requests/application/providers/work_request_create_controller.dart
  # Riverpod StateNotifier for wizard step state, local draft restore/save, validation, mock submit.

lib/features/work_requests/models/work_request_draft.dart
  # Local draft DTO for the create wizard. Not a database/domain model.

lib/features/work_requests/services/draft_storage/work_request_draft_storage.dart
  # SharedPreferences local draft storage. No cloud sync.

lib/features/work_requests/constants/work_request_options.dart
  # Category/subcategory/priority/lab option definitions used by UI.

lib/features/work_requests/utils/work_request_validators.dart
  # Pure validation helpers for title, purpose, description, quantity, links, material notes, acknowledgements.
```

## Tests

```text
test/work_request_create_flow_test.dart
  # New tests for Work Request validators, local draft storage, and wizard restore/navigation behavior.

test/app_defaults_test.dart            # User-row default/schema compatibility tests.
test/app_qr_test.dart                  # QR helper tests.
test/app_roles_test.dart               # Role enum/permission helper tests.
test/auth_flow_test.dart               # Auth repository unit/integration-style tests.
test/booking_flow_test.dart            # Booking repository behavior tests.
test/*_model_test.dart                 # Shared model parsing/serialization tests.
test/profile_*                         # Profile migration/offline queue tests.
```

## Supabase

```text
supabase/schema.sql                    # Current schema reference.
supabase/migrations/                   # Historical/phase migrations. Do not change without Phase 2 approval.
supabase/test_overlap_constraint.sql   # DB integrity verification helper.
```

## Cleanup / Merge Notes

- Do not delete `android/`; this is an Android app and builds depend on it.
- Do not delete `.github/`; CI, PR templates, issue templates, and architecture guards live there.
- Do not delete root `README.md`, `SECURITY.md`, `CONTRIBUTING.md`, `CODEOWNERS`, or workflow docs; GitHub consumes them.
- `docs/` is intentionally local/ignored. It can be reorganized freely without affecting GitHub.
- `lib/features/explore/` is older architecture but still provides event repository/detail/search pieces. Do not remove until Event/Akathalam consolidation is completed.
- `lib/features/home/presentation/screens/home_screen.dart` is older Home. RC5 uses `rc5_home_screen.dart`; keep until routes and fallback are audited.
- `lib/features/auth/presentation/screens/register_screen.dart` may become obsolete if Google-only auth is finalized, but do not delete before auth route cleanup.
- `lib/features/work_requests/data/` and `lib/features/work_requests/domain/` should not exist yet; architecture guard blocks them until Phase 2.
- `android/build/` and other generated build outputs should remain ignored and can be locally cleaned.
- `.env` must remain local and ignored.

## Current Work Request Scope

Allowed in the current branch:

- Flutter UI
- Riverpod local state
- SharedPreferences local draft
- Validation
- Widget/unit tests

Forbidden until Phase 2:

- Supabase calls
- SQL migrations
- RLS
- repository/data layer
- domain layer
- API contracts beyond docs
- cloud draft persistence

