# Grow~ RC4.4 Performance Baseline

Date: 2026-05-22

## Test Environment
- Device: vivo 1726, Android 8.1
- Flutter: 3.41.9 stable
- Test mode: Flutter integration test debug builds for automation; release profile still required after signing files are present.
- Backend: Supabase project configured through dart-defines.

## Current Verified Gates
- Database integrity tests: passing
- Auth smoke test: passing
- Booking smoke test: passing
- Admin approval smoke test: passing
- Provider stream diagnostics: active stream count returns to 0 after smoke runs
- flutter analyze: 0 issues

## Current Observations
- Rebuilt integration tests now verify database state instead of only UI text.
- Booking smoke verifies a real pending tool_bookings row.
- Admin smoke verifies admin role, booking approval, and notification fanout.
- Notification trigger and test account fixes were applied in the live database before the latest verification pass.

## Release Profile Targets
- Startup to usable screen: less than 3 seconds
- Frame build time: less than 16 ms
- Raster time: less than 8 ms
- Supabase user-facing query time: less than 150 ms for cached/common paths
- Active realtime stream count: stable after route changes and returns to 0 after logout/test teardown

## Follow-Up Measurement
- Run `flutter run --profile` on the physical device after release signing is available.
- Capture DevTools frame chart for Home, Tools, Notifications, and Admin approval.
- Record Supabase query timings from app logs and Supabase dashboard logs.
