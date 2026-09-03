---
name: architecture-review
description: Use when reviewing a change for module boundaries, layer coupling, phase-gate compliance, or repository structure — e.g. "does this belong in shared or features", "is this allowed in Phase 1", "does this violate the architecture guard".
---

# Architecture Review

## Canonical sources

- `docs/02_Architecture/REPOSITORY_ARCHITECTURE.md` — directory layout,
  feature-first module structure, dependency rules, naming conventions.
- `docs/02_Architecture/MODULE_LIFECYCLE.md` — the 9-phase gate every
  operational module must pass through sequentially.
- `ARCHITECTURE_DECISIONS.md` — the authoritative, git-tracked ADR list
  (ADR-001 through ADR-007). If this file and any doc under
  `docs/00_Project_Management/ARCHITECTURAL_DECISION_RECORDS/` disagree,
  `ARCHITECTURE_DECISIONS.md` wins.
- `.github/ci/architecture_guard_paths.txt` — the literal enforced regex
  list of what CI blocks right now. This is ground truth for "is this
  gated", not a doc's description of it.

## Checks to run

1. **Layer coupling**: does the change import across features directly
   (`lib/features/A` importing `lib/features/B`)? That's forbidden — must go
   through `lib/shared/` or a global provider. Does `lib/core/` import
   features or shared? Also forbidden.
2. **Feature-first structure**: new feature code should land under
   `lib/features/<feature>/{application,constants,models,presentation,services,utils}`,
   not scattered elsewhere.
3. **Phase gate**: is this module's work covered by
   `.github/ci/architecture_guard_paths.txt`? If the diff touches
   `lib/features/{work_requests,inventory,borrowing,payments,quotations,visitors,machines}/(data|domain)/`
   or `supabase/migrations/`, it needs an approved architecture/DB design
   first — CI will fail it regardless of what the PR argues.
4. **Widget/Supabase separation**: widgets must not call Supabase directly —
   only repositories/services do (`CODING_STANDARD.md`).
5. **Feature flags**: is a new, risky, or reversible-only module wrapped in a
   feature flag per `docs/02_Architecture/feature_flags.md`? Flags default to
   off until validated; never use a UI flag to gate a security check.
6. **Naming conventions**: files `snake_case.dart`, classes `PascalCase`,
   providers `camelCaseProvider`, routes `/kebab-case`.

## Workflow

1. Identify which module(s) the diff touches and cross-reference the phase
   gate table in `MODULE_LIFECYCLE.md` for each.
2. Grep the diff's changed paths against
   `.github/ci/architecture_guard_paths.txt` patterns directly — don't just
   reason about it, actually match the regex.
3. Report violations with the specific rule/doc they violate, not a general
   "this looks risky." If a violation is real, don't propose bypassing the
   guard — propose the smallest change that stays inside the current gate
   (e.g. UI/local-flow only) or flag that the module needs its next gate
   cleared first.
