# Grow V1 delivery board

Updated: 2026-09-29. Status is based on the current repository and GitHub audit, not a claim that the app is launch-ready. This public board intentionally omits private security-advisory details and credentials. The historical local launch plans are reference material; this board is the current execution queue.

## Current gates

| Gate | Verified state | Release evidence still needed |
| --- | --- | --- |
| Security boundary | Private remediation and database tests exist; production deployment is not verified here | Independent security review, controlled deployment, read-only live verification |
| Auth | PR #108 is draft; callback lifecycle hardening through `a608aa1` passed 175 local Flutter tests, analyzer, Quality Gate and Debug APK Build | Google provider and reliable email delivery configuration, fresh-device signup/sign-in/reset/cold-restart E2E, review |
| Onboarding | The stale RC5 screen PR #111 was closed without merge because #108 replaces that route; issue #110 tracks the active flow | Confirmed-account gate, persisted minimum profile, resume/error tests, device E2E |
| Design | Penpot previously showed pages 00–18 and Page 17 content; connector unavailable on this audit | Live page-by-page audit and linked prototype, Flutter comparison; see [acceptance matrix](../01_Design/PENPOT_ACCEPTANCE_MATRIX.md) |
| Navigation/UI | #99 then #100; #103 and #101 are separate | Review, current-head CI, real-device regression and accessibility checks |
| Operations | Local Work Request UI exists; issue #85 tracks non-production data | Approved contract delta, real data/RLS, tests, then separate Manufacturing Task and Machine Queue |
| GitHub | 8 open PRs, 34 open issues; no PR has independent review | Reconcile stacks and verify exact heads before merging; no green PR is merge-authorized by this board alone |

The non-sensitive [backend security baseline](../03_Database/BACKEND_SECURITY_BASELINE.md) is the database-entry gate for every operational module.
The [auth provider release checklist](../03_Database/AUTH_PROVIDER_RELEASE_CHECKLIST.md) is the configuration and Android-evidence gate for issues #112 and #113.
The [role and position contract](../03_Database/ROLE_AND_POSITION_CONTRACT.md) separates current account roles from future core-position assignments before any authorization schema is proposed.
The [Storage access contract](../03_Database/STORAGE_ACCESS_CONTRACT.md) reconciles proposed buckets with Flutter media calls before any upload UI is enabled.
The [Work Request contract delta](../02_Product/WORK_REQUEST_CONTRACT_DELTA.md) separates the current simulated UI from the decisions and authorization evidence required for real operations.
The [Profile ecosystem decision gate](../02_Product/PROFILE_ECOSYSTEM_DECISION_GATE.md) keeps the active minimum-profile auth path separate from unverified rich-profile migrations and privacy decisions.

## Next five executable tasks

These tasks may advance in parallel where their systems are independent. A green CI check is not a substitute for review or an Android E2E run.

1. **Close the security release gate — #88.** Keep remediation private until safe disclosure. Independently review the exact tested head, validate against the live schema shape, deploy through a reviewed migration, and verify grants, RLS, account roles, and ordinary profile/project flows afterward. Do not run an unreviewed console patch.
2. **Stabilize identity — #108, #110, #112, #113, #120.** Define and test `created → email verified → explicit sign-in → profile complete → Home`; old or used links must not authenticate. Configure Google and email on the intended Supabase environment, protect role fields, test profile persistence and storage policy before uploads, and run the exact APK on a phone once available. Never put test credentials in logs or issues.
3. **Finish the 00–18 Penpot system — #101.** Reconnect the connector, enumerate actual page names and boards, then complete the acceptance matrix: route, back/cancel/retry, all relevant states, 48 dp touch targets, text scaling, reduced motion, original doodles, authentic media, and Flutter token parity. Do not call a static frame a wired prototype.
4. **Reconcile product and Work Request contracts — #93, #95, #70, #71, #79, #85.** Preserve the approved Work Request contract, then review its delta for Machine Request vs Component Request, routing by responsibility, quote/deposit semantics, cancellation and audit. Decide the one-lab/two-room model and position scope before schema changes. Avoid new inventory quantities or prices until the owner supplies them.
5. **Restore a controlled merge queue — #80, #90, #99, #100, #103, #108, #115.** Check each base, current SHA, required checks, diff, unresolved conversations and independent review. Merge dependent stacks in order (#99→#100 and #90→#115). Historical PR #44 was closed without merge because its bundled, unapproved migrations correctly failed the architecture phase gate.

## Remaining build sequence

| Order | Slice | Entry gate | Exit evidence |
| --- | --- | --- | --- |
| 6 | Work Request real backend | Reviewed revised contract | RLS tests, real list/detail/timeline, no fabricated rows, Android E2E |
| 7 | Manufacturing Task | Work Request handoff contract | Separate PRD, role matrix, schema, audited transitions and tests; #69 |
| 8 | Machine Queue and booking | Machine catalog and operator rules approved | Availability/concurrency tests, machine-head authorization, real request states |
| 9 | Inventory, tools and components | Updated stock/import owner decision | Provenance, borrowing/return, count reconciliation and RLS; #97 |
| 10 | Projects and membership | Creator-approval contract | Join code creates request only, creator approval and denial tests; #98 |
| 11 | Events and payment | Event-head ownership, capacity and refund rules | Atomic seat confirmation only after verified payment; #87 |
| 12 | Lab presence | Head-supervised after-hours rules | Manual check-in/out, actual presence, audit and offline behavior; #96 |
| 13 | Reporting and administration | Canonical roles/positions | Server-enforced permissions and auditable assignment; #104 |
| 14 | Scale, recovery and release | All vertical slices complete | 4,000+ account/peak-load proof, backup/restore, signed build, privacy/support, staged pilot; #84, #86, #89 |

## Truth and repository rules

- Production account-role labels remain `student`, `lab_admin`, `super_admin` until a separate, reviewed product migration. Core positions are assignments, not client-controlled roles.
- The validation Supabase project had no Storage buckets at this audit. A proposed public-media migration is not proof of deployed storage and may conflict with members-only profile visibility; settle #120 before upload rollout.
- The approved Work Request contract and local schema ledger are inputs, not proof of live deployment. Never expose private exploit details in a public PR.
- Keep `docs/` ignored by default. Track only individually reviewed, non-sensitive documents; do not force-add the entire local documentation tree.
- Preserve the dirty main checkout and existing worktrees. Remove or move a file only after checking its owner, Git status, and unique content.
- Use real loading, empty, error, offline and permission states. Do not hardcode users, stock, machine capacity, event counts, verification badges or prices.
- An issue/PR closes only on specific evidence: tests executed, current-head CI, required review, and Android device verification when the change affects the device.

## Human inputs or external blockers

- A genuine independent reviewer for security and release-sensitive merges.
- Google OAuth client/provider configuration and a reliable confirmation-email sender for the intended Supabase project; secrets stay in the respective consoles.
- A connected, authorized Android phone for exact-build auth and navigation E2E.
- A working Penpot connector for live page edits and final page-by-page verification.
- Updated stock, machine operation/safety rules, official prices and payment reconciliation before those modules are marked production-ready.
