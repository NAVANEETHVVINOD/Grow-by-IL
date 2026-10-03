# CI/CD Pipeline Map

Status: Draft (no prior approval on record — flagging status rather than asserting one)
Last updated: 2026-09-01
Depends on: `/BRANCH_PROTECTION.md`, `docs/05_DevOps/git_policy.md`

This document outlines the current continuous integration (CI) workflows and the history of how they were consolidated. For the canonical PR-flow + branch-policy reference, see the new `docs/05_DevOps/CI_CD.md`; this file keeps the workflow-level detail and consolidation history.

> **2026-09-01 correction:** The two-workflow overhead this doc originally
> flagged (`schema_check.yml` duplicating `ci.yml`, plus a separate
> `dependabot-automerge.yml`) was already fixed — commit `e6804ee`
> ("ci: consolidate workflows into a single pipeline, remove schema_check
> duplicate") merged the schema check into `ci.yml`'s quality gate, and
> `dependabot-automerge.yml` was replaced by `dependabot-review.yml`, which
> does the opposite of auto-merge: it labels Dependabot PRs and explicitly
> requires human + CI review. Section 1 below now describes what's actually
> in `.github/workflows/` today; Section 2/3's "recommended consolidation"
> is kept as historical record of the reasoning, since it's what actually
> happened.

---

## 1. Existing Workflows

### 1.1 Grow~ CI/CD
- **File Name**: `ci.yml` (located at `.github/workflows/ci.yml`)
- **Trigger**:
  - `push`/`pull_request` to `main`, `develop`, `rc5-release-candidate`, tag `v*`
  - `workflow_dispatch`
- **Jobs Executed**:
  - `quality_gate`: Installs dependencies (`flutter pub get`), verifies `pubspec.lock` is in sync, checks formatting (`dart format --set-exit-if-changed .`), runs static analysis (`flutter analyze`), runs the unit/widget test suite (`flutter test`), and runs an architecture-phase guard plus the schema contract checks that used to live in the now-removed `schema_check.yml`.
  - `build_android` (depends on `quality_gate`): Builds debug and release APKs.
  - `release` (depends on `build_android`): Triggered only on tag pushes `v*`, publishes the release APK as a GitHub release.
- **Expected Runtime**: 10–12 minutes total (due to Android Gradle compilation).

### 1.2 Dependabot Review Gate
- **File Name**: `dependabot-review.yml` (located at `.github/workflows/dependabot-review.yml`)
- **Trigger**: `pull_request`, gated to `github.actor == 'dependabot[bot]'`
- **Jobs Executed**: `label_dependabot` — labels the PR `dependencies` and posts an explicit note that Dependabot auto-merge is intentionally disabled; Flutter/Android/Firebase/Supabase/Actions updates still require CI plus human review.
- **Expected Runtime**: ~30 seconds.

---

## 2. Duplicate Checks and Overhead (historical — resolved)
1. ~~**Runner Overhead**: Both `ci.yml` and `schema_check.yml` ran independently on `pull_request` to `main`.~~ Resolved by commit `e6804ee`; schema checks now run inside `ci.yml`'s `quality_gate` job, single checkout.
2. ~~**Analysis/Scans split across two workflows.**~~ Resolved — all lint/analyze/test/schema checks are one job.
3. ~~**Workflow Fragmentation** (`feature/**` only ran schema check; `main` ran both).~~ Resolved — one workflow, one trigger set.

---

## 3. Consolidation Architecture (implemented)

A single orchestrated workflow (`release_gate.yml`) should handle the entire pipeline sequentially:

```mermaid
graph TD
    Trigger[PR or Push Trigger] --> Checkout[actions/checkout]
    Checkout --> QualityGate[Quality Gate]
    
    subgraph QualityGate ["Quality Gate (Parallel Checks)"]
        Format["Format Check & Lints"]
        Analyze["Static Analysis (flutter analyze)"]
        Test["Unit & Widget Tests (flutter test)"]
        Schema["Schema Contract Check"]
        Secrets["Secret Scan (TruffleHog)"]
        Deps["Dependency Scan (OWASP / OSV)"]
    end
    
    QualityGate --> BuildGate{Build Needed?}
    BuildGate -- Yes: Push/PR -- > BuildAndroid[Build APKs debug & release]
    BuildGate -- No: Feature push -- > Done[Pipeline Success]
    
    BuildAndroid --> ReleaseGate{Tag v* Push?}
    ReleaseGate -- Yes -- > GitHubRelease[Publish GitHub Release]
    ReleaseGate -- No -- > Done
```

### Proposed Consolidated Pipeline Stages
1. **Quality Gate Job**:
   - `dart format --set-exit-if-changed .`
   - `flutter analyze`
   - `flutter test`
   - **Schema Contract Scan** (repurposed from `schema_check.yml`)
   - **Secret & Dependency Scan** (TruffleHog/OWASP checker)
2. **Build Job** (Runs on PR/Push to Main, depends on Quality Gate):
   - Builds Debug APK (`flutter build apk --debug`)
   - Builds Release APK (`flutter build apk --release`)
3. **Optional Integration Job** (Can run manually or on target releases):
   - Firebase Test Lab run or physical device emulator suite checks.
4. **Publish Release Job** (Runs on `v*` tag push):
   - Publishes build artifact directly to GitHub Releases.
