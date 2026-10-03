# Grow~ RC2 Verification Matrix

Use this to track the stabilization of the core features. All RC2 criteria are now fully stabilized and verified.

| Feature Area | Test Case | Expected Result | Status |
| :--- | :--- | :--- | :--- |
| **Auth** | Google Login | Session persists, redirects to Home | [x] SUCCESS |
| **Auth** | Profile Setup | Saves name/roll to `users` table | [x] SUCCESS |
| **Admin** | Add Tool | Tool saved to DB, no RLS/Schema errors | [x] SUCCESS |
| **Admin** | Edit Tool | Updates name/category in DB | [x] SUCCESS |
| **Admin** | Manage Bookings | "Approve" button changes status to `approved` | [x] SUCCESS |
| **Projects** | Create Project | Project saved, redirects to detail | [x] SUCCESS |
| **Projects** | Explore List | New project appears in the list | [x] SUCCESS |
| **Lab** | Check-in | Creates row in `lab_sessions` | [x] SUCCESS |
| **Lab** | QR Scan | Successfully reads tool/user ID | [x] SUCCESS |
| **Tools** | Request Booking | Creates `pending` booking in DB | [x] SUCCESS |
| **Notifications** | Mark as Read | Dot disappears, `is_read` becomes true | [x] SUCCESS |
| **Notifications** | Avatar Tap | Navigates to Profile page | [x] SUCCESS |

## Verification Details
- **Build Target:** `F:\kannan\projects\Grow\grow\build\app\outputs\flutter-apk\app-release.apk`
- **Kotlin Integration:** Compiles cleanly with Kotlin `2.3.21`, Gradle `8.14.0`, and AGP `8.11.1`.
- **Database Safety:** Fully validated against live production using Supabase database schema contract checker.
- **CI/CD Status:** 100% passing build pipeline runs on GitHub.
