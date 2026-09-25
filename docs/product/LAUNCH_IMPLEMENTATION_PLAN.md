# Grow launch implementation plan

Status: Draft for product-owner review, 16 September 2026. This is a delivery
plan, not approval of new business rules or proof that a feature is complete.
Use [current owner decisions](APPROVED_DECISIONS.md) for the intended product and
the [launch audit](../audits/LAUNCH_READINESS.md) for observed gaps. Recheck the
code, environment, and issue state at the start of each PR.

## Delivery rule

The initial 25–50-person rollout is a **real, supervised pilot**, not a mock
product. It must use genuine identity, authorization, operational records, and
payment verification for every enabled workflow. Expand toward 4,000+ users
only after capacity, recovery, and privacy tests pass. A missing inventory,
policy, or credential blocks its dependent workflow; it is never filled with
sample data in production.

For every operational module, follow the approved `MODULE_LIFECYCLE.md` gate
order: planning and owner-approved requirements; implementation contract; UI
and local flow; reviewed DB architecture and RLS; repository/API and sync;
tests; production. Its current Phase 1 guard stops new operational modules at
UI/local flow; a reviewed phase transition is needed before database work.
Work Requests, Manufacturing Tasks, and Machine Queue are separate modules
with separate approvals. An issue title or a green compile is not permission
to skip a gate. Keep each code PR small enough to review and attach its
requirements, tests, rollback, and environment evidence.

## Ordered task list

| Order | Work package and existing tracker | Concrete output / acceptance gate |
| --- | --- | --- |
| 0 | Align product source of truth: [#95](https://github.com/NAVANEETHVVINOD/Grow-by-IL/issues/95), [#93](https://github.com/NAVANEETHVVINOD/Grow-by-IL/issues/93), [#70](https://github.com/NAVANEETHVVINOD/Grow-by-IL/issues/70), [#71](https://github.com/NAVANEETHVVINOD/Grow-by-IL/issues/71) | Owner reviews the charter, backlog, feature inventory, ADR-006, roles, external-user access, and Work Request transitions against the latest decisions. The requirements and contract for each affected module have one unambiguous version. Do not let old “college email only” or “external mobile user deferred” language drive new code. |
| 1 | Establish truthful, buildable baseline: draft PR [#90](https://github.com/NAVANEETHVVINOD/Grow-by-IL/pull/90), [#84](https://github.com/NAVANEETHVVINOD/Grow-by-IL/issues/84), [#85](https://github.com/NAVANEETHVVINOD/Grow-by-IL/issues/85), [#91](https://github.com/NAVANEETHVVINOD/Grow-by-IL/issues/91) | Independently review overlapping PRs, merge only current-head green work, require real protected release configuration and signing, remove or disable fabricated member-visible records/actions, and keep CI/security scans active. Debug-fixture builds are not release evidence. |
| 2 | Prove identity and trust boundaries: PR [#82](https://github.com/NAVANEETHVVINOD/Grow-by-IL/pull/82), [#88](https://github.com/NAVANEETHVVINOD/Grow-by-IL/issues/88), [#81](https://github.com/NAVANEETHVVINOD/Grow-by-IL/issues/81) | Any-email sign-in, mandatory role-appropriate onboarding, head appointment only by super admin, authenticated profile visibility, and negative authorization/RLS tests on a reachable backend. Optional enrichment must not block entry. Physical-device sign-in and recovery must be tested before enabling the flow broadly. |
| 3 | Finalize the three-destination experience: [#92](https://github.com/NAVANEETHVVINOD/Grow-by-IL/issues/92) | Approved navigation map and original neo-brutalist Home, Lab, Profile flows for member and heads; requests, projects, events, and institution information have clear homes. Remove Akathalam, misleading live-status cards, and copied content. Validate loading, empty, error, accessibility, English copy, and reduced motion on Android. |
| 4 | Make lab presence and safety real: [#96](https://github.com/NAVANEETHVVINOD/Grow-by-IL/issues/96) | Approve a presence contract for manual-first check-in/out, optional door QR, current room capacity, ordinary/after-hours head presence, safety acknowledgement, and checkout notification. Then implement server-enforced sessions and audit history; test duplicate check-ins, stale sessions, offline retry, and head departure. Do not infer actual Wi-Fi, power, occupancy, or authorization from static UI. |
| 5 | Make requests and machine work real: [#69](https://github.com/NAVANEETHVVINOD/Grow-by-IL/issues/69), [#79](https://github.com/NAVANEETHVVINOD/Grow-by-IL/issues/79), [#77](https://github.com/NAVANEETHVVINOD/Grow-by-IL/issues/77) | Keep Work Requests, Manufacturing Tasks, and Machine Queue separate. Finalize routing (machine-related to Machine Head; other work to Operations), field/validation rules, time estimates, quotes, approvals, actual usage, and machine-operation permissions. Replace mock data only after schema/RLS approval; test requester/head/admin views and lifecycle transitions. Inventory-dependent selections wait for the real catalog. |
| 6 | Inventory, borrowing, and non-event billing: [#97](https://github.com/NAVANEETHVVINOD/Grow-by-IL/issues/97) | Receive and validate the lab's machine/tool/component list and room mapping, then approve import, booking, availability, return, warning, configurable ₹10/day default fine, and Operations verification contracts. Record quotes, UPI reference/proof, payment review, adjustments, and audit history. No auto-fine or financial write is enabled before the policy and clock are verified. |
| 7 | Projects and community: [#98](https://github.com/NAVANEETHVVINOD/Grow-by-IL/issues/98) | Approve public/private visibility, creator-only membership approval, code-to-join request, member profiles, and core review for lab support as distinct workflows. Implement discovery and team onboarding with access tests; private projects and join codes must not leak to unrelated members. |
| 8 | Events, capacity, and refunds: [#87](https://github.com/NAVANEETHVVINOD/Grow-by-IL/issues/87) | Events Head owns paid/free registrations, reasoned cancellation requests, UPI verification, refunds, attendance, and audit. Pending payment holds no seat. Confirm the last seat atomically on the server; close a full event; record and resolve payment received after sell-out. Test concurrency, duplicate transaction IDs, and role separation from Operations billing. |
| 9 | Reports, privacy, and operational readiness: [#89](https://github.com/NAVANEETHVVINOD/Grow-by-IL/issues/89) | Deliver verifiable usage, project, event, machine, inventory, and financial exports with access controls. Approve field inventory, notice, exact academic-year cutoff, one-year anonymized operational retention, personal-data handling, and required financial exceptions. Document backups and pass a restore drill. |
| 10 | End-to-end and rollout gate: [#86](https://github.com/NAVANEETHVVINOD/Grow-by-IL/issues/86), [#94](https://github.com/NAVANEETHVVINOD/Grow-by-IL/issues/94) | On a signed Android build and real staging backend, run member, head, and admin journeys, permission-denial cases, offline recovery, paid-seat races, and data restore. Pilot with 25–50 real users and triage defects; load-test agreed peak patterns for 4,000+ accounts before expansion. Revisit the review rule only when the E2E check is enforced and the exact PR head passes it. |

These are dependency bands, not permission to hold all UI work until every
backend module is finished. Within a band, use one focused issue/PR per
approved contract or independently testable change. Research, design, and
read-only audits may proceed in parallel without claiming implementation.

## PR and release gates

- Confirm the PR base and exact head, current required checks, independent
  review, and unresolved threads. Re-run tests after rebasing or merging a
  changed base. Overlapping PRs must be reconciled rather than merged twice.
- For mobile behavior, a debug APK build is not Android E2E. For backend or
  payment behavior, unit/widget tests are not RLS, concurrency, or real-service
  evidence. Attach results for the changed boundary.
- A launch candidate needs a signed artifact with real configuration, no
  fabricated runtime state, an authorized-device test, release rollback path,
  monitoring, privacy notice, tested backup/restore, and owner sign-off.
- The final app name, visual assets, machine/tool/component spreadsheet,
  approved price schedule, UPI account details, and academic-year boundary are
  external inputs. Keep dependent work blocked and visible until supplied;
  never encode guessed values as production defaults.

## Immediate next action

Review [#95](https://github.com/NAVANEETHVVINOD/Grow-by-IL/issues/95) and
[#93](https://github.com/NAVANEETHVVINOD/Grow-by-IL/issues/93) with the product
owner so current access/scope decisions become the canonical requirements.
In parallel, obtain independent review of [PR #90](https://github.com/NAVANEETHVVINOD/Grow-by-IL/pull/90)
and prepare real Android/backend E2E under [#86](https://github.com/NAVANEETHVVINOD/Grow-by-IL/issues/86).
Do not merge the RC5 release PR or weaken branch protection while those gates
are absent.
