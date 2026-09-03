# Grow~ by IdeaLab — Project Instructions

Operational management platform for AICTE IdeaLab at MEC (Model Engineering
College), Kerala. Flutter (Android) + Supabase (Auth/DB/Storage/Realtime) +
Firebase (Google Sign-In verification only) + Riverpod ^2.6.x + GoRouter.

This file is intentionally lean. It states rules that apply to almost every
session and points to the canonical doc for everything else. Do not duplicate
those docs here — read them when the task touches that area.

## Repo facts

- Git repo root is this directory (`grow/`), not its parent.
- Flutter SDK is at `C:\flutter`, not on PATH. Bash sessions need
  `export PATH="/c/flutter/bin:$PATH"` before `flutter`/`dart` commands work.
  Pinned version: Flutter 3.41.9 (matches `.github/workflows/ci.yml`).
- `docs/` is entirely git-ignored (see `docs/DOCUMENTATION_GOVERNANCE.md`).
  Edits there are useful locally but will never appear in a diff, PR, or
  `gh pr create` body — say so explicitly if asked to "update documentation"
  as part of a PR.
- `docs/00_Project_Management/MASTER_INDEX.md` is the canonical doc index.
  `docs/documentation_index.md` is a superseded duplicate — don't treat it as
  authoritative.

## Branching & PRs

Canonical: `DEV_WORKFLOW.md`, `BRANCH_PROTECTION.md`, `CONTRIBUTING.md`,
`.github/PULL_REQUEST_TEMPLATE.md`.

- `main` = production trunk. `rc5-release-candidate` = current active RC
  integration branch. Both are protected on GitHub (1 required approving
  review, `enforce_admins` on, required checks below) — never push directly
  to either. Other long-lived-looking branches (e.g. `rc5-release`,
  `develop`) exist in the repo but are not the active integration branch;
  don't assume every branch listed by `git branch -a` is current.
- Branch prefixes: `feature/*`, `fix/*`, `chore/*`. One coherent change per
  branch/PR.
- Real required CI checks (from `.github/workflows/ci.yml`): **Quality Gate**
  and **Debug APK Build**. Ignore the older, stale check lists in
  `docs/05_DevOps/git_policy.md`/`git_strategy.md` — those two docs
  self-flag as unreconciled duplicates of the root docs.
- Squash merge only. PR must cover purpose, scope, architecture/DB/security
  impact, tests run, rollback plan (see PR template).

## Architecture boundaries

Canonical: `docs/02_Architecture/REPOSITORY_ARCHITECTURE.md`,
`docs/02_Architecture/MODULE_LIFECYCLE.md`, `ARCHITECTURE_DECISIONS.md`.

- Feature-first: `lib/features/<feature>/{application,constants,models,presentation,services,utils}`.
- Features must not import other features directly — go through `lib/shared/`
  or a global provider. `lib/core/` must not import features or shared.
  Widgets must not call Supabase directly — go through repositories/services.
- Every operational module (Work Requests, Manufacturing Tasks, Machine
  Queue, Inventory, Payments, Borrowing, Visitors, Machines, Events) is
  phase-gated: Planning → Requirements → Contract → UI/Local Flow → DB
  Architecture → Repository/API → Backend Sync/RLS → Testing → Production.
  Phase 1 stops at Gate 4 — zero Supabase tables, repositories, or API
  clients for a module until its DB architecture is approved.
- CI enforces this: `.github/ci/architecture_guard_paths.txt` blocks commits
  touching `lib/features/{work_requests,inventory,borrowing,payments,quotations,visitors,machines}/(data|domain)/`
  and `supabase/migrations/` until that module's architecture is approved.
  Don't try to work around the guard; it means the gate hasn't been cleared.

## Terminology (don't drift from this)

Canonical: `docs/01_Product/BUSINESS_GLOSSARY.md`.

Use **Work Request**, not Order. Use **Manufacturing Task**, not Job — one
Work Request may produce several Manufacturing Tasks (ADR-0002, ADR-0003).
Use **Asset** only for fixed/individually-tracked items, never for consumable
inventory.

## Security

Canonical: `SECURITY.md`, `docs/04_Security/security_policy.md`,
`docs/04_Security/TRUST_BOUNDARY.md`.

- Never commit secrets, keystores, `.env`, or `google-services.json`
  (gitignored). Frontend uses the `anon` key only — never `service_role`.
- RLS is required on every table; no RLS changes without explicit review; no
  bypassing RLS from client code.
- Never log tokens, payment identifiers, or private profile fields.
- CI runs a grep-based secret scan plus Gitleaks — treat either failure as a
  release blocker.

## Testing & quality gates

Canonical: `CODING_STANDARD.md`, `DEFINITION_OF_DONE.md`, `DEV_WORKFLOW.md`.

Run before considering work done, and always before opening/updating a PR:

```powershell
dart format .
flutter analyze
flutter test
```

Run only the relevant test path during iteration
(`flutter test test/<area>_test.dart`); run the full suite before a PR.

## Skills

Specialized, repo-grounded workflows live in `.claude/skills/`: `work-request`,
`manufacturing-task`, `architecture-review`, `supabase-review`,
`security-review`, `flutter-feature`, `test-review`, `pr-review`. Invoke the
matching one instead of re-deriving these rules from scratch each session.
