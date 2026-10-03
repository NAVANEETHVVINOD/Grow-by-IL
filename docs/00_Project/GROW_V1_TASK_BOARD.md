# Grow V1 delivery board

Status: Draft evidence-based execution queue; not release approval
Owner: Project coordinator
Version: 1.2
Last updated: 2026-10-03
Depends on: [Current baseline](CURRENT_PROJECT_BASELINE.md)

This is the single current queue. Historical roadmaps remain reference records.
Use existing issues and PRs; this baseline adds no new product phase or Manufacturing
Task implementation. Completion requires actual outputs and relevant checks, rather
than a chat approval or a green badge on another revision.

## Active goal: P0-03 investigation

User-authorized scope: current evidence and diagnosis only. No implementation,
push, merge, PR/settings mutation, production Supabase change or product feature work.
This section tracks the active goal in the existing queue; it is not a second roadmap.
Markers: `✓` completed; `-` working; `✗` failed/blocked; blank not started.
A completed diagnosis does not mean its underlying CI problem is fixed.

| Status | ID / task | Owner | Depends on | Evidence / next action |
| --- | --- | --- | --- | --- |
| ✓ | G01 Read handoff, create goal and confirm scope | Coordinator | User request | Native goal created; P0-03 investigation only |
| ✓ | G02 Refresh heads/checks/reviews/protection/mergeability | Coordinator + agents | G01 | Exact heads unchanged; 11 open PRs, no reviews; protections checked; all mergeable, #123/#124 check-blocked |
| ✓ | G03 Diagnose #100/#115 missing checks and reconcile stacks | Evidence explorer | G02 | Quality CI excludes both feature-branch bases; parent/child ancestry current and conflict-free; no fix applied |
| ✓ | G04 Diagnose #123 Android Production Build | PR auditor | G02 | PR-merge build log associated with the current head proves AGP 9 / legacy Kotlin plugin conflict; no fix applied |
| ✓ | G05 Diagnose #124 Quality Gate | Security/evidence reviewer | G02 | Dart 3.11.5 cannot resolve riverpod_lint 3.1.9; other SDK/API major migrations identified; no fix applied |
| ✓ | G06 Compare main/RC5 and feature-only work | Coordinator | G02 | Fresh GitHub compare: RC5 ahead 16 / behind 0; feature work remains in active PRs |
| ✓ | G07 Inspect #121/local docs reconciliation readiness | Coordinator | G02 | Current remote b8b4ecf is ancestor of local e90e0a8; one docs/ignore-only commit; publication unauthorized |
| ✓ | G08 Identify exact next P1-01 security action | Coordinator | G02 | Read-only connection/catalog reconciliation, then staging negative authorization tests; live status unverified |
| ✓ | G09 Independently review findings and local board/report QA | Agents + coordinator | G03–G08 | Cross-reviews passed after tested-merge/event-propagation/deployment-wording corrections; local links and scope passed |
| ✓ | G10 Finalize diagnosis, evidence and next-command handoff | Coordinator | G09 | Reviewed evidence finalized for local commit; 16 links, exact docs scope and staged whitespace passed; no remote publication |

Underlying verification problems remain open: `✗` #100/#115 missing quality/build
checks; `✗` #123 Android build failure; `✗` #124 dependency resolution failure and
skipped build. Remote documentation backup is unverified and publication is not
authorized. Detailed evidence and the proposed fix plan are in the
[P0-03 investigation](../05_DevOps/P0_03_CI_INVESTIGATION.md).

## This pass: task status and next five actions

| ID / task | Owner | Dependency | State | Output / evidence | Review / QA | Next action |
| --- | --- | --- | --- | --- | --- | --- |
| P0-01 Preserve documentation | Coordinator + security reviewer | Publication review | Local accepted; remote waiting | Blanket ignore removed; 107 historical MD copied, five sanitized, two private records excluded; nine existing public docs retained; local commit created | Scoped publication review and local checks passed, with preserved historical whitespace exception below | Obtain publication authorization for existing #121 path, then verify remote backup and current CI |
| P0-02 Establish baseline | Evidence explorer + PR auditor | Repository read access | Accepted locally | Exact branch/PR SHAs, current CI, approvals and conflicts in baseline | Independent evidence review passed; governance navigation findings corrected | Use this baseline for the next executable slice; refresh remote state before external actions |
| P0-03 Restore truthful PR verification | Coordinator / CI owner | P0-02 | ✓ Investigation complete; ✗ CI problems remain | Exact missing-check/toolchain/SDK causes documented in investigation | Independent diagnosis review and local docs QA passed; fixes not implemented; no hosted success claimed | Next engineering task requires separate correction-plan authorization |
| P1-01 Close security foundation | Security owner | Baseline + private remediation | Waiting | #88, non-sensitive backend baseline; deployment unverified | Live security acceptance unverified | Review exact private remediation and safe environment, then verify RLS/role/membership negative paths |
| P1-02 Complete identity acceptance | Auth owner + QA | Security foundation, #108 | Waiting | #108 quality/debug success; #110/#112/#113/#120 remain open | Provider, persistence and real-device acceptance unverified | Test existing auth code before expansion; supply test environment/provider/device prerequisites when needed |

P0-01 objective: make reviewed documentation visible to Git without publishing private
security evidence or artifacts. Files: `.gitignore`, copied historical Markdown,
`docs/README.md`, this board, baseline, governance and the later Work Request delta.
Implementation: copy reviewed originals, redact public copies, remove blanket ignore,
retain narrow exclusions. QA: provenance, redaction, inclusion/exclusion, tracked-path
allowlist, current links, whitespace and independent review. Security: no RLS or
production changes. Acceptance: reviewed local commit plus authorized, verified remote
publication for off-machine backup. The local portion and remote portion are distinct.

P0-02 objective: identify actual done/partial/open work. Evidence sources: GitHub read
APIs, local Git/source, approval log, supplied history and read-only subagents. Acceptance:
exact head and event-context checks; conflicting claims marked; no assumed approval.
No application or production writes are needed. No old CI result passes a new revision.

P0-03 objective: make missing/failed verification actionable. Inspect failed steps and
phase-guard paths, keep applicable guard and real test gates, resolve parent stacks,
then rerun actual current-source checks and inspect hosted results after authorized
push. #109's check-name alignment appears configured, but issue closure needs owner
review; do not recreate it. Acceptance: applicable required jobs really execute and
succeed on the intended revision/event. Missing/skipped checks fail this acceptance.

P1-01 objective: prove server authority, grants, RLS, account role and project membership
boundaries. Use [backend gate](../03_Database/BACKEND_SECURITY_BASELINE.md) and
[role contract](../03_Database/ROLE_AND_POSITION_CONTRACT.md). Test own/cross-user data,
role elevation denial, membership assignment, privileged functions and ordinary flows.
Blocker: approved private remediation/deployment and real test-environment evidence.
Do not execute old migrations blindly or expose private findings publicly.

P1-02 objective: prove account created → email confirmed → intentional sign-in → minimum
profile persisted → Home, including retry/reset/used-link/cold-restart paths. Use the
[provider checklist](../03_Database/AUTH_PROVIDER_RELEASE_CHECKLIST.md) and
[profile gate](../02_Product/PROFILE_ECOSYSTEM_DECISION_GATE.md). Acceptance: current
code checks, real permitted backend and exact APK/device journeys. Configuration,
SMTP and connected device evidence must be collected when this slice runs.

## Remaining tasks in dependency order

These are the existing delivery phases, not new approval phases. Every slice updates
its affected contract and this board; do not generate another parallel roadmap.

| Status | Phase | Task / existing issue or PR | Depends on | State / acceptance evidence still required |
| --- | --- | --- | --- | --- |
| ✗ | 0 | PR hygiene: #80/#90/#99/#100/#103/#108/#115/#121 and #122–#124 | Baseline | Planned; review actual diffs, fix missing/failed checks, resolve stacks, verify before any authorized merge |
|  | 0 | Historical docs: #72/#73/#74/#75/#76 | Preservation | Planned; reconcile unique content and stale policy without deleting recoverable work |
|  | 1 | Security/auth: #88/#108/#110/#112/#113 | Test environment | Waiting; production authority, verified providers, callback/profile persistence and Android acceptance |
|  | 2 | Penpot/design: #101, navigation #92/#99/#100, identity #103 | Identity boundaries | Partial; actual pages 00–18, prototype/state/accessibility/token parity evidence |
|  | 3 | Profile/storage/core positions: #102/#104/#120 | Security + privacy decisions | Partial; real ownership/visibility, scoped assignments, storage RLS, profile persistence and deep-link tests |
|  | 4 | Product/Work Request reconciliation: #93/#95/#70/#71 | Recorded decisions + category inputs | Waiting; revised contract resolves eligibility, states and routing without widening prior approvals |
|  | 4 | Real Work Request and data honesty: #85/#77/#78/#79 | Approved API/schema + security | Local/mock only; real create/list/detail/history, negative RLS, atomic cancellation, offline/errors and Android E2E |
|  | 5 | Manufacturing Task: #69 | Real Work Request + handoff contract | Not started in this pass; separate requirements/contract, authorization and audited execution |
|  | 6 | Machine Queue + booking | Manufacturing + booking/operator/catalog rules | Waiting; real availability, concurrency and operator authorization tests |
|  | 7 | Machines + maintenance | Verified catalog + scoped ownership | Waiting; current asset/safety/maintenance data and audited state changes |
|  | 8 | Inventory/borrowing/returns/fines: #97 | Verified stock/prices + approved rules | Waiting; provenance, movement reconciliation, return verification and cross-user tests |
|  | 9 | Projects/membership: #98; lab presence/visitors: #96 | Scoped roles + approved operations | Partial; creator approval, private join-code handling, manual presence/after-hours and audit tests |
|  | 10 | Events/attendance/certificates: #87 | Ownership + payment contract | Partial; real capacity, atomic seat confirmation, attendance/certificate evidence |
|  | 11 | Quotation/payment/billing: #87/#97 | Charge/refund/pricing decisions | Waiting; verified payment events, idempotency, refunds and auditable reconciliation |
|  | 12 | Reports/exports/audit | Real operational records | Waiting; authorized outputs, history integrity, privacy and export tests |
|  | 13 | Super Admin/operational hardening: #104/#84 | Server permissions + delivery config | Waiting; safe admin operations, real release configuration/signing, no placeholder production APK |
|  | 14 | Android/backend E2E/accessibility/offline: #81/#86; scale/recovery: #89 | Real vertical slices | Waiting; real environment/device journeys, load, backup/restore, retention and accessibility evidence |
|  | 15 | Pilot 25–50 | All required release checks + support owner | Waiting; signed build, onboarding/support/escalation and monitored acceptance |
|  | 16 | Expand toward 4,000+ | Successful pilot + capacity/recovery evidence | Waiting; measured staged expansion and operational ownership |
|  | Maintenance | CI actions #91, staged SDK migration #114, bot PRs #122–#124 | Actual failure evidence and pinned sources | Planned; focused updates with current-source tests, no bundled major upgrade for convenience |

## Decisions already recorded

- Machine and Operations requests are submitted separately to their respective heads.
- Both may be cancelled directly before the responsible head takes/reviews them.
- Afterward, the requester provides a reason; the head approves or denies. Pending or
  denied cancellation preserves work status. Implement the cutoff atomically server-side.
- Operations Head approves updated stock and prices; actual values are still awaited.
- Students request/book work; Machine Heads operate fabrication machines. The detailed
  booking/safety contract remains open.
- Work Request, Manufacturing Task and Machine Queue remain separate modules.

See [Work Request delta](../02_Product/WORK_REQUEST_CONTRACT_DELTA.md). No new cancellation
question is required. Exact V1 categories, charge/quote mapping, refunds, verified
catalog/current prices and named pilot support are still unresolved at their entry gates.

## Operating rules and blockers

Reviewed non-sensitive docs are tracked by default. Private evidence and raw artifacts
stay excluded. Off-machine backup is incomplete until an authorized push is verified.
Use existing #121 for docs reconciliation; avoid another competing planning PR.

Preserve dirty original worktrees. Never infer a direct-commit violation from first-parent
history alone. No PR closure, merge, deployment, remote-setting change or production
migration is authorized by a board status. Current AGENTS requires independent review
before merge; GitHub currently enforces zero approvals. Historical pasted preferences
conflict with this instruction and are recorded in the baseline without changing policy.

Do not invent prices, users, stock, machine availability, payments or test results.
Passing compile/unit/widget checks do not prove a live backend or Android journey.
Private security disclosure, provider/SMTP configuration, exact-build phone acceptance,
Penpot connection and owner-supplied catalog/pricing/support inputs remain separate gates.
Do not ask for all future-phase answers before independent foundation work can proceed.

## Verification of this documentation slice

- Passed: hash comparison of 101 unchanged historical copies; five sanitized copies
  and one governance amendment account for the other six preserved files. Two private
  historical documents are absent from the publication set. The current contract delta
  exactly matches the original local decision snapshot.
- Passed: 15 current navigation links; four public-path inclusion checks; six private/
  raw-artifact exclusion checks. The staged 112 changed paths are confined to Markdown
  under `docs/` and `.gitignore`. No application/runtime source changed.
- Passed: independent scoped publication/security review of actual copies and independent
  PR/evidence review of baseline facts. Documentation review found two governance
  navigation/link issues, which the coordinator corrected.
- Passed: strict `git diff --cached --check` on current ignore/README/baseline/board/delta.
  Default full staged whitespace check flags retained historical trailing spaces and
  blank EOF lines. Historical copies intentionally retain their original bytes, including
  Markdown hard breaks. `git -c core.whitespace=-blank-at-eol,-blank-at-eof diff --cached
  --check` passes for the complete change. This explicit preservation exception is not
  a clean default-whitespace claim.
- Not run: Flutter/build/backend/device tests, because this slice changes documentation
  and Git inclusion only. No product gate is cleared by this docs review.
- Unverified: hosted CI for this new revision, off-machine backup, live security,
  provider/SMTP behavior, Android acceptance and Penpot. No remote write was performed.
