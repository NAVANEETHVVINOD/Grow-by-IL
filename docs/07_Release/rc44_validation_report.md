# Grow~ RC4.4 Validation Report

## Latest Full Integration Run

- Date: 2026-05-22
[Local identifier or configuration omitted from public historical copy.]
[Local identifier or configuration omitted from public historical copy.]
- Result: Passed, 5/5 integration files
- Runtime: About 12 minutes

## Confirmed Issues Found

### RC44-001: Provider observer active stream count went negative

- Severity: P1 observability
- Evidence: Full integration logs reported `Active Streams: -1` during booking flow teardown.
- Impact: Realtime leak diagnostics become untrustworthy during release testing.
- Fix: Track stream providers by actual provider runtime type, clamp/remove counts at zero, and report total active streams.
- Status: Fixed and verified. Later smoke runs returned active stream count to 0.

### RC44-002: Test seed script contained a hardcoded Supabase key

- Severity: P1 security/release hygiene
- Evidence: `scripts/seed_test_users.dart` embedded a project URL and JWT-like anon key.
- Impact: Easy to accidentally commit operational credentials during release prep.
- Fix: Script now requires `SUPABASE_URL` and `SUPABASE_ANON_KEY` environment variables.
- Status: Fixed locally.

### RC44-003: Soak runner did not pass required app configuration

- Severity: P2 release automation
- Evidence: `scripts/run_soak_test.ps1` invoked Flutter without required `--dart-define` values.
- Impact: Soak runs could fail from missing config or accidentally use inconsistent local shell state.
- Fix: Script now validates required environment variables and passes them to Flutter.
- Status: Fixed locally.

### RC44-004: Booking approval does not fan out a notification in live DB

- Severity: P0 release blocker
- Evidence: `test/database/notification_integrity_test.dart` failed after admin approval. The booking status changed, but no notification appeared for the booking owner.
- Impact: Admin approval can succeed while the student never receives a notification.
- Likely cause: The live database has the booking overlap constraint, but does not yet have the RC4.3 notification trigger migration applied.
- Required fix: Apply `grow/supabase/migrations/rc44_notification_trigger_fix.sql`, then rerun `flutter test test/database`.
- Status: Fixed and verified. `flutter test test/database` passed after SQL application.

### RC44-005: Configured admin test account is not an app admin

- Severity: P0 test data blocker
[Local identifier or configuration omitted from public historical copy.]
- Impact: Admin approval E2E cannot be trusted until the admin test account has `role = lab_admin` or `role = super_admin` in `public.users`.
- Required fix: Run `grow/supabase/rc44_test_data_fix.sql` in the test/staging database, or run tests with `TEST_ADMIN_EMAIL` and `TEST_ADMIN_PASSWORD` pointing at a real admin account.
- Status: Fixed and verified. Admin smoke resolved `rawRole=lab_admin` and passed on device.

## Current Verified Passes

- `flutter analyze`: 0 issues after test-suite restructure.
- `flutter test`: 60/60 passed, including live database integrity tests.
- `integration_test/smoke_auth_test.dart`: passed on physical device.
- `integration_test/smoke_booking_test.dart`: passed on physical device and verified a real pending `tool_bookings` row.
- `integration_test/smoke_admin_test.dart`: passed on physical device and verified approval plus notification fanout.
- `test/database/booking_integrity_test.dart`: passed, DB overlap constraint is active.
- `test/database/notification_integrity_test.dart`, cross-user notification RLS probe: passed, student cannot notify another user.
- `test/database/notification_integrity_test.dart`, admin approval fanout: passed, DB trigger creates the notification.

## Release Engineering Status

- `android/app/build.gradle.kts` now uses the `release` signing config instead of debug signing.
- `android/key.properties` and `android/upload-keystore.jks` are ignored by git.
- Signed release APK builds successfully at `build/app/outputs/flutter-apk/app-release.apk`.
- Signed release APK installs successfully on vivo 1726.
- Release startup passes: app process stays alive, crash buffer is empty, and the login screen renders.
- Google Sign-In release blocker was fixed by updating `google-services.json` with Android OAuth clients and rebuilding with the matching web client ID.
- Signed release Google login verified on vivo 1726: app reached authenticated Home screen, process stayed alive, and crash buffer was empty.
- Play Store app bundle builds successfully at `build/app/outputs/bundle/release/app-release.aab`.
- Release keystore fingerprints to register in Firebase/Google Cloud:
  - SHA1: `F9:F4:1F:E1:CD:63:8A:53:70:15:2E:01:E5:68:BE:93:4B:A2:00:73`
  - SHA256: `C9:5A:EE:5E:B0:B4:55:67:39:5A:4D:34:E1:A5:3A:A0:61:BE:97:AA:79:C0:1A:1C:B6:28:50:3E:5F:84:84:7F`

## Test Quality Notes

- Fake assertions such as `expect(true, true)` have been removed from the active smoke and database test paths.
- Full directory execution still rebuilds/reinstalls once per integration file, which is slow.
- Recommended next hardening step: create `integration_test/release_smoke_test.dart` as a single fast gate for release validation.
