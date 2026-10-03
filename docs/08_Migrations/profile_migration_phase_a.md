# Profile Migration Phase A - Operational Playbook

> **Safety notice (2026-09-17):** This historical playbook has not been
> reconciled against the live project in the current audit. Do not run its
> commands against a shared or production database. In particular, a database
> reset is destructive and is **not** a production rollback. First compare
> live migration history, schema, grants, and RLS with the repository; prepare
> and review a forward-only repair and a tested recovery plan.

This document describes the operational playbook for migrating profile and onboarding data from SharedPreferences to Supabase relational tables.

## CURRENT IMPLEMENTATION STATUS
* **Phase A Code Integration**: `Status: production validated` - All repositories, double-write controllers, and unit tests have been successfully implemented and tested locally.
* **Database Schema Application**: `Status: migration pending` - The migrations are ready in the `supabase/migrations/` folder but must be run on the production database.

---

## 1. Migration Overview

The migration shifts user profile drafts from the key-value `SharedPreferences` cache to structured relational tables in Supabase:
- `user_profiles` (basic metadata & privacy settings)
- `user_skills` (skills & proficiency levels)
- `user_interests` (personal focus areas)
- `user_education` (academic credentials)
- `user_experience` (work history)
- `user_social_links` (GitHub, LinkedIn, and website)

---

## 2. Onboarding & Username Backfills

To preserve existing users and prevent onboarding disruption:
- **Username Generation**: Lowercase the local part of the email address, strip out special characters, replace spaces with underscores, and add numeric suffixes in case of unique constraints violations.
- **Onboarding Progress Resume**: Existing users with completed profiles are marked `migrated`. Incomplete users resume onboarding at the appropriate onboarding screen draft step using cached SharedPreferences parameters.
- **Notification Category Migration**: Existing notification records will map onto structured categories (`system`, `event`, `project`, `booking`, `community`, `opportunity`, `vouch`).

---

## 3. Step-by-Step Procedure

### Step 3.1: Pre-Migration Backup
Before running any migrations, execute a backup of all existing RLS policies and table structures:
```bash
# Snapshot currently applied schema and policies
supabase db export --output schema_snapshot.sql
```

### Step 3.2: Apply Migrations
Apply the local SQL migration scripts (files `003` to `006` in `supabase/migrations/`) to your Supabase project:
```bash
supabase db push
```

### Step 3.3: Verification of Database Tables
Query the database to verify all tables are successfully created:
```sql
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'user_%';
```

### Step 3.4: Enable Feature Flag
Verify that `kEnableProfileMigration` is set to `true` in `lib/core/constants/feature_flags.dart`.

---

## 4. Compatibility & Route Redirection

Ensure old routes redirect correctly to the new RC5 shell interfaces:
- `/explore` redirects to `/home` (Discover sections)
- `/lab` redirects to `/akathalam`
- `/events` redirects to `/akathalam/events`

---

## 5. Rollback Strategy

If production incidents occur (such as CPU spikes, circular dependency loops, or locking issues):
1. **Disable Feature Flag**: Set `kEnableProfileMigration = false` in `lib/core/constants/feature_flags.dart` and deploy a hotfix. This immediately stops the sync service and mutex coordinator from running, falling back to local SharedPreferences read/write paths.
2. **Database recovery**: Do not use `supabase db reset` on shared or
   production data. Restore only from a verified backup or apply a separately
   reviewed forward repair after assessing affected data, policies, and
   dependent clients.
