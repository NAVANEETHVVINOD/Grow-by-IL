# Current Grow project baseline

Status: Draft evidence record; not product or release approval
Owner: Project coordinator
Version: 1.0
Last updated: 2026-10-03
Depends on: Read-only GitHub and local repository inspection
Referenced by: [Delivery board](GROW_V1_TASK_BOARD.md)

Follow-up: the [P0-03 investigation](../05_DevOps/P0_03_CI_INVESTIGATION.md)
refreshes this baseline, proves the four current CI root causes and records the
authorized diagnosis-only scope. Its board markers distinguish completed
investigation from unresolved CI defects. No application or remote fix is applied.

## Repository facts

Repository: [NAVANEETHVVINOD/Grow-by-IL](https://github.com/NAVANEETHVVINOD/Grow-by-IL).
GitHub was queried on October 3, 2026; refresh these facts before any external action.

| Surface | Observed revision / state |
| --- | --- |
| GitHub default `main` | `1041099156cf33a865e9b5d0ea30e25540e7bd46`; last commit May 26, 2026 |
| GitHub RC5 | `2fafcf2a7b41f3bb26df9db8200f4e8316a311ee`; active integration target of product PRs |
| Local original RC5 checkout | `9adb5545901c327ca0da96cd192d2f57dbbe967c`; dirty auth/UI/Android work, preserve |
| Existing docs PR #121 | `b8b4ecfd42232417ef9809fdb9b4ad4e0fbfabba`; nine tracked public documents |
| Local preservation branch | `docs/baseline-docs-20261003`, based on #121; documentation-only changes |
| Existing launch-plan checkout | Dirty delivery board and Work Request delta; original edits preserved |
| Open work | 11 PRs and 34 issues at inspection |

`main` is the GitHub default; RC5 is the observed product integration branch. No trunk
change is inferred or performed. The baseline branch deliberately starts from the
existing docs PR, rather than importing application changes from unrelated worktrees.
The original checkout has 14 modified tracked paths and untracked auth/UI/artifact
work. The observed worktree list contains 28 entries before this preservation branch.
Worktree cleanup and broad resets are outside this pass.

## Review of the supplied concerns

| Concern | Verified finding | Action |
| --- | --- | --- |
| Ignored docs | Original RC5 has zero tracked docs; the docs branch has nine. 109 local historical Markdown files plus raw artifacts existed. | Preserve 107 reviewed records; sanitize five; exclude two private security records and raw artifacts. Track reviewed docs by default. |
| Approval claims | [Approval log](../00_Project_Management/APPROVAL_LOG.md) records Charter, Phase 1A and Work Request-only Phase 1B approval on August 2. [Old status](../00_Project_Management/PROJECT_STATUS.md) still says pending. | Preserve conflicting history; do not invent or broaden approvals. Current revised backend/business gates remain open. |
| PR #56 CI | [#56](https://github.com/NAVANEETHVVINOD/Grow-by-IL/pull/56) merged August 4; final head `7943fc7c8a074c29453378a4cdacfc6cc5a2ebfb` had successful Quality Gate and Debug APK checks. | No present fix needed. This does not verify whether an earlier chat claim was true when made. |
| Duplicate #57 | [#57](https://github.com/NAVANEETHVVINOD/Grow-by-IL/pull/57) is closed. | Do not close it again or resurrect it. |
| Direct commits | A first-parent commit is not proof of a policy violation; squash merges also have one parent. | Allegation remains unverified; current branch policy still applies. |
| Mock Work Requests | `lib/features/work_requests/services/work_request_data_source.dart:16–17` constructs `MockWorkRequestDataSource`; draft storage uses SharedPreferences. | Real operations are incomplete. Existing UI/unit tests cannot prove backend persistence or authorization. |
| Large screens / timing workarounds | Historical debt exists, but this pass did not remeasure every screen or reproduce every timing issue. | Keep debt visible; refactor only where an executable slice requires it. |
| Scope inflation | Existing issues and PRs already describe most work. | Use one board and existing PRs; no Manufacturing Task implementation in this baseline pass. |

## Current PR dispositions and exact heads

Success below refers to observed applicable quality/build checks, not device E2E or
merge approval. No open PR had a submitted review or review thread at inspection.

| PR | Head | Base | Observed checks | Disposition / next action |
| --- | --- | --- | --- | --- |
| [#80](https://github.com/NAVANEETHVVINOD/Grow-by-IL/pull/80) | `f0c37dbf582d9bfe6973f592f2871ebb20a00d5a` | main | Quality/build success | KEEP; review dependency-update policy |
| [#90](https://github.com/NAVANEETHVVINOD/Grow-by-IL/pull/90) | `13d9d96d44489b3250431f9583d630b91b6f935a` | RC5 | Quality/debug success | KEEP; inspect hardening and docs overlap |
| [#99](https://github.com/NAVANEETHVVINOD/Grow-by-IL/pull/99) | `772e808cb1974fad497d30782a62febae302287f` | RC5 | Quality/debug success | KEEP; parent of #100 |
| [#100](https://github.com/NAVANEETHVVINOD/Grow-by-IL/pull/100) | `ed37a92d601c9ee6efb03fc951463a15058f8c23` | #99 branch | Only skipped label check | KEEP; rebase/retarget after parent and obtain real CI |
| [#103](https://github.com/NAVANEETHVVINOD/Grow-by-IL/pull/103) | `d80a96ab68a1ad33b7a7fdd9446b66be5ea3cd04` | RC5 | Quality/debug success | KEEP; identity acceptance review |
| [#108](https://github.com/NAVANEETHVVINOD/Grow-by-IL/pull/108) | `a608aa136b084ac5de7ca3f9a8fa9f21d20267d4` | RC5 | Quality/debug success | KEEP; auth/provider/profile/device gates |
| [#115](https://github.com/NAVANEETHVVINOD/Grow-by-IL/pull/115) | `d3809fc8556660083f2e36e5af6a922cc86a68f2` | #90 branch | Zero checks | KEEP; resolve parent, then obtain real CI |
| [#121](https://github.com/NAVANEETHVVINOD/Grow-by-IL/pull/121) | `b8b4ecfd42232417ef9809fdb9b4ad4e0fbfabba` | RC5 | Quality/debug success | KEEP; reconcile this preservation change into existing docs path after authorization |
| [#122](https://github.com/NAVANEETHVVINOD/Grow-by-IL/pull/122) | `51b56f941b5138d9f831de34d5b9afd6737753d4` | main | Quality/build success | KEEP; review action upgrade and pinned sources |
| [#123](https://github.com/NAVANEETHVVINOD/Grow-by-IL/pull/123) | `6f856183211fb93024a535b1841c8a08c3b9362d` | main | Production build failed | NEEDS FIX; diagnose exact failed job |
| [#124](https://github.com/NAVANEETHVVINOD/Grow-by-IL/pull/124) | `99f4d4e30c3bc0f7aa233a63523e28b562ac58fc` | main | Quality failed; build skipped | NEEDS FIX; diagnose dependency update |

Dependency graph: `#90 → #115`, `#99 → #100`; auth/provider/profile evidence gates
precede release acceptance. Existing main-target dependency PRs use a different CI
contract from RC5. No PR is designated MERGE/CLOSE solely from this inspection.

## CI and release truth

Both main and RC5 protection require current checks, strict up-to-date validation,
administrator enforcement and no force pushes. Main requires `Quality Gate (CI)` and
`Android Production Build`; RC5 requires `Quality Gate` and `Debug APK Build`.
Both require zero GitHub approvals. The current user-provided AGENTS instructions
still require independent review before merging. The pasted historical conversation
records a different preference; no merge is attempted while that policy conflicts.

RC5 `2fafcf2…` has successful push checks but a failing PR-context architecture
guard at the same SHA: [failed run](https://github.com/NAVANEETHVVINOD/Grow-by-IL/actions/runs/34808903767).
The failure skipped later schema/secret steps. A green push run is not evidence that
the integration PR passed. Inspect the blocked paths and phase approvals; do not
disable the guard to obtain a green check.

Main's [pinned CI](https://github.com/NAVANEETHVVINOD/Grow-by-IL/blob/1041099156cf33a865e9b5d0ea30e25540e7bd46/.github/workflows/ci.yml#L103)
allows placeholder backend configuration in its production APK build. Compile success
therefore does not establish a usable release. Its older Dependabot auto-approval/
auto-merge workflow also differs from RC5's label-only workflow. Reconcile as explicit
release work; no remote settings or workflow files were changed in this pass.

## Business decisions and unresolved inputs

The pasted history and latest local [contract delta](../02_Product/WORK_REQUEST_CONTRACT_DELTA.md)
record separate Machine/Operations submissions, direct cancellation before head
claim/review, and reasoned cancellation requests afterward with head approval/denial.
Pending or denied cancellation leaves work status unchanged. Operations Head approves
stock and prices. These recorded decisions are retained; backend enforcement is pending.

Historical [product direction](../01_Product/PRODUCT_DECISION_DELTA_2026-09-17.md)
says students request/book work and Machine Heads operate fabrication machines.
Detailed booking, eligibility and concurrency rules still need an approved contract.

Still open at the relevant gate: exact V1 request categories; which incur quotes/
charges; refund rules; dated verified machine/tool/component data; actual approved
prices; booking/safety contract details; named pilot support/escalation owner. Pricing
approver and cancellation behavior are already recorded and need not be reasked.
These do not block the documentation baseline. They block dependent operational code.

## Implementation inventory and limits

Auth/profile, events, projects, tool booking, lab presence, navigation and admin screens
exist in RC5 or active PRs. Their production readiness is unverified here. Work Request
is a local UI/mock workflow. Manufacturing, queue, operational inventory/borrowing,
quotation/payment and reports remain gated or partial; historical ERDs are proposals,
not proof of implemented or deployed services. Penpot, live backend and Android device
were not accessed in this pass. No new application tests were run for this docs-only change.

## Local verification for this change

The coordinator checks copied-file provenance/redactions, current navigation links,
Git ignore inclusion/exclusion behavior, tracked path allowlist and `git diff --check`.
Independent docs/evidence/security review inspected the actual files. Two governance
navigation/link findings were corrected. Current files pass strict staged whitespace
checks; copied historical whitespace has a documented preservation exception.
Exact results are recorded on the [delivery board](GROW_V1_TASK_BOARD.md).
Hosted CI for this new change and off-machine backup remain unverified until authorized
publication. No application release, production migration, PR merge or closure is included.
