---
name: test-review
description: Use when writing tests for new/changed code, or reviewing whether a change has adequate test coverage — unit, widget, or integration tests under test/ or integration_test/.
---

# Test Review

## Canonical sources

- `CODING_STANDARD.md` §"Testing Standards".
- `docs/02_Architecture/REPOSITORY_ARCHITECTURE.md` §"Testing Strategy" —
  test location mirrors `lib/` paths, naming
  `test/<feature_name>_<context>_test.dart`, framework `flutter_test` +
  `flutter_riverpod`, mocks via `SharedPreferences.setMockInitialValues({})`
  with no live network calls, minimum 80% coverage target for validators,
  controllers, and state storage classes.
- `docs/06_Testing/test_inventory.md` — current inventory of what's already
  tested (as of last update: 85 unit, 2 widget, 18 integration tests, all
  passing) — check here before assuming a class is untested.
- `DEV_WORKFLOW.md` / `DEFINITION_OF_DONE.md` — the required local check
  sequence and DoD testing checklist.

## Standards to follow

- Unit test models, validators, and business logic — this is the priority,
  not UI text assertions. Business correctness should not depend only on
  widget text matching (`CODING_STANDARD.md`).
- Repository logic should be testable without UI automation where practical.
- UI/widget/integration tests stay small and smoke-focused — they're not
  where business-rule coverage should live.
- No live network calls in tests; mock `SharedPreferences` and Supabase
  calls at the repository boundary.

## Workflow

1. Before writing new tests, check `docs/06_Testing/test_inventory.md` for
   what already exists for the touched file/class, so you extend rather than
   duplicate.
2. Match the existing naming/location convention:
   `test/<feature_name>_<context>_test.dart`, mirroring the `lib/` path.
3. Prioritize coverage in this order: validators → business logic/state
   controllers → models/serialization → widget smoke tests. Don't spend the
   coverage budget on widget text assertions if the validator underneath is
   untested.
4. Run the scoped test file(s) during iteration; run the full
   `flutter test` before opening/updating a PR, matching CI's "Quality Gate"
   job.
