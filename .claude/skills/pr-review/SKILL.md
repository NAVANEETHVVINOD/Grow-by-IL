---
name: pr-review
description: Use when preparing a PR description, reviewing a diff before opening/updating a PR, or checking whether a change meets the repo's Definition of Done and merge requirements.
---

# PR Review

## Canonical sources

- `DEV_WORKFLOW.md` — full workflow (issue → architecture review → branch →
  implementation → self review → PR → CI → review → squash merge → release),
  branch rules, local check rules, PR content rules, merge rules.
- `CONTRIBUTING.md` — required reading list, branching strategy, development
  process, architecture gate.
- `DEFINITION_OF_DONE.md` — the checklist a feature must satisfy across
  product/architecture, implementation, data/security, verification, and
  review/release before it's "done."
- `BRANCH_PROTECTION.md` — required repo settings, solo-maintainer review
  rule (admin may merge their own PR after CI + checklist review, until a
  second maintainer joins), Dependabot rule.
- `.github/PULL_REQUEST_TEMPLATE.md` — the actual template a PR body must
  fill: Purpose, Scope, Files Changed, Architecture Impact, Database Impact,
  Security/Privacy Impact, UI/UX Impact, Testing, Rollback Plan, Future Work.

## Checks to run before calling something PR-ready

1. **Scope**: one coherent change per branch/PR — no mixing product
   features, schema changes, formatting, and unrelated cleanup
   (`CONTRIBUTING.md`).
2. **Local checks green**: `dart format .`, `flutter analyze`,
   `flutter test` — all three, not a subset, before opening/updating.
3. **Architecture gate**: no Supabase migrations, schema changes, new
   repositories, or persistence logic for a gated module unless its
   PRD/SRS/architecture/role-matrix/DB-design are approved (cross-check with
   [[architecture-review]]).
4. **PR template fully filled**: especially Database Impact and
   Security/Privacy Impact — "No database impact" is a valid answer, an
   empty section is not.
5. **DoD checklist**: run through `DEFINITION_OF_DONE.md` section by
   section — don't just eyeball the diff.
6. **Rollback plan is concrete**: "revert the PR" is acceptable for pure
   UI-local-flow work; anything touching schema or RLS needs a real answer.

## Workflow

1. Read the actual diff (`git diff`/`gh pr diff`), not just the branch name
   or commit messages, before drafting the PR body.
2. Fill every section of `.github/PULL_REQUEST_TEMPLATE.md` — don't
   summarize outside its structure.
3. Cross-check touched paths against
   `.github/ci/architecture_guard_paths.txt` and flag if CI is likely to
   block the PR, before the human is surprised by a red check.
4. Never propose `--no-verify`, force-push, or skipping required reviews to
   get a PR merged faster — if CI is red, fix the underlying issue.
