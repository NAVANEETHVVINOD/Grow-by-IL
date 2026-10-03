# Repository Cleanup Report

Status: Draft
Last updated: 2026-08-07

## 1. Unused Screens
- Review legacy screens under lib/features/profile/presentation/screens and lib/features/home/presentation/screens for routes that are no longer active in the main shell
- Candidate screens to audit: profile_screen.dart, onboarding_screen.dart, debug_schema_screen.dart

## 2. Unused Widgets
- Inspect shared widgets that are no longer referenced by current feature screens
- Review rc5 widgets for duplication with existing Material widgets or feature-local components

## 3. Unused Providers
- Audit Riverpod providers in lib/features/*/domain and lib/shared/providers for stale state and providers that no longer have subscribers
- Focus on provider files tied to older profile and home flows

## 4. Duplicate Models
- Compare feature models that appear to represent similar concepts such as user profile, event, and project entities across multiple folders
- Consolidate where the app now relies on a single shared model shape

## 5. Duplicate Docs
- Reconcile overlapping content between docs/02_Architecture and docs/03_Database planning files
- Prefer canonical docs with pointers from secondary references

## 6. Dead Routes
- Review lib/core/router/app_router.dart for routes that are no longer reachable or are only used for debugging and should be guarded
- Consider moving experimental routes behind feature flags or a debug-only route group

## 7. Legacy Code
- Identify old profile implementations and older onboarding screens that remain alongside newer RC5 flows
- Keep the latest path active and archive the legacy path where possible

## 8. Files > 1000 Lines
- lib/features/profile/presentation/screens/rc5_profile_screen.dart (reported to be large and worth splitting)
- Any large feature screens or provider files should be assessed for extraction into smaller widgets and services

## 9. Potential Refactors
- Split large profile screen into smaller UI sections
- Convert repeated widget compositions into shared RC5 widgets
- Replace feature-local business logic with repository-backed services where appropriate
