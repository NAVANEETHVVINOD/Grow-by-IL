# Organization Schema Proposal

Status: Proposal only. Do not execute SQL, alter RLS, create seed data, or change production records from this document.

## Repository Evidence And Conflict

The repository currently contains incompatible identity and authorization models.

| Source | Observed contract |
| --- | --- |
| supabase/migrations/001_initial_schema.sql | public.users defines base_role and system_role, including historical Head values. |
| lib/core/constants/app_roles.dart | Flutter exposes student, lab_admin, and super_admin as AppRole. |
| lib/shared/models/user_model.dart and lib/core/constants/app_defaults.dart | Flutter reads and writes public.users.role. |
| supabase/migrations/003_profile_ecosystem.sql and 008_profile_ecosystem_patch.sql | public.user_profiles stores extended profile data keyed to auth.users. |
| lib/features/profile/data/profile_ecosystem_repository.dart | Profile editing reads and writes public.user_profiles. |

The runtime availability of user_profiles was previously verified, but this proposal does not claim that every repository migration has been applied to the live project. A migration ledger and read-only schema inspection are required before implementation.

## Proposed Canonical Contract

### Authentication Identity

auth.users remains Supabase's authentication identity. Flutter must not invent a second identity store.

### Canonical Operational Account

public.users is proposed as the single canonical operational-account row, one row per auth.users row. It owns account-level and authorization-relevant attributes:

- id referencing auth.users(id)
- verified application email and basic account metadata already required by the application
- account_type with approved values student, faculty, and super_admin
- lifecycle flags such as active or blocked only where approved
- profile_completed only if the profile gate continues to use it
- audit timestamps

The legacy base_role, system_role, and current role fields must be reconciled into this one account-type contract by an approved migration plan. No automatic meaning may be assigned to historical Head strings.

### Extended Personal Profile

public.user_profiles is proposed as a one-to-one optional extended profile owned by the account. It stores presentation and portfolio data such as bio, department, avatar/privacy choices, education, skills, and interests through related profile tables. It is not an authorization source and does not own account type or position assignment.

### Organization Master Data

The proposed organization model uses independent tables or equivalent well-defined relations.

| Concept | Purpose |
| --- | --- |
| labs | Configurable operational scope; IDEA Lab now, additional labs later. |
| positions | Position master data. Names are configurable, not Flutter enums. |
| position_assignments | Historical and active user-to-position-to-lab records. |
| permissions | Stable capability vocabulary, not UI labels. |
| position_permissions | Approved mapping between a position and a capability. |

position_assignments must conceptually include user_id, position_id, lab_id, assigned_by, effective_from, effective_until, status, and timestamps. A partial uniqueness constraint should permit only one active assignment for a user platform-wide while allowing many users for the same position. The exact status vocabulary is not approved yet.

## Permission Evaluation

auth.uid() -> public.users account_type -> active position_assignments -> lab scope -> position_permissions capability

For elevated operations, RLS should call a small, tested authorization helper or approved server-side interface rather than repeat position-name checks in every policy. The helper design is deliberately deferred until the schema and capability vocabulary are approved.

## Migration Strategy After Approval

1. Read the live migration history, table definitions, indexes, functions, triggers, policies, and current data shape without modifying them.
2. Choose one new numbered migration after the latest canonical migration; do not rewrite existing migration history or use an ad hoc SQL-console script.
3. Add the canonical account-type column/constraint and compatibility mapping from legacy columns only after its mapping rules are reviewed.
4. Create organization relations, indexes, RLS policies, audit mechanisms, and approved seed/master data in the same reviewed migration series.
5. Update Flutter models, auth/profile contract, and feature flags in a separately scoped implementation PR with tests.
6. Remove compatibility fields only after production data, RLS, client code, and rollback evidence are verified.

## Portability

The design uses PostgreSQL relations, constraints, RLS, and authenticated client access that can run on managed Supabase during development/RC and a future college-managed Supabase deployment. Any hosted-only feature must be called out before adoption. Backups, TLS, monitoring, storage, auth-provider configuration, and incident ownership remain required before self-hosting.

## Non-Goals

- No live database inspection or mutation in this proposal.
- No migration or seed data.
- No RLS replacement or disablement.
- No hardcoded people, labs, positions, capacities, or permissions in Flutter.
- No Manufacturing Task or Machine Queue schema design.

## Approval Gate

This proposal requires Product Owner and technical/security review before any schema migration, RLS change, account-role refactor, or Admin UI implementation.

