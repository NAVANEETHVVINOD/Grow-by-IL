# Grow~ — Development Roadmap

## Status Legend
- ✅ Complete and verified
- 🟡 Partial (UI done, logic incomplete)
- 🔲 Not started
- 🚀 Next task

---

## Completed

### ✅ Task 1 — Project Scaffold
Flutter project created. Feature-first folder structure. pubspec.yaml with
all 18 dependencies. main.dart with ProviderScope and Supabase init.

### ✅ Task 2 — Design System
AppColors, AppSizes, AppTheme (Space Grotesk + DM Sans).
NeoCard, NeoButton, NeoChip, NeoTextField, ShimmerSkeleton.
Neo-brutalist: yellow accent, navy borders, flat 4px offset shadows.

### ✅ Task 3 — Navigation & Shell
GoRouter with StatefulShellRoute. 5-tab bottom nav with yellow pill highlight.
All routes registered. Route guards for auth and profile completion.

### ✅ Task 4 — Supabase Schema & Models
11-table PostgreSQL schema in supabase/schema.sql.
8 Dart models: User, Tool, Booking, Event, RSVP, Project, LabSession, Notification.
RLS enabled on all tables.

### ✅ Task 5 — Auth System (Enhanced)
Register, Login, SignOut with session persistence.
Splash screen with route guard (checks auth + profile_completed).
Onboarding (3 pages). Profile setup flow (username, base_role, skills, interests).
Two-layer role system: base_role (student/faculty) + system_role (admin-assigned).
AuthRepository with AppLogger and handleSupabaseError().

### ✅ Task 6 — Home Screen
Full dashboard: avatar header, notification bell, 2x2 animated action grid
(Check In / Book a Tool / Events / My Projects), live visitor count,
upcoming events section, active projects section.
FadeTransition on load. ShimmerSkeleton loading states.
Independent FutureProviders per section.

### ✅ Task 7 — Lab Check-In System
lab_repository.dart: checkIn(), checkOut(), getActiveSession(),
getLiveVisitorCount() (Supabase realtime stream), getMyHistory().
lab_providers.dart: activeSessionProvider, liveLabVisitorCountProvider (StreamProvider),
mySessionHistoryProvider.
lab_screen.dart: Two-state screen (not checked in / checked in with HH:MM:SS timer).
Green pulsing dot. Session history list. Report issue bottom sheet.
qr_scan_screen.dart: mobile_scanner camera with web fallback.
user_qr_card.dart: QR card widget + showUserQrCard() bottom sheet.
Session heartbeat (Timer.periodic 5min in main_shell.dart).
DB constraint: unique active session per user (no duplicate check-ins).

### ✅ Security & Logging Pass
AppLogger (info/warn/error/action) applied to all repositories.
handleSupabaseError() maps Supabase exceptions to user-friendly messages.
Route guard in app_router.dart covers all auth/unauth cases.
Sign out auto-checks out active lab session before clearing auth.
5 race condition bugs fixed: duplicate provider, double check-in,
ghost sessions on sign-out, async signOut race, null crash on checkinTime.
RLS policies verified on lab_sessions table.

---

## In Progress

### 🟡 Task 11 — Profile & Gamification (Partial)
Profile screen UI built: avatar, @username, role badge, skills/interests chips,
XP progress bar (visual only), stats row (4 tiles), My QR button, Edit Profile stub,
Sign Out (red outlined NeoButton at bottom).
NOT YET DONE: Real XP system, badge unlocking, leaderboard, GitHub graph,
portfolio items, Edit Profile wired up.

---

## Remaining Tasks

### 🚀 Task 8 — Tool Catalog & Booking (NEXT)
What to build:
- tool_repository.dart: getTools(), getToolById(), createBooking(),
  approveBooking(), checkoutTool(), returnTool(), getOverdueBookings()
- tool_providers.dart: toolsProvider, myBookingsProvider
- tool_catalog_screen.dart: 2-col grid, search, category filter chips,
  tool cards with availability NeoChip, Book button, selected state (yellow border)
- booking_screen.dart: bottom sheet — date chips (7 days), time slot picker,
  duration selector, project link dropdown, "Request Booking" NeoButton
- QR return flow: scan GROWLAB-TOOL-{id} → find active booking → checkout/return
- RLS: tools readable by all auth users, bookings CRUD own rows,
  op_head can see/approve all bookings
- Tool status: available / in_use / maintenance / retired
- Return enforcement: overdue auto-block on future bookings
- Conflict prevention: check existing bookings before showing slots

New routes needed: /tools (catalog), /tools/:id (detail), /tools/:id/book

### 🔲 Task 9 — Events & RSVP
- event_repository.dart + providers
- events_screen.dart: tabs (Upcoming / My RSVPs / Past)
- event_detail_screen.dart: full info + RSVP button
- QR ticket: qr_flutter, data = "GROWLAB-RSVP-{rsvpId}"
- Coordinator scan mode: scan ticket → mark checked_in_at
- RLS: events readable by all, RSVPs own rows

New routes needed: /events/:id, /events/:id/scan

### 🔲 Task 10 — Projects & Teams
- project_repository.dart + providers
- projects_screen.dart: My Projects + All Projects + Create FAB
- create_project_screen.dart: title, description, club, visibility
- project_detail_screen.dart: 3 inner tabs (Overview / Team / Updates)
- Team invite: project QR code → join request → admin approve
- Resource allocation: request tools from within project
- Project stages: Ideation → In Progress → Completed → Showcase

New routes needed: /projects, /projects/create, /projects/:id

### 🔲 Task 11 — Full Profile & Gamification
Complete the partial profile:
- Real XP system (XpService: awardXP(), recalculate level, badge check)
- Badge unlocking (12 badge types, trigger-based)
- Leaderboard (top 10 by XP, opt-in)
- GitHub contribution graph (github-contributions-api.jogruber.de)
- Portfolio items (portfolio_items table + CRUD)
- Edit Profile bottom sheet wired up
- profile_repository.dart

### 🔲 Task 12 — Admin Panel
- admin dashboard with 4 metric cards
- Inventory management (add/edit/remove tools, health status)
- Booking approvals queue (approve/reject, overdue list)
- Member management (change system_role, block/unblock)
- Analytics (daily check-ins, peak hours, most used tools)
- CSV export for AICTE documentation
- Role gate: only system_role IN ('admin', 'operation_head', 'faculty')

New routes needed: /admin/inventory, /admin/approvals, /admin/members, /admin/analytics

### 🔲 Task 13 — Push Notifications & Final Polish
- Firebase Cloud Messaging setup (add google-services.json)
- FCM token saved to users.fcm_token column
- Notification types: booking approved/reminder/overdue, event reminder,
  XP earned, project invite
- flutter_local_notifications for foreground display
- All loading states → ShimmerSkeleton
- All error states → Icons.error_outline + retry
- All empty states → icon + message
- HapticFeedback on all NeoButton taps
- Pull to refresh on all list screens
- App icon configured (IdeaLab logo)
- flutter build apk --release verified clean

---

## Features Deferred (Post-MVP)
- GitHub contribution graph (Task 11)
- Portfolio system (Task 11)
- Knowledge base / SOP library
- Donation page
- Explore tab (services listing)
- Web admin dashboard

---

## Development Rules (Always Active)
1. flutter analyze → 0 issues before marking any task done
2. flutter build apk --debug after each task (catches what web runner misses)
3. Never stack unverified features
4. Test real device flow after each task
5. No emojis — Material Icons only
6. All new strings → AppStrings
7. All new routes → app_router.dart
8. All new screens handle: loading / error / empty states
9. Never disable RLS
10. AppLogger on every repository method

---

_Grow~ Roadmap | MEC IdeaLab | Updated: May 2026_
