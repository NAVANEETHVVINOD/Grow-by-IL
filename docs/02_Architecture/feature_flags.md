# Grow~ Feature Flags Reference

This document details the feature flags governing both the UI rollout and the backend profile synchronization system in Grow~.

## CURRENT IMPLEMENTATION STATUS
* **UI & Migration Flags**: `Status: fully implemented` - Controlled by constants inside `FeatureFlags` class in `lib/core/constants/feature_flags.dart`.

---

## 1. Feature Flag Definitions

### `enableAkathalam`
- **Type**: `bool`
- **Location**: `FeatureFlags.enableAkathalam` (default: `true`)
- **Description**: Gates the Akathalam tab interface. Enabled by default as RC5 shell depends on it.

### `enableNewProfile`
- **Type**: `bool`
- **Location**: `FeatureFlags.enableNewProfile` (default: `true`)
- **Description**: Profile rollout guard. Allows quick rollback of the profile UI without rewriting client route files.

### `enableVouches`
- **Type**: `bool`
- **Location**: `FeatureFlags.enableVouches` (default: `false`)
- **Description**: UI placeholder flag. Kept disabled until the corresponding backend systems are ready.

### `kEnableProfileMigration`
- **Type**: `bool`
- **Location**: `FeatureFlags.kEnableProfileMigration` (default: `true`)
- **Description**: Gates the safe onboarding migration engine. When `true`, the app attempts to migrate SharedPreferences profiles to Supabase. When `false`, it halts migration checks and behaves as a local-only key-value store.

---

## 2. Rollout & Rollback Rules

- **Default Off**: Keep flags `false` unless a features slice is fully validated and ready for rollout.
- **Never Hide Security**: Never rely on UI feature flags to gate security checks. Admin/owner privileges must always be validated via database RLS checks.
- **Emergency Rollback**: If a profile sync deadlock or DB locking issue occurs:
  1. Flip `kEnableProfileMigration` to `false`.
  2. Release/deploy a hotfix. The client will fall back to using SharedPreferences onboarding drafts, preventing users from getting stuck in load loops.
