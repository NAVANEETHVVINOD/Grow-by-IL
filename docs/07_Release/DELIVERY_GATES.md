# Grow~ Delivery Gates: Evidence Required Per Milestone

Status: Draft (Pending Review)
Owner: Lead Architect / Release Owner
Version: 1.0
Last updated: 2026-09-01
Depends on: `/DEFINITION_OF_DONE.md`, `docs/07_Release/release_checklist.md`, `/CONTRIBUTING.md`
Referenced by: `docs/00_Project_Management/MASTER_INDEX.md`

> **Authoritative Version Pointer**: Per-PR completion criteria live in
> `/DEFINITION_OF_DONE.md`. Per-release build/ship steps live in
> `docs/07_Release/release_checklist.md`. This doc sits between the two: what
> evidence must exist before a *milestone* (not a single PR, not a Play
> Store push) is considered actually delivered.

## 1. Why This Doc Exists

`/DEFINITION_OF_DONE.md` answers "is this PR done." `release_checklist.md`
answers "is this build safe to ship." Neither answers "is Milestone X (e.g.
'Work Request V1', 'Manufacturing Tasks V1') actually delivered, with
evidence, or just merged." This doc is that gate, expressed generically so
it applies to any future module milestone, not just Work Requests.

## 2. Gate Criteria (all required, no partial credit)

A milestone is not "delivered" until:

1. **Architecture gate cleared**: the module's PRD/SRS, architecture,
   role/permission matrix, and database design are Approved-status docs
   (per `/CONTRIBUTING.md` "Architecture Gate" and
   `ARCHITECTURE_DECISIONS.md` ADR-007) — not Draft.
2. **Business rules reconciled**: the relevant rows in
   `docs/01_Product/04_BUSINESS_RULE_MATRIX.md` match the approved
   implementation contract for that module, with no open "reconciliation
   needed" notes for that module's rules.
3. **Every DoD item green** on every PR that shipped part of the milestone
   (`/DEFINITION_OF_DONE.md`) — verified by checking merged PR descriptions,
   not assumed.
4. **CI green on the integration branch** at the commit being called the
   milestone boundary (`docs/05_DevOps/CI_CD.md` Section 2).
5. **Manual verification recorded**: at minimum the golden path and the
   documented edge cases for the milestone's feature(s), with a note of what
   was tested and on what device/build — not just "flutter test passed."
6. **No unresolved P0/P1 issue** tagged to that milestone's GitHub Issues
   area label.
7. **Rollback plan exists and is specific** to the milestone (which
   migrations, which feature flags, which branch to revert to) — not a
   generic "revert the PR" statement.

## 3. Evidence Format

For each milestone, evidence should be a short note (in the milestone's
tracking issue or a `docs/07_Release/` entry) listing, against the 7 items
above: pass/fail, link/PR number, and date checked. This doc does not
mandate a machine-readable manifest format — if the team wants one later,
that's a separate, explicit decision (see Open Items).

## 4. Current State (as of 2026-09-01)

No module has been run through this gate yet — Work Requests (the only
shipped feature module) does not have a formal "V1 delivered" milestone
marker; PR #63 fixed a lifecycle mismatch found *during* development, which
is exactly the kind of gap this gate is meant to catch earlier next time.

## 5. Open Items

- Whether to formalize evidence as a machine-readable manifest (e.g. one
  YAML/JSON per milestone under `docs/07_Release/`) is a genuine open
  question, not decided here — flagged for the repo owner, not invented
  unasked.
