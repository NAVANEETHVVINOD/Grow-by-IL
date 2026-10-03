# Grow~ Platform - RC1 Release Baseline

## Release Information
- **Release Candidate**: RC1 (Stable Baseline)
- **Status**: FROZEN & STABLE
- **Commit Hash**: `c7b23bd`
- **Build Date**: 2026-05-09
- **Environment**: Production (Supabase Live)

## Build Status
- **Android**: `√ Built build\app\outputs\flutter-apk\app-release.apk (70.1MB)`
- **Infrastructure**: Stabilized `gradle.properties` with 6GB JVM Heap.
- **`flutter analyze`**: No issues found.

## Core Tested Flows
1. **Authentication**: 
   - Google Sign-In (Functional)
   - Profile Auto-Sync (Fixes PGRST116)
   - Splash Redirect (Stable)
2. **Lab Operations**:
   - Check-in / Check-out (Functional)
   - Active Session Persistence (Stable)
   - Tool Booking Overlap Validation (Operational)
3. **Project Management**:
   - Project Discovery (Explore Tab)
   - Join/Leave Team (Functional)
   - Schema Drift aligned (`users.name` mapping fixed)
4. **Events**:
   - Event Listing (Functional)
   - Schema Aligned (`start_time` migration verified)

## Known Limitations (RC1 Scope)
- **Project Updates**: Incomplete. Tab hidden in UI; repository stubbed. (Scheduled for RC2/RC3).
- **Admin Panel**: Minimal/Placeholder. Routing is defined but logic is not yet role-guarded at the DB level.
- **Reporting**: "Report Issue" in Lab logs to terminal; no database persistence yet.

## Rollback Instructions
To return to this stable baseline:
1. `git checkout c7b23bd`
2. `flutter clean`
3. `flutter pub get`
4. Use stabilized `gradle.properties` provided in this commit.

---
*This document serves as the official baseline for Grow~ RC1. All subsequent changes are part of the RC2 Operations Layer.*
