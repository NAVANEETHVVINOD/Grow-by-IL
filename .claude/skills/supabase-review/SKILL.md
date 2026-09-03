---
name: supabase-review
description: Use when reviewing or writing Supabase schema, migrations, queries, or RLS policies — anything touching supabase/ or a repository that talks to Supabase.
---

# Supabase Review

## Canonical sources

- `CODING_STANDARD.md` §"Supabase Standards".
- `docs/04_Security/security_policy.md` — the actual current RLS policy SQL
  for shipped tables (`user_profiles` and profile child tables, `avatars`
  storage bucket) and their pattern (`user_id = auth.uid()`).
- `SECURITY.md` — reporting/scope; treats RLS bypass and unreviewed RLS
  changes as security issues, not ordinary bugs.
- `docs/02_Architecture/MODULE_LIFECYCLE.md` gates 5–7 (DB Architecture,
  Repository/API, Backend Sync & RLS) — what must be true before schema or
  RLS work is allowed to merge for a given module.
- `.github/ci/architecture_guard_paths.txt` — blocks all of
  `supabase/migrations/` until a module's DB architecture is approved. This
  applies regardless of how small the migration looks.
- `supabase/migrations/` — read the existing numbered migrations
  (`001_initial_schema.sql` … `008_profile_ecosystem_patch.sql`,
  `rc43_backend_authority.sql`) to see actual current schema and RLS
  patterns before proposing new ones; don't assume `docs/03_Database/*_ERD.md`
  files reflect what's actually migrated (they're planning docs, not schema
  truth).

## Checks to run

1. **Gate check first**: is this migration/schema change for a module that
   has cleared Phase 5 (DB Architecture) approval? If not, this shouldn't be
   proposed as a mergeable migration at all — say so.
2. **RLS on every table**: no new table ships without a SELECT/INSERT/UPDATE/DELETE
   policy set matching the `user_id = auth.uid()` ownership pattern (or an
   explicit, reviewed reason it differs, e.g. `is_public = true` reads).
3. **No service_role in client code**: frontend must only ever use the
   `anon` key. Grep for `service_role` in any Dart file — CI's secret scan
   already blocks this, but catch it in review too.
4. **No unbounded queries or broad realtime streams** — CODING_STANDARD.md
   explicitly calls these out; check `.limit()`/pagination and realtime
   channel scope.
5. **Indexes added with query patterns**, not as an afterthought.
6. **Migration linting**: currently *not* enforced in CI (intentionally,
   until Phase 2 database architecture restores it) — don't assume a green
   CI run means the migration was linted.

## Workflow

1. Read the relevant existing migration(s) and the corresponding
   `docs/03_Database/*_ERD.md` planning doc (if one exists) side by side —
   flag any mismatch rather than trusting either alone.
2. Verify RLS policies against `docs/04_Security/security_policy.md`'s
   pattern before approving new ones.
3. Confirm the change doesn't touch a path blocked by
   `.github/ci/architecture_guard_paths.txt`.
