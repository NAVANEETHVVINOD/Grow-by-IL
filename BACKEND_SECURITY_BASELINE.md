# Backend Security Baseline

Status: Draft. This is an approval gate, not a database migration or an
implementation specification.

## Purpose

This document defines the evidence and approvals required before Grow adds or
restores persistence for operational modules. It covers the existing identity,
authorization, RLS, migration, and audit boundaries. It does not authorize any
production SQL, RLS change, seed data, role assignment, or Flutter persistence
work.

## Canonical Sources

The following tracked files are authoritative for this baseline:

- `SECURITY.md` for security engineering rules.
- `ARCHITECTURE_DECISIONS.md`, especially ADR-007, for phase-gated persistence.
- `SYSTEM_BOUNDARIES.md` for V1 scope.
- `supabase/migrations/` for repository schema and policy history.
- Flutter source for the current client contract.

Ignored `docs/` material may provide context but must not override these files
without an approved, tracked reconciliation.

## Verified Constraints

1. Supabase Auth is the application identity provider. `public.users` is the
   current operational-account row used by Flutter. Extended profile tables are
   not an authorization source.
2. Email/password and native Google sign-in both create or synchronize the
   same `public.users` identity. The post-sign-in route must be resolved by
   Splash and the profile-completion gate, not by the sign-in button.
3. The current repository contains incompatible authorization vocabulary:
   the initial migration defines `base_role` and `system_role`; current Flutter
   code reads and writes `users.role`; later migration files reference the
   newer vocabulary. No new feature may infer equivalence between these fields.
4. The live project contains profile tables that are not represented by a
   complete, matching deployed migration ledger. Applying repository files out
   of order or creating an ad-hoc replacement schema is prohibited.
5. RLS is enabled for the current application tables. Client code must not use
   a service role, bypass RLS, or use a broad policy to work around an error.
6. Existing security advisories for function execution, function search paths,
   extension placement, and leaked-password protection require a reviewed
   disposition before operational backend expansion.

## Required Contract Decisions

The following require explicit approval before schema design or migration work:

| Decision | Required outcome |
| --- | --- |
| Account model | One canonical account-type vocabulary and a migration path from legacy role columns. |
| Positions | Position assignments are distinct from account type, are time-bounded, and are scoped to a lab where applicable. |
| Authority | Super Admin assignments, revocations, and elevated actions are server-authoritative and audited. |
| Profile ownership | `public.users` owns account and authorization attributes; extended profile tables own only profile data. |
| RLS matrix | Every table and RPC has an operation-by-operation actor, scope, and denial rule. |
| Authentication | Email and Google flows share profile synchronization, profile completion, sign-out, and denied-user behavior. |
| Audit model | The events, retained fields, readers, and protection rules for elevated actions are defined. |
| Migration ledger | The deployed schema is reconciled with the repository through an approved, ordered migration plan. |

## Evidence Required Before a Change Proposal

1. Capture a read-only live schema inventory: tables, columns, constraints,
   indexes, RLS state, policies, functions, triggers, extensions, and deployed
   migration ledger. Do not include secret values or user data in the record.
2. Compare that inventory with every tracked migration. Classify each source
   migration as applied, partially represented, unapplied, superseded, or
   incompatible. Do not execute the comparison output.
3. Produce an approved account/position authorization contract before creating
   position tables, policies, repositories, or administration screens.
4. Produce an RLS matrix covering `SELECT`, `INSERT`, `UPDATE`, `DELETE`, and
   RPC execution for every affected object.
5. Define a migration and rollback plan that is idempotent where necessary,
   protects existing rows, and includes a staging verification sequence.
6. Define focused tests for unauthenticated access, own-record access, cross-
   user denial, elevated access, revoked access, email auth, Google auth,
   profile creation, profile completion, and sign-out/relaunch.

## Prohibited Until Approval

- Running existing migration files directly against the shared project.
- Creating a parallel `users`, `user_profiles`, role, or position schema.
- Adding operational module persistence for Work Requests, Manufacturing Tasks,
  Machine Queue, Inventory, or Payments.
- Adding `data/` or `domain/` layers that imply a new backend contract.
- Granting broad client access, disabling RLS, or using a service-role key in
  Flutter.
- Mapping legacy Head strings to new positions without an approved migration.
- Treating UI visibility as authorization enforcement.

## Approval Exit Criteria

This baseline is complete only when all of the following are approved in the
repository approval record:

1. Live schema and migration-ledger reconciliation.
2. Canonical account and position authorization model.
3. RLS and RPC policy matrix.
4. Security-advisor disposition with planned remediation ownership.
5. Migration, rollback, and test plan.

Only after those approvals may a narrowly scoped database architecture proposal
be prepared for a specific module. A module still needs its own approved PRD/SRS
and implementation contract under ADR-007.
