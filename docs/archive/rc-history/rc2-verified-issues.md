# RC2 Verified Issues Tracking
Last Updated: 2026-05-17

# 🔴 RESOLVED & VERIFIED
- [x] **Add Tool Flow**: Verified that adding a tool from the admin panel succeeds seamlessly on a physical device. Complete with zero RLS or schema constraint violations.
- [x] **Notification UI**: Dark mode colors are fully optimized, readable, and match the high-fidelity Neo-brutalist theme palettes.
- [x] **My Projects Button**: Correctly redirected and mapped to point to the personalized user project dashboard instead of the generic explore screen.
- [x] **Notification Overflow**: Fixed with `Wrap` and `Flexible` layouts.
- [x] **Rejection Status**: Code now uses `cancelled` to match DB constraint.
- [x] **action_url Removal**: Purged from all code and models.
- [x] **Safe Error Handling**: Notification inserts now wrapped in `try/catch`.

# 🟡 AUDIT CLAIMS RESOLVED
- [x] **Role Mismatch**: Proved that `users` table uses `system_role` and `base_role` columns exactly as intended by our two-layer governance system. Code is fully clean.
- [x] **Missing event_date**: Confirmed that `events` uses `start_time` consistently and cleanly throughout all models and views. Stale index claims are removed.
- [x] **FCM Token Security**: Validated FCM tokens security configuration. Tokens are secured behind Supabase's hardened table RLS policies and not exposed.
- [x] **Google OAuth**: Unused components cleaned up, and active OAuth flow optimized in `google_auth_service.dart` with build-time parameters.
