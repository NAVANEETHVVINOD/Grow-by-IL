# CI/CD Pipeline Map

This document outlines the current continuous integration (CI) workflows, identifies duplicates and overhead, and details the consolidation roadmap for a unified release pipeline.

---

## 1. Existing Workflows

### 1.1 Grow~ CI/CD
- **File Name**: `ci.yml` (located at `.github/workflows/ci.yml`)
- **Trigger**:
  - `push` to `main` and tag `v*`
  - `pull_request` to `main`
- **Jobs Executed**:
  - `quality_gate`: Installs dependencies (`flutter pub get`), runs static analysis (`flutter analyze`), checks code formatting (`dart format --set-exit-if-changed .`), and runs the unit test suite (`flutter test`).
  - `build_android` (depends on `quality_gate`): Builds the release APK on Ubuntu using dummy Firebase fallback credentials and Supabase secrets, uploading the resulting `app-release.apk` as a build artifact.
  - `release` (depends on `build_android`): Triggered only on tag pushes `v*`, downloads the release APK and publishes it as a GitHub release.
- **Expected Runtime**: 10–12 minutes total (due to Android Gradle compilation).

### 1.2 Schema Contract Check
- **File Name**: `schema_check.yml` (located at `.github/workflows/schema_check.yml`)
- **Trigger**:
  - `push` to `main` and `feature/**`
  - `pull_request` to `main`
- **Jobs Executed**:
  - `schema-contract`: Checks DTD and files for deprecated/invalid Postgres column names, and asserts valid event status enum values using grep/grep-rn scans.
- **Expected Runtime**: ~1 minute.

### 1.3 Dependabot Auto-Merge
- **File Name**: `dependabot-automerge.yml` (located at `.github/workflows/dependabot-automerge.yml`)
- **Trigger**: `pull_request`
- **Jobs Executed**: Merges Dependabot PRs automatically once tests pass.
- **Expected Runtime**: ~30 seconds.

---

## 2. Duplicate Checks and Overhead
1. **Runner Overhead**: Both `ci.yml` and `schema_check.yml` run independently on `pull_request` to `main`. This triggers two separate VM runners checksout, fetching repository code twice.
2. **Analysis/Scans**: The lint check (`dart format`) and static analysis (`flutter analyze`) are ran locally or in `ci.yml` but schema-related lints are run separately in `schema_check.yml`.
3. **Workflow Fragmentation**: Triggers are split (`feature/**` only runs schema check; `main` runs both), which can allow linter or compilation failures to bypass gating until a PR is merged or opened.

---

## 3. Recommended Consolidation Architecture

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
