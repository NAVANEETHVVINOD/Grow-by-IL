# Grow launch task plan — 2026-09-17

Status: working plan for a production product, not an MVP waiver. This is an evidence-based sequence, not authorization to bypass review, alter live SQL, or replace the product owner's pending inventory/pricing inputs.

## Immediate merge and implementation queue

| Order | Slice | Completion evidence | Current boundary |
| --- | --- | --- | --- |
| 1 | PR #103 truthful profile identity + narrow CI schema-guard repair | CI on exact new head, analyzer/tests, reviewer approval, no invented identity claims | Local workflow patch awaits validation/commit/push; current remote Quality Gate failed. |
| 2 | PR #99 Home → Lab → Profile shell | Exact APK, route/back/selected state, auth gate, unauthorized/offline states, CI and independent review | Existing phone smoke covered signed-in navigation, not signout/login or all failure paths. |
| 3 | PR #100 truthful Home content, rebased after #99 | Combined Android comparison, no fake ticker/opportunities, CI on final base, independent review | Stacked on #99; never merge first or fold unrelated PRs into one. |
| 4 | Issue #95 charter/backlog reconciliation | Reviewed revised charter, role and eligibility decisions, date/version, explicit conflicts closed | Local decision delta is a draft; older approved charter still conflicts. |
| 5 | Repository/live schema and authorization audit | Read-only live snapshot, migration ledger, ordinary-user negative tests; reviewed repair migration | Potential P0 project-members and user-role policy issues in checked-in SQL; deployment unknown. |
| 6 | Penpot 00–18 completion, Page 17 fill, design token approval | Every actual page checked against the page specification, clickable prototype, assets/rights, accessibility and Android comparison | Penpot connection unavailable in this pass; local spec is not the finished design. |
| 7 | Auth/onboarding reliability | Email/Google on-device flows with the user entering credentials, no profile-gate bypass, outage and retry states, privacy-safe logging | Do not capture credentials or convert a backend outage into “profile incomplete.” |
| 8 | Work Requests production contract | Approved PRD/ERD/RLS, real repository and audit timeline, no seeded production records | Current mock source and seeded counts are tracked in issue #85. |
| 9 | Manufacturing Task and Machine Queue, as separate modules | Separate approved contracts, machine-head permissions, queue conflict/assignment tests | Requires machine list, operational rules, role model, and Work Request handoff. |
| 10 | Inventory/borrowing, projects, events, quotations/payments, reports | Each has approved ownership, data contract, RLS, UX states, tests, and audit trail | Do not invent catalog, prices, event capacity, or payment verification. |

## Production acceptance gates across every slice

1. **Product:** owner-approved rules, actual catalog/price/room inputs where applicable, and no contradictory charter text.
2. **Security:** tested RLS with ordinary and privileged identities; least-privilege role assignment; no client-controlled approval or verified-payment claims; no secret in code/logs.
3. **Data:** one canonical migration ledger, backup/restore rehearsal, idempotent import, audit history for role/payment/inventory/status changes, schema-to-model checks.
4. **UX:** approved bright neo-brutalist tokens, authentic imagery/doodles, real loading/empty/error/offline/unauthorized states, accessible text scale/contrast, no dead controls.
5. **Quality:** analyzer, focused and full tests, CI on final SHA, independent review, Android E2E on exact APK, regression comparison; iOS requires its own later device/build gate.
6. **Scale:** test representative 4,000+ accounts and peak event/booking concurrency, pagination/query indexes, storage budgets, crash/latency monitoring, rate limits and incident/rollback playbook. “4,000+ target” is not a claim of proven capacity.
7. **Release:** Play distribution/legal/privacy content, support path, operational training, monitoring, backup access, staged rollout, rollback decision owner, and signed release build verification.

## PR policy and issue hygiene

- The live audit reported 11 open PRs and 28 issues on 2026-09-17. None had the required independent approval. Do not merge by bypassing branch protection, combining all PRs, or mistaking green checks on an old head for readiness.
- Keep #99 and #100 as dependency-ordered PRs. Keep #103's CI/profile correction scoped separately. Review docs/security/feature PRs on their own bases and heads. A single bulk merge would obscure failures and rollback ownership.
- Before opening a new issue, search the existing 28 for a duplicate. New focused issues are justified for confirmed live RLS/role-write drift, Penpot Page 17 completion, auth outage/gate behavior, and schema ledger only after their current issue coverage is checked.
- Keep obsolete worktrees until `git worktree list`, each exact status, ignored/untracked contents, and PR relationship are verified. `pr64-test` is a real worktree with build outputs, not an empty folder to delete blindly.

## Human inputs still needed before those modules can be completed

Final product name and approved logo/media; machine/tool/component list and room mapping; safety and training rules; pricing/quotation/fine/refund policy; official UPI/payment reconciliation procedure; head assignments and role approval; production domain for links; and institutional privacy/legal approvals. Designs may show honest empty/setup states while these are pending, never made-up operational content.
