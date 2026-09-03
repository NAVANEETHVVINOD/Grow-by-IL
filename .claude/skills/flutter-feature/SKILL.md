---
name: flutter-feature
description: Use when implementing a new Flutter feature or screen, or extending an existing feature module under lib/features/ — scaffolding, state management, UI states, feature flags.
---

# Flutter Feature Implementation

## Canonical sources

- `CODING_STANDARD.md` — Flutter architecture, UI/UX, data/business logic,
  Supabase, testing, and logging standards.
- `docs/02_Architecture/REPOSITORY_ARCHITECTURE.md` — feature-first
  directory layout and naming conventions (see [[architecture-review]] for
  the layer-coupling rules in detail).
- `docs/02_Architecture/feature_flags.md` — flag definitions, rollout/rollback
  rules, and the current `FeatureFlags` class location
  (`lib/core/constants/feature_flags.dart`).
- `docs/02_Architecture/MODULE_LIFECYCLE.md` — confirms whether the feature
  is still Phase 1 (UI/local-flow only, zero Supabase tables/repositories)
  or has cleared later gates.
- `docs/02_Architecture/rc5_design_system.md` — existing RC5 design tokens
  and shared widgets to reuse instead of one-off styling.

## Standards to follow

- New feature code under `lib/features/<feature>/` with the standard
  sub-layout: `application/providers`, `constants`, `models`,
  `presentation/{screens,widgets}`, `services`, `utils`. `data/` and
  `domain/` subfolders are Phase-2-only for gated modules — check
  `.github/ci/architecture_guard_paths.txt` before adding either.
- State ownership via Riverpod providers; avoid giant `ConsumerWidget`s
  watching unrelated providers — prefer section-level consumers on heavy
  screens.
- Widgets never call Supabase directly — go through a repository/service.
- Every screen needs explicit loading, empty, error, and success states.
- Don't encode unapproved business rules into forms — if a validation rule
  isn't in an approved requirements/contract doc, flag it rather than
  guessing.
- Avoid magic strings for statuses/roles/categories — prefer the feature's
  existing enums/constants or master data.
- New risky or not-yet-validated modules get a feature flag, default off,
  per `feature_flags.md`'s rollout rules. Never gate a security check behind
  a UI flag.
- Mobile-first; reuse existing shared widgets/tokens over new one-offs.

## Workflow

1. Check `docs/02_Architecture/MODULE_LIFECYCLE.md` for this feature's
   current phase before deciding what's implementable.
2. Scaffold under the standard sub-layout; don't invent a different shape
   for "just this feature."
3. Wire state through Riverpod providers scoped to what the screen needs.
4. Add loading/empty/error/success states before calling the screen done.
5. Run `dart format .`, `flutter analyze`, and `flutter test` (scoped to the
   feature, then the full suite before PR) — see [[test-review]].
