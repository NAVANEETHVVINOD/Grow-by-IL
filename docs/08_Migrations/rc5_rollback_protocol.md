# RC5 Rollback Protocol

This document outlines the standard operating procedures and rollback actions for failure scenarios identified during the RC5 release.

## CURRENT IMPLEMENTATION STATUS
* **Rollback Infrastructure**: `Status: fully implemented` - Supported by compile-time feature flags and table schema rollback scripts.

---

## 1. Rollback Protocol Matrix

If production issues occur, refer to this matrix for immediate operational actions:

| Scenario / Failure State | Root Cause Indicator | Operational Rollback Action |
| --- | --- | --- |
| **Migration Corruption** | Duplicate profiles or RLS permission rejections during onboarding. | **Disable Migration Flag**: Flip `FeatureFlags.kEnableProfileMigration = false` and release hotfix. User immediately drops back to SharedPreferences local-only drafts. |
| **Replay Deadlock** | Replay loops, async lock timeout alerts, or DB connection pooling depletion. | **Pause Replay Queue**: Temporarily disable replay scheduler or trigger manual pause via Developer Sync Diagnostics. |
| **Stale Write Storm** | Flapping network states resulting in high CPU usage or massive conflict logs. | **Disable Optimistic Replay**: Discard conflicted queue payloads and enforce manual user retry trigger. |
| **Auth Replay Failure** | Rapid invalid sessions triggering unauthorized API exceptions. | **Suspend Replay Queue**: The engine auto-halts replay if session is null/expired, retaining queue intact in SharedPreferences cache. |
| **Schema Mismatch** | DB column differences causing parsing or insert exceptions. | **Rollback Schema Version**: Run local sql down-migration script and reset the schema version counter on client. |
| **Release Crash Spike** | Severe client crashes or Riverpod invalidation storm. | **Revert Release Tag**: Roll back git branch tag in CI/CD pipeline and re-deploy the previous validated build. |

---

## 2. Step-by-Step Scenario Responses

### 2.1 Emergency Deactivation of Sync Engine
If users are locked out due to sync engine locks, immediately release a hotfix with:
```dart
// lib/core/constants/feature_flags.dart
static const bool kEnableProfileMigration = false;
```
This forces the app to bypass Supabase profile lookups and rely entirely on local SharedPreferences onboarding keys.

### 2.2 Schema Reversion
If DB schema requires physical reversion, execute:
```bash
# Apply rollback snapshot SQL
supabase db reset
```
And reset the local cache version inside SharedPreferences using the Developer Dashboard.
