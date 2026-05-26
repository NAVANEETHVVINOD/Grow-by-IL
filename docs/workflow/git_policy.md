# Grow~ Git Workflow & Branch Governance Policy

## Protected Branches

### main

Purpose:

* Production-ready code only

Rules:

* No direct push
* No force push
* Require PR
* Require CI checks
* Require at least 1 approval
* Dismiss stale approvals
* Require branch up-to-date before merge
* Restrict deletion

Required checks:

* flutter analyze
* flutter test
* flutter test integration_test/
* dart format --set-exit-if-changed .
* flutter build apk --debug
* flutter build apk --release
* Secret scan
* Dependency scan

Merge strategy:

* Squash only

Commit naming:

feat(module): ...
fix(module): ...
chore(module): ...
docs(module): ...

---

## Development Branch Structure

main
└── rc5-release
    ├── feature/profile-sync
    ├── feature/onboarding
    ├── feature/opportunities
    ├── feature/vouch-system
    ├── fix/navbar-overflow
    ├── docs/schema-update

Rules:

Feature branch:

* One feature only
* Short-lived
* Delete after merge

Release branch:

* Collect approved features
* Run validation
* Merge to main only after release verification

---

## PR Requirements

PR template:

Summary:
Changes:
Screens affected:
Database changes:
Migration changes:
Testing performed:
Rollback strategy:
Risk level:

Checklist:

[ ] flutter analyze passed
[ ] flutter test passed
[ ] integration tests passed
[ ] release APK builds
[ ] docs updated
[ ] schema updated
[ ] migration tested
[ ] screenshots attached
[ ] no secrets committed

---

## Branch Cleanup Rules

Delete automatically after merge:

feature/*
fix/*
docs/*

Keep:

main
rc5-release
release/*
hotfix/*

Archive:

release history tags
RC4
RC5
RC6
