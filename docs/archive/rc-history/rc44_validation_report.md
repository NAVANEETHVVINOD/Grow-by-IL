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
- Status: Fixed locally, awaiting rerun.

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
- Status: Migration file created, live DB still needs the SQL applied.

### RC44-005: Configured admin test account is not an app admin

- Severity: P0 test data blocker
[Local identifier or configuration omitted from public historical copy.]
- Impact: Admin approval E2E cannot be trusted until the admin test account has `role = lab_admin` or `role = super_admin` in `public.users`.
- Required fix: Run `grow/supabase/rc44_test_data_fix.sql` in the test/staging database, or run tests with `TEST_ADMIN_EMAIL` and `TEST_ADMIN_PASSWORD` pointing at a real admin account.
- Status: SQL fix file created, live DB still needs test data update.

## Current Verified Passes

- `flutter analyze`: 0 issues after test-suite restructure.
- `integration_test/smoke_auth_test.dart`: passed on physical device.
- `integration_test/smoke_booking_test.dart`: passed on physical device and verified a real pending `tool_bookings` row.
- `test/database/booking_integrity_test.dart`: passed, DB overlap constraint is active.
- `test/database/notification_integrity_test.dart`, cross-user notification RLS probe: passed, student cannot notify another user.

## Test Quality Notes

- The suite currently passes, but several files still contain weak assertions such as `expect(true, true)`.
- Full directory execution still rebuilds/reinstalls once per integration file, which is slow.
- Recommended next hardening step: create `integration_test/release_smoke_test.dart` as a single fast gate for release validation.
