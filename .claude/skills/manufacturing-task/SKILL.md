---
name: manufacturing-task
description: Use when implementing, reviewing, or discussing Manufacturing Tasks — the execution-work units (laser cutting, 3D printing, PCB milling, CNC, assembly, testing) derived from an approved Work Request. Not for Machine Queue/scheduling — see the boundary section before any queue-adjacent work.
---

# Manufacturing Task

A Manufacturing Task is execution work derived from an approved Work
Request — laser cutting, 3D printing, PCB milling, CNC routing, electronics
assembly, mechanical assembly, design support, or testing
(`docs/01_Product/BUSINESS_GLOSSARY.md`, MOD-05).

## Manufacturing Task vs. Machine Queue — read this first

Manufacturing Task (MOD-05) and Machine Queue (MOD-06) are separate product
slices in the glossary and on the roadmap, and must stay separate here too:

- **Manufacturing Task** = *what* execution work exists and *which* approved
  Work Request it belongs to (type, parent, cascade-on-cancel). This skill.
- **Machine Queue** = *ordering/scheduling* of tasks against machines and
  operators — Machine Head-owned, a distinct future module with its own
  phase gates.

Do not design, model, or implement Machine Queue behavior (ordering,
assignment, operator scheduling, queue position calculation) as part of a
Manufacturing Task change, unless the task explicitly says it concerns the
queue. If a Manufacturing Task change seems to require queue logic, stop and
flag that it's crossing into the separate, not-yet-contracted Machine Queue
module rather than folding queue design into this one.

## Canonical sources

- ADR-0003 (`docs/00_Project_Management/ARCHITECTURAL_DECISION_RECORDS/ADR-0003-manufacturing-tasks.md`)
  — the accepted decision to model manufacturing as tasks under a Work
  Request rather than assigning the whole request to one machine.
- `docs/01_Product/05_WORK_REQUEST_REQUIREMENTS.md` §"Manufacturing Task
  Types" — the initial task type list, and the split between a Work
  Request's fabrication *subcategory* (student intent) and the actual task
  type (Machine Head's call at approval time — a student's single
  "Mixed Fabrication" selection can become several tasks).
- `docs/01_Product/06_WORK_REQUEST_IMPLEMENTATION_CONTRACT.md` §"Manufacturing
  Task Cascade" — the only approved lifecycle rule that currently exists:
  tasks are created at Work Request `reviewed → approved`, and parent
  cancellation after that point cascades to every child task.

## Important gap — do not paper over it

Unlike Work Request, Manufacturing Task has **no approved Implementation
Contract** of its own (no per-field, per-state-machine, per-validation-rule
document). What exists is the ADR (why it's modeled this way) and scattered
mentions in the Work Request docs. Per `docs/02_Architecture/MODULE_LIFECYCLE.md`,
a module needs its own Requirements + Contract gate cleared before UI/local
flow work starts. If asked to build real Manufacturing Task UI or logic
beyond what's already implied by the Work Request contract's cascade rule,
say so and propose writing the Contract first rather than inventing task
states, fields, or a queue model from scratch.

## Scope boundary

No Manufacturing Task may exist without a non-cancelled parent Work Request.
Before that parent reaches `approved`, no tasks exist and no cascade logic is
needed. `lib/features/machines/(data|domain)/` and `supabase/migrations/`
are both CI-gated (`.github/ci/architecture_guard_paths.txt`) until DB
architecture is approved — this applies to Manufacturing Task persistence
*and*, separately, to Machine Queue persistence once that module starts.

## Workflow

1. Confirm which parent Work Request state the task logic assumes; task
   creation/cascade only fires at/after `approved` (see [[work-request]]).
2. If the task doesn't already have an approved Contract-level rule to point
   to, treat the request as "needs a Contract" rather than a green light to
   design one inline.
3. If the work in front of you is actually about ordering, assignment, or
   scheduling rather than "what task exists for what request," it belongs to
   Machine Queue, not here — say so instead of extending this skill's scope
   to cover it. Student-facing visibility limits (coarse position only, no
   raw queue/priority rationale/operator detail) are a Work Request rule
   ([[work-request]]) that both Manufacturing Task and Machine Queue must
   respect, not something either module defines on its own.
