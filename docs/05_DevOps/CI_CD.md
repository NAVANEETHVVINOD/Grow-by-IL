# Grow~ CI/CD: PR Flow, Current Checks, Branch-Policy Status

Status: Draft (Pending Review)
Owner: Lead Architect / DevOps Owner
Version: 1.0
Last updated: 2026-09-01
Depends on: `/BRANCH_PROTECTION.md`, `docs/05_DevOps/ci_pipeline_map.md`, `docs/05_DevOps/git_policy.md`
Referenced by: `docs/00_Project_Management/MASTER_INDEX.md`

> **Authoritative Version Pointer**: Workflow-level detail and consolidation
> history live in `docs/05_DevOps/ci_pipeline_map.md`. This doc is the
> current-state reference: what actually happens on a PR today, and what
> GitHub itself reports as branch protection (verified via `gh api`
> 2026-09-01, not copied from an older doc).

## 1. PR Flow (as actually configured, not aspirational)

1. Branch off `rc5-release-candidate` (the active integration branch) using
   `feature/*`, `fix/*`, or `chore/*` naming (`/CONTRIBUTING.md`).
2. Push, open a PR targeting `rc5-release-candidate` (or `main`/`develop` —
   `ci.yml` triggers on all three).
3. `.github/workflows/ci.yml` runs one job, `quality_gate` (job display name
   "Quality Gate"), which in order: installs deps, verifies `pubspec.lock`
   sync, format check, `flutter analyze`, `flutter test`, an architecture
   phase guard, a schema contract validation step, and secret-scan steps
   (`Secret scan`, `Gitleaks secret scan`).
4. Two more jobs, `debug_build` ("Debug APK Build") and `release_build`
   ("Release APK Build"), build APKs.
5. At least 1 approving review required on PRs targeting `main` (see
   Section 2). Squash merge only (`/CONTRIBUTING.md`).
6. `.github/workflows/dependabot-review.yml` separately labels and gates
   Dependabot PRs — auto-merge is intentionally off (see
   `docs/05_DevOps/ci_pipeline_map.md` Section 1.2).

## 2. Branch Protection — Verified Current State (2026-09-01)

Pulled directly via `gh api repos/NAVANEETHVVINOD/Grow-by-IL/branches/<branch>/protection`, not from a prior doc:

### `main`
- Required approving reviews: **1**, stale reviews dismissed on new pushes.
- `enforce_admins`: **true** (protection applies to admins too).
- Force pushes: **blocked**. Branch deletion: **blocked**.
- Required status checks (strict — branch must be up to date), contexts:
  `flutter analyze`, `flutter test`, `flutter test integration_test/`,
  `dart format`, `flutter build apk --debug`, `flutter build apk --release`,
  `Secret scan`, `Dependency scan`.

> **Flagged mismatch, not fixed here (governance decision, not mine to make):**
> those 8 required-check *context strings* don't match any job name the
> current `ci.yml` actually reports. The live workflow has exactly three
> job-level names: `Quality Gate`, `Debug APK Build`, `Release APK Build`
> (verified by reading the job `name:` keys in `.github/workflows/ci.yml`).
> The 8-name list matches `docs/05_DevOps/git_policy.md`'s "Required checks"
> section almost verbatim, suggesting the branch-protection rule was
> configured against an older, more granular workflow structure and never
> updated when the workflow was consolidated (see
> `docs/05_DevOps/ci_pipeline_map.md`'s 2026-09-01 correction note). Whether
> GitHub is currently blocking merges on checks that never report, or
> silently treating them as satisfied, needs a human to check directly on
> an open PR (e.g. #64) rather than inferred here — flagged, not verified
> further, and *not* changed, per instruction not to modify protection rules.

### `rc5-release-candidate`
- **Not protected at all** — `gh api` returns `404 Branch not protected`.
  Direct pushes, force pushes, and deletion are all technically possible
  despite this being the active integration branch that PRs merge into.
  This contradicts an assumption carried in earlier session notes that it
  was "protected (PR-only, no direct pushes)" — that assumption was wrong
  as of this check and should not be relied on going forward.

## 3. What This Doc Does Not Do

Does not change any branch protection rule — reporting only, per explicit
instruction. Any fix to the required-check mismatch above, or to
`rc5-release-candidate`'s lack of protection, is the repo owner's call.
