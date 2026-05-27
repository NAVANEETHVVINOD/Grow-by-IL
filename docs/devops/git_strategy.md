# Git Workflow and Branch Governance Policy

This document defines the branch governance structure, Git workflow policies, and the current branch state analysis for the Grow~ codebase.

---

## 1. Current Git Repository Branch State

As of May 27, 2026, the active branch topology is summarized below:

### 1.1 Local Branches
- `rc5-release-candidate` *(Current Active working branch)*
- `main` *(Production trunk)*
- `develop` *(Development / Integration trunk)*
- **Feature Branches**:
  - `feature/production-hardening-rc4`
  - `feature/rc2-phase3-tools`
  - `feature/real-device-testing-fixes`
  - `feature/safe-android-updates`
  - `feature/schema-contract-sync`
- **Release Candidates & Refactoring**:
  - `rc5-release`
  - `rc5-stabilization-pass`
  - `rc5-backend-integration`
  - `rc5-foundation-ui-system`
  - `rc5-onboarding-v2`
  - `rc5-profile-migration-phase-a`
  - `rc4.2-stability`
  - `rc4.3-production-stabilization`
  - `rc4.4-release-engineering`
- **Hotfix & UI Branches**:
  - `fix-ui-dropdown`
- **Dependency Updates (Dependabot)**:
  - `dependabot/gradle/android/android-updates-43bcff6fcb`
  - `dependabot/pub/flutter-updates-d3be48ebda`

### 1.2 Remote Branches (`origin/*`)
- `origin/main` *(Target for releases)*
- `origin/rc5-release-candidate` *(Active PR #44 source)*
- `origin/rc5-stabilization-pass`
- `origin/rc5-release`
- `origin/rc4.3-production-stabilization`
- `origin/feature/*` (e.g., `firebase-google-auth`, `rc2-db-foundation`, `schema-contract-sync`, `safe-android-updates`)
- `origin/fix/ci-version-mismatch`
- `origin/dependabot/*`

### 1.3 Active Pull Requests
- **Open PRs**:
  - **PR #44**: `rc5-release-candidate` -> `main` (Release candidate under review)
- **Closed / Stale PRs**:
  - **PR #43**: `rc5-stabilization-pass` -> `main` (Closed/superseded by #44)
  - **PR #42**: `release: RC5 stabilization and feature drop` -> `main` (Closed/superseded by #44)

---

## 2. Branch Governance Rules

To maintain repository cleanliness and ensure high-stability releases, the following branch policies are enforced:

### 2.1 Branch Protection Rules for `main`
The `main` branch represents the production-ready state of the application. It is protected by the following GitHub enforcement rules:
1. **No Direct Pushes**: All commits to `main` must arrive via Pull Requests. Direct push is blocked.
2. **Reviewer Approval**: PRs targeting `main` require at least **one approved review** from the repository Owner / Code Owner before merge.
3. **Required Status Checks**: The unified CI pipeline (`Quality Gate` and `Build`) must pass successfully. Checks include:
   - `dart format`
   - `flutter analyze`
   - `flutter test`
   - `Schema Contract validation`
4. **Squash Merging**: Merging to `main` should use the squash and merge method to keep the main branch history linear and clean.

### 2.2 Standard Branch Naming Conventions
Contributors must prefix branch names according to the nature of their changes:
- `feature/*`: New application features, components, or major capabilities.
- `release/*` (or `rc*`): Stabilization passes and release builds.
- `hotfix/*` or `fix/*`: Critical patches for production bugs.
- `docs/*`: Changes limited strictly to documentation files.

### 2.3 Post-Merge Cleanup Policy
1. **Automated Deletion**: The repository is configured to delete head branches automatically after pull requests are merged.
2. **Manual Cleanup**: Upon merging a release candidate branch (e.g., `rc5-release-candidate`), developers should run:
   ```bash
   git branch -d <branch_name>          # Delete local branch
   git remote prune origin              # Prune local tracking of deleted remote branches
   ```
3. **Stale Branch Pruning**: Any local feature or fix branch older than 14 days without an active PR is classified as stale and should be archived or deleted.
