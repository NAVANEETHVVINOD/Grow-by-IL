# Grow~ Task Tracker

Last updated: 2026-08-02

This is a local-only tracker. The `docs/` folder is intentionally ignored and is
used as the working memory for architecture, product planning, QA notes, and AI
handoffs. GitHub-facing policy files remain at the repo root only when they are
needed by GitHub or contributors.

## Current Status

- Active branch: `rc5-release-candidate`
- Last merged PR: #55 - `feat(rc5): add work request shell and workflow guardrails`
- Last merge commit: `52a8882`
- PR state: merged after green CI under documented solo-maintainer review path
- Local verification: `flutter analyze` pass, `flutter test` pass
- Current delivery mode: architecture-gated incremental implementation

## Current Maturity

- RC4 stabilization: complete enough to preserve as the production base
- RC5 visual/product direction: started
- Enterprise workflow guardrails: merged into `rc5-release-candidate`
- Work Request implementation: UI-only overview slice exists, Create flow paused
- Backend/schema expansion: gated until PRD/SRS and architecture approval

## Completed

### RC4 / RC4.4 Stabilization

- [x] Provider rebuild and realtime instability audit completed
- [x] Home rebuild surface reduced with section-level isolation
- [x] Notification pagination added
- [x] N+1 event RSVP issue fixed
- [x] Dual subscription pattern reduced
- [x] Booking overlap risk identified and backend constraint plan created
- [x] Notification RLS issue identified and backend trigger/RPC direction created
- [x] Release signing configured locally
- [x] Release APK/AAB verified previously
- [x] Google release OAuth/SHA issue investigated/fixed by user-side config
- [x] Unit/widget tests passing locally
- [x] Analyzer passing locally

### RC5 Foundation In Code

- [x] RC5 feature flags added
- [x] RC5 Home screen exists: `rc5_home_screen.dart`
- [x] RC5 Akathalam route/screen exists
- [x] RC5 Profile screen exists: `rc5_profile_screen.dart`
- [x] RC5 Edit Profile hub exists
- [x] Work Requests overview screen exists
- [x] Work Requests route is feature-flagged
- [x] Home quick action can route to Work Requests when enabled
- [x] Existing booking/admin/auth flows preserved by adapter approach

### Enterprise Workflow / Guardrails

- [x] PR-first workflow documented
- [x] `rc5-release-candidate` treated as protected trunk-equivalent
- [x] Direct-to-trunk commits marked as historical exceptions only
- [x] PR template added
- [x] CI Quality Gate includes format, analyze, test, architecture guard, schema contract validation, and secret scans
- [x] Gitleaks scan added and passing in PR #55
- [x] Dependabot auto-merge replaced with review/label workflow
- [x] Architecture guard moved to data file: `.github/ci/architecture_guard_paths.txt`
- [x] Schema contract validation narrowed to changed Dart files to avoid baseline false positives
- [x] PR #55 CI fixed after delimiter bug in architecture guard

## Recently Merged PRs

### PR #55 - Work Request Shell And Workflow Guardrails

- Status: merged
- Checks:
  - [x] Quality Gate passed
  - [x] Debug APK Build passed
  - [x] Gitleaks passed inside Quality Gate
  - [x] Release APK Build intentionally skipped because this is not a tag
- Merge path: documented solo-maintainer review path

## Paused / Not Yet Approved

### Work Request Create Flow

Status: paused.

Reason: the Create flow would encode business rules, field taxonomy, validation,
queue visibility, payment rules, and assignment logic. Those belong in reviewed
PRD/SRS and architecture artifacts before implementation.

Do not build yet:

- [ ] Work Request Create form
- [ ] Work Request repository/data layer
- [ ] Work Request schema migration
- [ ] Manufacturing task queue persistence
- [ ] Payment/quotation logic
- [ ] Machine runtime/cost calculator

## Immediate Next Steps

### 1. Close Phase 1B Requirements Before More Work Request UI

- [ ] Finalize Work Request lifecycle
- [ ] Finalize request category taxonomy
- [ ] Finalize required fields for fabrication requests
- [ ] Finalize file-link policy
- [ ] Finalize student edit/cancel rules
- [ ] Finalize queue visibility boundary
- [ ] Finalize payment/deposit state rules
- [ ] Finalize notification matrix
- [ ] Finalize audit/event log requirements

### 2. Review Local Work Request Contract

- [ ] Review `docs/01_Product/05_WORK_REQUEST_REQUIREMENTS.md`
- [ ] Review `docs/01_Product/06_WORK_REQUEST_IMPLEMENTATION_CONTRACT.md`
- [ ] Approve or revise fabrication-first Create Flow scope
- [ ] Approve or revise payment/deposit lifecycle
- [ ] Approve or revise notification matrix
- [ ] Approve or revise queue visibility boundary

### 3. Architecture Artifacts Still Needed

- [ ] SRS / PRD for operational modules
- [ ] Role and permission matrix
- [ ] Work Request state machine
- [ ] Manufacturing Task state machine
- [ ] Inventory and borrowing lifecycle
- [ ] Machine/equipment model boundary
- [ ] Payment and quotation workflow
- [ ] Reporting/export catalog
- [ ] Navigation map and dashboard blueprint

### 4. Next Safe Implementation Slice

Recommended only after Phase 1B review:

- `feat(work-requests): add fabrication request create flow`

Scope should be UI + local validation only unless schema approval is complete.

## Upcoming Product/Engineering Phases

### Phase 1B - Product Requirements / SRS

- [ ] Convert current product answers into formal SRS
- [ ] Define module boundaries: Work Requests, Machines, Inventory, Borrowing, Visitors, Events, Profiles
- [ ] Define public/private profile fields
- [ ] Define validation rules and acceptance criteria
- [ ] Define non-goals for V1

### Phase 2 - Architecture / ERD / RLS

- [ ] Database ERD
- [ ] RLS matrix
- [ ] Role permission matrix
- [ ] Audit log model
- [ ] Notification model
- [ ] Storage/external-file-link policy
- [ ] Migration rollout strategy

### Phase 3 - UX / Screen Flow

- [ ] Navigation map
- [ ] Dashboard blueprint
- [ ] Work Request flow wireframe
- [ ] Machine Head queue view wireframe
- [ ] Operation Head inventory view wireframe
- [ ] Student request status view wireframe
- [ ] Admin moderation/approval views

### Phase 4 - Engineering

- [ ] Schema migrations
- [ ] Repositories
- [ ] Providers
- [ ] UI forms
- [ ] DB/service tests
- [ ] Smoke tests
- [ ] Device QA

## Risks

- [ ] Scope creep from RC5 UI work into unapproved backend workflow
- [ ] Work Request Create flow encoding unreviewed business rules
- [ ] Root docs vs local docs confusion
- [ ] CI guard becoming too broad or too brittle
- [ ] Reintroducing RC4 rebuild storms through large dashboards
- [ ] Supabase storage pressure if file uploads are added prematurely
- [ ] Payment/accounting workflows becoming ambiguous without SRS

## Known Schema Drift Debt

These were detected by the earlier full-repository schema contract scan. They
are baseline technical debt, not regressions from PR #55, and should be fixed in
a dedicated compatibility/schema cleanup slice.

- [ ] `interests` usage in profile-related Dart code
- [ ] `full_name` usage in auth/profile-related Dart code

## Explicit Non-Goals For Now

- [ ] Direct messaging
- [ ] Live chat
- [ ] GitHub OAuth sync
- [ ] Firebase Cloud Messaging push notifications
- [ ] External/public customer ordering app
- [ ] Marketplace
- [ ] Advanced analytics dashboard
- [ ] Full schema migration without approved ERD/RLS
