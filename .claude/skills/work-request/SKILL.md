---
name: work-request
description: Use when implementing, reviewing, or discussing the Work Request feature (lib/features/work_requests/) — creation flow, status lifecycle, fields, validation, or student/core-team visibility rules.
---

# Work Request

Work Request is the primary operational object in Grow: a student/team
request for fabrication, design, or technical help. It is **not** an Order —
see `docs/01_Product/BUSINESS_GLOSSARY.md` and ADR-0002.

## Canonical sources (in priority order)

1. `docs/01_Product/06_WORK_REQUEST_IMPLEMENTATION_CONTRACT.md` — **Approved**.
   This is the single source of truth for the current build: state machine,
   required fields, validation rules, permissions, payment-state linkage.
2. `docs/01_Product/05_WORK_REQUEST_REQUIREMENTS.md` — Draft/Phase 1B prep.
   Useful for category/subcategory taxonomy and rationale, but the
   Implementation Contract wins on anything both docs cover.
3. `lib/features/work_requests/models/work_request_summary.dart` — the
   shipped `WorkRequestStatus` enum. Must match the Implementation Contract.

**Do not use** `docs/01_Product/04_BUSINESS_RULE_MATRIX.md` as a lifecycle
source. It is Draft/unapproved and has a documented three-way mismatch with
the Implementation Contract and the shipped enum (BRULE-020 uses different
naming and implies a review-loop the approved contract doesn't spell out).

## Canonical lifecycle (camelCase Dart enum, `.name` for wire format)

```
draft → submitted → reviewed → changesRequested → approved → inProgress
→ readyForPickup → completed
```
Plus terminal `rejected` and `cancelled`. `queued` is deliberately **not** a
Work Request status — that belongs to the future Manufacturing Task / Machine
Queue domain.

Open question, not yet resolved: whether `changesRequested` loops back to
`reviewed` or to `submitted`. Don't silently pick one in new code that
enforces transitions — surface the ambiguity and ask, or match whatever the
existing UI already assumes.

Manufacturing Tasks are created at the `reviewed → approved` transition, not
earlier. Cancelling an `approved`+ request must cascade: every child task
moves to `cancelled`, carries the parent's cancellation reason, and notifies
operators (see the Manufacturing Task Cascade section of the Implementation
Contract, and the [[manufacturing-task]] skill).

## Scope boundary for the current build

Fabrication-category requests only. Out of scope until Phase 2 approval:
quotation generation, payment collection, machine/operator assignment, queue
reordering, inventory consumption, and any Supabase persistence — draft state
is local-only via `SharedPreferences`. Check
`.github/ci/architecture_guard_paths.txt` before touching anything under
`lib/features/work_requests/(data|domain)/`; CI will block it otherwise.

## Student visibility rules

Students may see: current status, coarse queue position ("3 ahead"),
estimated completion window, assigned lab/machine after review, public
core-team contact.

Students must **not** see: raw machine queue, internal priority rationale,
full ordered task list, internal Machine Head notes, operator assignment
detail before publication, maintenance conflicts, queue reordering controls.

## Workflow

1. Before changing behavior, check whether the change is UI/local-flow
   (allowed) or persistence/domain (gated — needs Phase 2 approval first).
2. Cross-check any status/field/validation change against the Implementation
   Contract table for that concern; if the contract doesn't cover it, don't
   invent a rule — flag it as an open question.
3. Keep the enum, the contract, and the UI in agreement. If you find a
   mismatch, fix it in a dedicated PR before building new screens on top of
   the drifted version (this happened once already — see
   `fix/work-request-lifecycle-alignment`).
4. Run `flutter test` scoped to `test/` files touching work_requests, plus
   `flutter analyze`, before considering the change done.
