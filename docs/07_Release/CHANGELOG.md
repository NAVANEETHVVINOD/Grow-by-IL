# Changelog

## [1.0.0] - 2026-05-22
### Added
- Lab QR check-in and check-out
- Tool catalog and booking system with admin approval
- Project and team management
- Event RSVP
- Role-based admin dashboard (lab_admin, super_admin)
- Google Sign-In with Firebase
- Real-time lab visitor count
- Realtime notification infrastructure

### Infrastructure
- Supabase RLS on all 11 tables
- Schema drift CI (schema_check.yml)
- Focused unit, smoke, and database-integrity tests
- Release APK signing configured
