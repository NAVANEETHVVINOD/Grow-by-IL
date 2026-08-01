# Grow~ Development Workflow

## Purpose

This document defines how work moves from idea to release. It is tracked in the
repo so the workflow does not depend on chat memory.

## Workflow

```text
Issue / Task
  -> Architecture Review
  -> Feature Branch
  -> Implementation
  -> Self Review
  -> Pull Request
  -> CI
  -> Review
  -> Squash Merge
  -> Release
```

## Branch Rules

- No direct pushes to `main`.
- All changes must go through pull requests.
- Use `feature/*` for product work.
- Use `fix/*` for bug fixes.
- Use `chore/*` for docs, tooling, CI, or cleanup.
- Keep branches small and single-purpose.

## Phase Gate Rules

- Product implementation must follow approved requirements.
- Schema/migration work must wait for approved architecture and database design.
- New modules must be behind feature flags until stable.
- UI-only previews are allowed only when they are reversible and do not imply
  backend contracts.

## Local Check Rules

Run before opening or updating a PR:

```powershell
dart format .
flutter analyze
flutter test
```

For Android release-impacting changes, also run the relevant build command.

## PR Rules

A PR must include:

- purpose
- scope
- files changed
- architecture impact
- database impact
- breaking changes
- screens added or changed
- tests
- rollback plan
- future work

## Merge Rules

- CI must be green.
- At least one review is required.
- Use squash merge.
- Delete merged branches.

## Release Rules

- Releases must use signed artifacts.
- Internal testing comes before public rollout.
- Release checklist and rollback notes must be reviewed before production.
