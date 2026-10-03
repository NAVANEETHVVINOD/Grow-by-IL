# Grow~ Technical Bible

Status: Draft (Pending Review)
Owner: Lead Architect / Core Team
Version: 1.0
Last updated: 2026-09-01
Depends on: `/CODING_STANDARD.md`, `/DEFINITION_OF_DONE.md`, `/SYSTEM_BOUNDARIES.md`, `/CONTRIBUTING.md`
Referenced by: `docs/00_Project_Management/MASTER_INDEX.md`

> **Authoritative Version Pointer**: This is a normative *contract*, not a
> restatement. Where any section below appears to conflict with
> `/CODING_STANDARD.md`, `/DEFINITION_OF_DONE.md`, or `/SYSTEM_BOUNDARIES.md`,
> those root files win — file an issue to fix this doc rather than trusting
> this copy.

## 1. Purpose

A single normative entry point for "what is Grow allowed to look like,
engineering-wise." It exists because the repo already has several
authoritative rule documents (coding standard, definition of done, system
boundaries, contributing guide) scattered across root and `docs/`; this file
is the index + the rules that don't have a home yet. It does not duplicate
those documents' content — it cross-references them and states the rules
that cut across all of them.

## 2. Mandatory Engineering Rules (cross-cutting)

These apply regardless of feature, derived from what's already enforced in
CI (`.github/workflows/ci.yml`) and `/BRANCH_PROTECTION.md`:

1. No Supabase/network calls directly from widgets — repository layer only
   (per `/DEFINITION_OF_DONE.md` "Implementation").
2. No new Supabase migration, schema change, repository, or persistence logic
   for a new operational module without an approved PRD/SRS + architecture +
   role matrix + database design first (`/CONTRIBUTING.md` "Architecture
   Gate", `ARCHITECTURE_DECISIONS.md` ADR-007).
3. Dart enums for domain states stay camelCase; wire serialization goes
   through `.name`; Supabase persistence translates camelCase -> snake_case
   in the repository layer, never by renaming the enum (locked decision from
   the Work Request lifecycle alignment, PR #63).
4. One branch = one coherent change. Don't mix feature code, schema changes,
   formatting, and unrelated cleanup in a single PR (`/CONTRIBUTING.md`).
5. `dart format .`, `flutter analyze`, `flutter test` must be run locally
   before pushing; CI re-runs all three plus schema-contract checks and must
   be green before merge (`docs/05_DevOps/CI_CD.md`).
6. Every PR states purpose, scope, architecture impact, database impact,
   security/RLS impact, UI/UX impact, tests run, rollback plan
   (`.github/PULL_REQUEST_TEMPLATE.md`).
7. System boundaries in `/SYSTEM_BOUNDARIES.md` are not suggestions — moving
   anything from "Outside Grow" to "Inside Grow" requires an approved
   requirement, ADR, security review, storage/cost review, and test plan
   before any code lands.

## 3. What This Document Is Not

- Not a replacement for `/CODING_STANDARD.md` (style/lint rules) or
  `/DEFINITION_OF_DONE.md` (per-feature checklist) — read those directly.
- Not a product requirements document — see `docs/01_Product/PRODUCT_SCOPE.md`
  and `docs/01_Product/00_PRODUCT_CHARTER.md`.
- Not an architecture diagram — see `docs/02_Architecture/system_architecture.md`
  and `docs/02_Architecture/product_architecture.md`.

## 4. Open Items

- The repo currently has two ADR systems (root `/ARCHITECTURE_DECISIONS.md`,
  ADR-001..007, "Accepted"; and
  `docs/00_Project_Management/ARCHITECTURAL_DECISION_RECORDS/`, ADR-0001..0004,
  "Approved") that were never reconciled into one numbering scheme. Flagged
  for a human decision in the repo-structure-and-docs-cleanup audit; not
  resolved here.
