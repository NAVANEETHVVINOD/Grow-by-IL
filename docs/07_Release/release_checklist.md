# Grow~ Release Checklist

## Pre-Release (do before every release)
- [ ] flutter analyze -> 0 issues
- [ ] flutter test -> all pass
- [ ] flutter build apk --release -> builds clean with release signing
- [ ] Test on physical device: auth, check-in, booking, admin approval
- [ ] Check Supabase: no failed queries in logs
- [ ] Bump version in pubspec.yaml (versionCode + versionName)
- [ ] Update CHANGELOG.md with what changed

## Play Store Release
- [ ] flutter build appbundle --release
- [ ] Upload .aab to Play Console (Internal Testing first)
- [ ] Test internal track on 2+ devices
- [ ] Promote to Production

## Post-Release
- [ ] Monitor Crashlytics for 24 hours
- [ ] Check Supabase query performance
- [ ] Verify RLS policies are active

## Emergency Rollback
- If critical bug: use Play Console to roll back to previous release
- If data corruption: see docs/release_rollback.md
[Local identifier or configuration omitted from public historical copy.]
