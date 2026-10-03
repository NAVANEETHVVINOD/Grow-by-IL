# IdeaLab Flutter App — AI IDE Task Prompts
# Feed these to your AI IDE (Cursor / Windsurf / any AI coder) ONE AT A TIME.
# Wait for each task to complete and verify before moving to the next.
# Each prompt is self-contained and references the ones before it.

---

# ════════════════════════════════════════
# TASK 1 — Project Scaffold & Folder Structure
# ════════════════════════════════════════

## Paste this into your AI IDE as the FIRST prompt:

```
Create a new Flutter project called "idealab" with the following setup:

PROJECT INFO:
- App name: IdeaLab
- Package name: com.idealab.mec
- Flutter 3.x, Dart 3.x
- Minimum iOS: 13, Android: 21

PUBSPEC.YAML — add these dependencies:
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^13.2.0
  supabase_flutter: ^2.3.4
  firebase_core: ^2.27.0
  firebase_messaging: ^14.7.19
  mobile_scanner: ^5.2.3
  qr_flutter: ^4.1.0
  image_picker: ^1.1.2
  cached_network_image: ^3.3.1
  flutter_local_notifications: ^17.0.0
  intl: ^0.19.0
  shared_preferences: ^2.2.3
  dio: ^5.4.3
  google_fonts: ^6.2.1
  flutter_svg: ^2.0.10+1
  timeago: ^3.6.1
  uuid: ^4.3.3

dev_dependencies:
  riverpod_generator: ^2.3.11
  build_runner: ^2.4.9
  flutter_lints: ^3.0.1
  riverpod_lint: ^2.3.10

CREATE THIS EXACT FOLDER STRUCTURE under lib/:

lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart       (empty file, we fill next task)
│   │   ├── app_strings.dart      (empty file)
│   │   └── app_sizes.dart        (empty file)
│   ├── theme/
│   │   └── app_theme.dart        (empty file)
│   ├── router/
│   │   └── app_router.dart       (empty file)
│   └── utils/
│       ├── extensions.dart       (empty file)
│       └── validators.dart       (empty file)
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       └── screens/
│   ├── home/
│   │   └── presentation/
│   │       └── screens/
│   ├── explore/
│   │   └── presentation/
│   │       └── screens/
│   ├── events/
│   │   └── presentation/
│   │       └── screens/
│   ├── lab/
│   │   └── presentation/
│   │       └── screens/
│   ├── projects/
│   │   └── presentation/
│   │       └── screens/
│   ├── profile/
│   │   └── presentation/
│   │       └── screens/
│   └── admin/
│       └── presentation/
│           └── screens/
├── shared/
│   ├── widgets/
│   ├── models/
│   └── repositories/
└── main.dart

In main.dart put ONLY:
- ProviderScope wrapper
- MaterialApp.router placeholder
- A comment: // Theme and router wired in Task 2 and Task 3

Create a placeholder home screen at:
features/home/presentation/screens/home_screen.dart
that shows a Scaffold with AppBar title "IdeaLab" and body Center(child: Text("Task 1 complete")).

Run flutter pub get and confirm the app builds and shows the placeholder screen.
```

---

# ════════════════════════════════════════
# TASK 2 — Design System (Colors, Typography, Theme)
# ════════════════════════════════════════

## After Task 1 is done and builds. Paste this next:

```
We are building a NEOBRUTALIST design system for the IdeaLab Flutter app.
Reference: the Gemini-generated design uses thick black borders, flat offset shadows,
electric yellow primary, navy dark, off-white background.

Fill in these files:

━━━ lib/core/constants/app_colors.dart ━━━
class AppColors {
  // Backgrounds
  static const background = Color(0xFFF5F5F0);    // warm off-white
  static const surface = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF0D0F1C);    // deep navy

  // Primary palette
  static const yellow = Color(0xFFFFD60A);         // electric yellow (primary accent)
  static const navy = Color(0xFF0D0F1C);           // primary dark
  static const cobalt = Color(0xFF1A56FF);         // blue accent
  static const green = Color(0xFF2ECC71);          // available/success
  static const red = Color(0xFFFF3B3B);            // error/in-use
  static const orange = Color(0xFFFF6B35);         // warning

  // Text
  static const textPrimary = Color(0xFF0D0F1C);
  static const textSecondary = Color(0xFF5A5A6A);
  static const textOnDark = Color(0xFFF5F5F0);
  static const textOnYellow = Color(0xFF0D0F1C);

  // Neobrutalist shadows (flat, no blur)
  static const shadowOffset = Offset(4, 4);
  static const shadowColor = Color(0xFF0D0F1C);

  // Status chips
  static const available = Color(0xFF2ECC71);
  static const inUse = Color(0xFFFF3B3B);
  static const pending = Color(0xFFFF6B35);
  static const maintenance = Color(0xFF9B59B6);
}

━━━ lib/core/constants/app_sizes.dart ━━━
class AppSizes {
  // Border
  static const borderWidth = 2.0;
  static const borderWidthThick = 3.0;

  // Shadow
  static const shadowX = 4.0;
  static const shadowY = 4.0;

  // Border radius
  static const radiusSm = 8.0;
  static const radiusMd = 12.0;
  static const radiusLg = 16.0;
  static const radiusXl = 24.0;

  // Spacing
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;

  // Component heights
  static const buttonHeight = 52.0;
  static const inputHeight = 52.0;
  static const chipHeight = 36.0;
  static const bottomNavHeight = 72.0;
  static const appBarHeight = 64.0;
}

━━━ lib/core/theme/app_theme.dart ━━━
Create a ThemeData using Google Fonts:
- headlineFont: Space Grotesk (bold for headings)
- bodyFont: DM Sans (for body text)

ThemeData should set:
- scaffoldBackgroundColor: AppColors.background
- colorScheme: ColorScheme.light with primary=AppColors.yellow,
  onPrimary=AppColors.navy, secondary=AppColors.cobalt
- appBarTheme: backgroundColor=AppColors.background,
  elevation=0, foregroundColor=AppColors.navy,
  titleTextStyle: SpaceGrotesk Bold 20px
- textTheme: map headline/title styles to SpaceGrotesk Bold,
  body/label to DM Sans
- No shadows on AppBar

━━━ lib/shared/widgets/neo_card.dart ━━━
Create a reusable NeoCard widget:
- Required: child Widget
- Optional: color (default white), borderColor (default navy), 
  shadowOffset (default 4,4), padding (default 16), borderRadius (default 12)
- Implementation: Container with 2px solid border in borderColor,
  BoxDecoration with boxShadow using shadowOffset (no blur, solid navy)
  This is the CORE widget used everywhere in the app.

━━━ lib/shared/widgets/neo_button.dart ━━━
Create a NeoButton widget:
- Required: label String, onPressed VoidCallback
- Optional: color (default yellow), textColor (default navy),
  width (default double.infinity), height (default 52), isLoading (default false)
- Style: 2px solid navy border, flat 4px offset shadow,
  borderRadius 8, SpaceGrotesk Bold text
- Loading state: shows CircularProgressIndicator replacing label

━━━ lib/shared/widgets/neo_chip.dart ━━━
Create a NeoChip widget for status badges:
- Required: label String, color Color
- Auto-determines text color (dark on light backgrounds, light on dark)
- 1.5px border same color as chip but darker shade
- Compact height 28px, horizontal padding 12px, radius 6px

Wire app_theme.dart into main.dart.
Confirm the app still builds showing placeholder with correct background color #F5F5F0.
```

---

# ════════════════════════════════════════
# TASK 3 — Navigation & Shell (GoRouter + Bottom Nav)
# ════════════════════════════════════════

## After Task 2 is done:

```
Set up the complete navigation structure for the IdeaLab app using GoRouter.

━━━ ROUTES TO CREATE ━━━

Public routes (no auth required):
  /splash           → SplashScreen
  /onboarding       → OnboardingScreen
  /login            → LoginScreen
  /register         → RegisterScreen

Main shell route (requires auth — wraps bottom nav):
  /home             → HomeScreen       (tab 0)
  /explore          → ExploreScreen    (tab 1)
  /events           → EventsScreen     (tab 2)
  /lab              → LabScreen        (tab 3)
  /profile          → ProfileScreen    (tab 4)

Detail routes (pushed on top, no bottom nav):
  /events/:id            → EventDetailScreen
  /tools/:id             → ToolDetailScreen
  /tools/:id/book        → BookingScreen
  /projects/:id          → ProjectDetailScreen
  /projects/create       → CreateProjectScreen
  /lab/checkin           → QRScanScreen (for check-in)
  /lab/checkout/:toolId  → QRScanScreen (for tool return)
  /admin                 → AdminPanelScreen (role-gated)
  /notifications         → NotificationsScreen

━━━ lib/core/router/app_router.dart ━━━

Use GoRouter with:
- initialLocation: '/splash'
- ShellRoute wrapping the 5 main tabs to keep bottom nav persistent
- A redirect function that:
    * If user not authenticated → go to /login
    * If user authenticated and on /splash or /login → go to /home
    * If user tries /admin and is not Op Head/Faculty → go to /home

━━━ lib/shared/widgets/main_shell.dart ━━━

Create the persistent shell widget with BottomNavigationBar:
- 5 items: Home (house icon), Explore (compass), Events (calendar),
  Lab (flask/beaker), Profile (person)
- Style:
  * Background: AppColors.background
  * Top border: 2px solid AppColors.navy (neobrutalist touch)
  * Selected item: yellow pill background behind icon + label
  * Unselected: navy icon, grey label
  * Height: 72px
  * No elevation shadow (border does the work)

━━━ CREATE PLACEHOLDER SCREENS ━━━

Create these files, each with JUST a Scaffold + centered Text("ScreenName"):
- features/auth/presentation/screens/splash_screen.dart
- features/auth/presentation/screens/onboarding_screen.dart
- features/auth/presentation/screens/login_screen.dart
- features/auth/presentation/screens/register_screen.dart
- features/home/presentation/screens/home_screen.dart
- features/explore/presentation/screens/explore_screen.dart
- features/events/presentation/screens/events_screen.dart
- features/lab/presentation/screens/lab_screen.dart
- features/profile/presentation/screens/profile_screen.dart
- features/admin/presentation/screens/admin_panel_screen.dart

Wire GoRouter in main.dart. App should launch on SplashScreen
and the bottom nav should be visible when navigating to /home.
Confirm all 5 tabs are tappable and show their placeholder text.
```

---

# ════════════════════════════════════════
# TASK 4 — Supabase Backend: Schema & Setup
# ════════════════════════════════════════

## After Task 3 builds and navigation works:

```
Set up Supabase for the IdeaLab app.

━━━ STEP 1: Supabase initialization ━━━

In main.dart, before runApp(), add:
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',       // placeholder string for now
    anonKey: 'YOUR_SUPABASE_ANON_KEY', // placeholder string for now
  )
  
Create lib/core/constants/supabase_keys.dart:
  class SupabaseKeys {
    static const url = String.fromEnvironment('SUPABASE_URL');
    static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  }

━━━ STEP 2: Create Supabase SQL Schema ━━━

Generate a complete SQL file at: supabase/schema.sql

Include these tables with proper types, foreign keys, and RLS comments:

-- 1. users (extends Supabase auth.users)
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  college_roll TEXT UNIQUE,
  role TEXT NOT NULL DEFAULT 'student'
    CHECK (role IN ('student','core_team','op_head','faculty')),
  club_id UUID,
  xp INTEGER DEFAULT 0,
  level INTEGER DEFAULT 1,
  reputation_score INTEGER DEFAULT 100,
  qr_code_data TEXT UNIQUE,
  is_blocked BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. clubs
CREATE TABLE clubs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  color TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. tools
CREATE TABLE tools (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  category TEXT NOT NULL
    CHECK (category IN ('3d_printer','laser','electronics','woodwork','fabrication','other')),
  description TEXT,
  image_url TEXT,
  sop_url TEXT,
  total_qty INTEGER NOT NULL DEFAULT 1,
  available_qty INTEGER NOT NULL DEFAULT 1,
  health_status TEXT DEFAULT 'available'
    CHECK (health_status IN ('available','in_use','maintenance','retired')),
  last_maintained TIMESTAMPTZ,
  qr_code_data TEXT UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. tool_bookings
CREATE TABLE tool_bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tool_id UUID REFERENCES tools(id),
  user_id UUID REFERENCES users(id),
  project_id UUID,
  slot_start TIMESTAMPTZ NOT NULL,
  slot_end TIMESTAMPTZ NOT NULL,
  status TEXT DEFAULT 'pending'
    CHECK (status IN ('pending','approved','active','returned','overdue','cancelled')),
  approved_by UUID REFERENCES users(id),
  approved_at TIMESTAMPTZ,
  checkout_at TIMESTAMPTZ,
  returned_at TIMESTAMPTZ,
  return_reminder_sent BOOLEAN DEFAULT false,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. lab_sessions
CREATE TABLE lab_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  checkin_time TIMESTAMPTZ DEFAULT NOW(),
  checkout_time TIMESTAMPTZ,
  purpose TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. events
CREATE TABLE events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  event_type TEXT DEFAULT 'workshop'
    CHECK (event_type IN ('workshop','hackathon','talk','competition','open_lab','other')),
  club_id UUID REFERENCES clubs(id),
  event_date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ,
  venue TEXT,
  capacity INTEGER,
  rsvp_count INTEGER DEFAULT 0,
  image_url TEXT,
  created_by UUID REFERENCES users(id),
  status TEXT DEFAULT 'upcoming'
    CHECK (status IN ('upcoming','ongoing','completed','cancelled')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. rsvps
CREATE TABLE rsvps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id),
  qr_ticket_data TEXT UNIQUE,
  checked_in_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(event_id, user_id)
);

-- 8. projects
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  club_id UUID REFERENCES clubs(id),
  stage TEXT DEFAULT 'ideation'
    CHECK (stage IN ('ideation','in_progress','completed','showcase')),
  created_by UUID REFERENCES users(id),
  visibility TEXT DEFAULT 'public'
    CHECK (visibility IN ('public','club','private')),
  showcase_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. project_members
CREATE TABLE project_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id),
  role TEXT DEFAULT 'member'
    CHECK (role IN ('admin','lead','member','mentor')),
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(project_id, user_id)
);

-- 10. notifications
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT,
  related_id UUID,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. knowledge_articles
CREATE TABLE knowledge_articles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  tags TEXT[],
  author_id UUID REFERENCES users(id),
  upvotes INTEGER DEFAULT 0,
  is_approved BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

Add these indexes:
CREATE INDEX idx_tool_bookings_user ON tool_bookings(user_id);
CREATE INDEX idx_tool_bookings_status ON tool_bookings(status);
CREATE INDEX idx_lab_sessions_user ON lab_sessions(user_id);
CREATE INDEX idx_events_date ON events(event_date);
CREATE INDEX idx_rsvps_event ON rsvps(event_id);
CREATE INDEX idx_notifications_user ON notifications(user_id, is_read);

━━━ STEP 3: Create Dart models ━━━

Create lib/shared/models/ for each table:
- user_model.dart    (fromJson, toJson, copyWith)
- tool_model.dart
- booking_model.dart
- event_model.dart
- rsvp_model.dart
- project_model.dart
- notification_model.dart

Each model: final fields, const constructor, fromJson factory, toJson method.
Use freezed-style pattern but without the package (manual is fine).

━━━ STEP 4: Supabase client helper ━━━

Create lib/shared/repositories/supabase_client.dart:
  final supabase = Supabase.instance.client;

Confirm app still builds.
```

---

# ════════════════════════════════════════
# TASK 5 — Auth Feature (Login, Register, Session)
# ════════════════════════════════════════

## After Task 4 schema is ready:

```
Implement the full authentication feature for IdeaLab.

━━━ Auth Flow ━━━
Splash (2s) → check session → 
  if logged in → Home
  if not → Onboarding (first time) OR Login (returning)

━━━ lib/features/auth/data/auth_repository.dart ━━━

Create AuthRepository with these methods:
  Future<UserModel?> getCurrentUser()
  Future<UserModel> signUpWithEmail(email, password, name, phone, collegeRoll)
  Future<UserModel> signInWithEmail(email, password)
  Future<void> signOut()
  Stream<AuthState> get authStateStream
  Future<void> updateUserRole(userId, role)

After signUp: insert a row into public.users table with default role='student'
and generate a unique qr_code_data = 'IDEALAB-USER-{userId}'

━━━ lib/features/auth/domain/auth_provider.dart ━━━

Using Riverpod, create:
  authRepositoryProvider (simple Provider)
  currentUserProvider (FutureProvider that returns UserModel?)
  authStateProvider (StreamProvider for session changes)

━━━ SCREENS ━━━

1. features/auth/presentation/screens/splash_screen.dart
   - Show IdeaLab logo (use a Text "IDEALab" in SpaceGrotesk Bold 36px with yellow underline)
   - After 2 seconds: check authStateProvider
   - Navigate to /home if authenticated, /onboarding if first launch (use SharedPreferences 
     key 'has_seen_onboarding'), /login otherwise

2. features/auth/presentation/screens/onboarding_screen.dart
   - 3 pages with PageView (no complex animations)
   - Page 1: icon + "Book lab tools instantly"
   - Page 2: icon + "Join projects, build things"  
   - Page 3: icon + "Check in, earn XP, level up"
   - Bottom: dot indicators + "Get Started" NeoButton
   - On "Get Started": save SharedPrefs key, navigate to /login

3. features/auth/presentation/screens/login_screen.dart
   - NeoCard wrapping the form (not full screen form)
   - Email TextField (neobrutalist: 2px border, no fill, DM Sans)
   - Password TextField with show/hide toggle
   - "Login" NeoButton (yellow)
   - "Create Account" text button below
   - Error snackbar using ScaffoldMessenger with neobrutalist style
     (red background, white text, navy border)
   - Loading state on NeoButton while logging in

4. features/auth/presentation/screens/register_screen.dart
   - Fields: Full Name, College Roll No, Email, Phone, Password
   - Same neobrutalist field style
   - "Register" NeoButton
   - On success: navigate to /home
   - Validate: email format, phone 10 digits, password min 8 chars

━━━ SHARED WIDGET ━━━

lib/shared/widgets/neo_text_field.dart:
  - label String, controller, optional validator, obscureText bool
  - Style: 2px navy border, background white, DM Sans 16px
  - Focus state: border becomes yellow (2px)
  - Error state: border becomes red, red hint text below
  - No filled background — just the border

Test: full login → home flow works, register creates user in Supabase.
```

---

# ════════════════════════════════════════
# TASK 6 — Home Screen (Real UI)
# ════════════════════════════════════════

## After auth works end-to-end:

```
Build the real Home Screen matching the Gemini design.

Reference design: 
- Warm off-white background
- Greeting + logo top row
- Lab status card
- 2x2 quick action grid (Check In = yellow, Book a Tool = blue, Events, My Projects)
- Upcoming events card
- Active projects horizontal scroll

━━━ lib/features/home/presentation/screens/home_screen.dart ━━━

Layout (SingleChildScrollView + Column):

1. TOP APP BAR (not Material AppBar, custom Row):
   - Left: IdeaLab logo text "IDEALab" in SpaceGrotesk Bold + subtitle with user name
   - Right: notification bell IconButton with red dot badge if unread notifications

2. LAB STATUS CARD (NeoCard):
   - "Lab is OPEN" in bold green text OR "Lab is CLOSED" in red
   - Live visitor count: "X people inside right now"
   - LIVE badge (green pill, pulsing animation — simple opacity animation)
   - Pull lab status from lab_sessions table: count active sessions
     (sessions where checkout_time IS NULL)

3. QUICK ACTION GRID (2x2 using GridView, fixed height):
   Card 1 — CHECK IN (yellow bg, location pin icon, navy text)
   Card 2 — BOOK A TOOL (cobalt blue bg, wrench icon, white text)
   Card 3 — EVENTS (white bg, calendar icon, navy text)
   Card 4 — MY PROJECTS (white bg, folder icon, navy text)
   
   Each card: NeoCard, onTap navigates to correct route,
   icon 32px, label 14px SpaceGrotesk Bold at bottom of card
   Cards are equal height (140px), neobrutalist border + shadow

4. UPCOMING EVENT CARD (NeoCard):
   - Section header: "Upcoming Event" in DM Sans 13px grey
   - Event title in SpaceGrotesk Bold 18px
   - Date pill (yellow chip) + venue text
   - "RSVP" NeoButton (compact height 40px) on the right
   - Load from events table: next event where event_date > now()
   - Show skeleton shimmer if loading (use simple Container with grey background)

5. ACTIVE PROJECTS (horizontal scroll):
   - Section header: "Active Projects" + arrow buttons
   - Each project card (NeoCard, width 200px):
     * Project title bold
     * Member avatar stack (max 4 avatars, circle +N for overflow)
     * Stage chip
     * Location text (just "Kerala, India" for now)
   - Load from projects + project_members tables

Use Riverpod FutureProviders for each data section.
Each section handles loading + error states independently.
Confirm real data appears from Supabase.
```

---

# ════════════════════════════════════════
# TASK 7 — Lab Check-In Feature (Core Feature)
# ════════════════════════════════════════

## After Home screen works with real data:

```
Build the full lab check-in / check-out feature with QR scanning.

━━━ FLOW ━━━
User taps "Check In" on home → QR Scan screen opens →
  Camera scans QR → validates it's a valid user QR →
  Creates lab_session row → shows success → home shows user as "inside"
User taps "Check Out" (visible when they're inside) →
  Confirms → updates checkout_time → session closed

━━━ lib/features/lab/data/lab_repository.dart ━━━

Methods:
  Future<LabSession?> getActiveSession(userId)
  Future<LabSession> checkIn(userId, purpose)
  Future<void> checkOut(sessionId)
  Stream<int> getLiveVisitorCount()  ← realtime stream using Supabase realtime
  Future<List<LabSession>> getMyHistory(userId, {limit = 20})

━━━ lib/features/lab/domain/lab_providers.dart ━━━

  labRepositoryProvider
  activeSessionProvider (FutureProvider for current user's open session)
  liveVisitorCountProvider (StreamProvider — realtime)

━━━ lib/features/lab/presentation/screens/lab_screen.dart ━━━

This is the main LAB tab. Show:

If user has NO active session:
  - Big "CHECK IN" NeoButton (yellow, full width)
  - Under it: "Who's here now" section showing live count + avatar bubbles of current users

If user HAS an active session:
  - Green status card: "You're checked in" + session timer (shows HH:MM:SS elapsed)
  - "Check Out" NeoButton (red outline style)
  - Under: "Book a Tool" section (list of available tools with quick Book button)
  - "Report an Issue" link (opens a simple form sheet)

Bottom section (always visible):
  - "My Recent Sessions" list (date, time in, time out, duration)

━━━ lib/features/lab/presentation/screens/qr_scan_screen.dart ━━━

Use mobile_scanner package:
  - Full screen camera view
  - Overlay: dark semi-transparent corners, white square frame in center
  - Top: "Scan Lab QR Code" label
  - On detect: parse QR data
    * If starts with "IDEALAB-USER-": it's a user card → do check-in for THAT user
      (used by coordinators scanning visitor cards)
    * If the CURRENT user is scanning THEIR OWN check-in: use their userId directly
      (tapping Check In button → auto check-in without needing to scan their own QR)
  - Show result overlay: green tick + "Checked In!" or red X + error message
  - Auto-close after 2 seconds on success

━━━ lib/shared/widgets/user_qr_card.dart ━━━
Widget that shows the user's QR code:
  - Uses qr_flutter to render QR from user's qr_code_data string
  - Below QR: user name + college roll
  - Wrapped in a NeoCard
  - Used in Profile tab

For the check-in button on Home screen:
  Simply call labRepository.checkIn(currentUser.id, 'General visit')
  without opening QR scanner (self check-in is automatic).
  
  The QR scanner is for coordinators scanning visitor cards.

Confirm: check-in creates a row in lab_sessions,
home screen live count updates in real-time,
check-out sets checkout_time.
```

---

# ════════════════════════════════════════
# TASK 8 — Tool Catalog & Booking
# ════════════════════════════════════════

## After check-in works:

```
Build the Tool Catalog and Booking system. This is the BOOK A TOOL screen
shown in the Gemini design image.

━━━ lib/features/lab/data/tool_repository.dart ━━━

Methods:
  Future<List<ToolModel>> getTools({String? category})
  Future<ToolModel> getToolById(id)
  Future<List<ToolBooking>> getMyBookings(userId)
  Future<ToolBooking> createBooking(toolId, userId, slotStart, slotEnd, projectId?)
  Future<void> approveBooking(bookingId, approvedBy)   ← op head only
  Future<void> checkoutTool(bookingId)                  ← QR scan
  Future<void> returnTool(bookingId)                    ← QR scan
  Future<List<ToolBooking>> getOverdueBookings()        ← admin

━━━ lib/features/lab/presentation/screens/tool_catalog_screen.dart ━━━

Match the Gemini design exactly:

1. Header: "Book a Tool" in SpaceGrotesk Bold 28px, back arrow
2. Search bar (NeoTextField, full width, search icon left, 2px border)
3. Filter chips (horizontal scroll, no scroll indicator):
   "All", "3D Printer", "Laser", "Electronics", "Woodwork", "Fabrication"
   Selected chip: yellow bg + navy border
   Unselected chip: white bg + grey border
4. Tool Grid (2 columns, GridView.builder, NeverScrollableScrollPhysics):
   Each TOOL CARD (NeoCard):
   - Tool image (CachedNetworkImage, height 120px, border-radius 8, border)
   - Tool name: SpaceGrotesk Bold 15px
   - Availability chip: NeoChip("Available", green) or NeoChip("In Use", red)
   - "Book" button: compact NeoButton, height 36px
   
   Selected card state: yellow 3px border + stronger shadow (match Gemini design)
   
5. Floating "Confirm Booking" NeoButton at bottom (visible when card selected)

━━━ lib/features/lab/presentation/screens/booking_screen.dart ━━━

After tapping "Book" on a tool:
  Show a bottom sheet (showModalBottomSheet) with:
  1. Tool name + image thumbnail
  2. Date picker (simple: show next 7 days as horizontal date chips)
  3. Time slot picker: show available slots as chips (9am, 10am, 11am... etc)
     Grey out already-booked slots (check tool_bookings table for conflicts)
  4. Duration selector: 1hr, 2hr, 3hr, Full Day
  5. Optional: link to project (dropdown of user's active projects)
  6. "Request Booking" NeoButton
  
  On submit: create booking with status='pending', 
  push notification to Op Head,
  show "Booking requested! You'll be notified when approved."

━━━ Return via QR ━━━
When user opens QR scanner with a tool QR code (IDEALAB-TOOL-{toolId}):
  - Find their active booking for this tool
  - If checking out: set status='active', checkout_at=now()
  - If returning: set status='returned', returned_at=now(), 
    update tool available_qty+1, award XP to user (+10 for on-time return)

Confirm: full flow — browse catalog → select → choose slot → request → 
admin approves → user checks out tool → returns tool.
```

---

# ════════════════════════════════════════
# TASK 9 — Events & RSVP
# ════════════════════════════════════════

```
Build the Events tab and RSVP system.

━━━ lib/features/events/ ━━━

event_repository.dart:
  Future<List<EventModel>> getUpcomingEvents({String? clubId, String? type})
  Future<List<EventModel>> getPastEvents()
  Future<EventModel> getEventById(id)
  Future<RsvpModel> rsvpToEvent(eventId, userId)
  Future<void> cancelRsvp(rsvpId)
  Future<void> checkInToEvent(rsvpId)      ← QR scan at event door
  Future<List<RsvpModel>> getMyRsvps(userId)
  Future<void> createEvent(EventModel)     ← core team / event head only

events_screen.dart:
  - Tab pills: Upcoming / My RSVPs / Past  
  - Upcoming: list of EventCard widgets
  - My RSVPs: list with QR ticket button on each
  - Past: simple list with photo thumbnails

EventCard widget (NeoCard):
  - Event image (full width top, height 160px)
  - Gradient overlay at bottom of image
  - Event title bold on image
  - Row below image: date chip + type chip + venue text
  - "RSVP Now" NeoButton OR "Registered ✓" if already RSVPed
  - Seats remaining: "X spots left" in orange if < 10

event_detail_screen.dart:
  - Hero animation on event image
  - Full description
  - Organiser row (club name + organiser avatar)
  - Date/time/venue info row
  - Map placeholder (just a grey box with venue text for now)
  - RSVP button (full width, sticks to bottom)
  - After RSVP: show QR ticket in a modal

QR Ticket modal:
  - Show qr_flutter QR code (data = "IDEALAB-RSVP-{rsvpId}")
  - Event name + date below
  - "Save to Photos" button (use image rendering to save QR as image)
  - Neobrutalist ticket design: dashed left border, perforated line divider

Coordinator check-in mode (accessible from admin panel):
  - Open QR scanner
  - Scan attendee's ticket QR
  - Validate rsvp exists and belongs to this event
  - Mark checked_in_at = now()
  - Show green success with attendee name
```

---

# ════════════════════════════════════════
# TASK 10 — Projects & Teams
# ════════════════════════════════════════

```
Build the Projects feature.

━━━ projects tab & screens ━━━

projects_screen.dart (tab):
  - "My Projects" section: projects where user is a member
  - "All Projects" section: public projects, filterable by stage/club
  - "+" FAB to create new project

create_project_screen.dart:
  - Fields: Title, Description, Club (dropdown), Visibility (public/club/private)
  - Stage auto-set to 'ideation'
  - Creator auto-added as project admin
  - On create: navigate to project_detail_screen

project_detail_screen.dart:
  - Header: project title + stage chip (colour coded)
  - Team row: member avatars + roles + "Invite" button
    Invite = show user's project QR or share link
  - TABS inside this screen (TabBar, 3 tabs):
    * Overview: description + requested tools + resources
    * Team: list of members with their roles, add/remove (admin only)
    * Updates: chronological feed of updates posted by team
  - FAB: "Post Update" → simple text + optional image form

Invite flow:
  - Project admin taps "Invite"
  - Show project QR code (data = "IDEALAB-PROJECT-{projectId}")
  - Anyone who scans this QR → sees project page → "Join Project" button
  - Admin gets notification "X wants to join your project" → approve/reject

Tool request from within project:
  - In project Overview tab: "Request Tool" button
  - Opens tool catalog in selection mode
  - Selected tool gets linked to project_id in booking

Gamification hooks (add XP awards):
  +5 XP: create project
  +10 XP: post a project update
  +20 XP: complete a project (stage → completed)
  +5 XP: join a project
```

---

# ════════════════════════════════════════
# TASK 11 — Profile, QR Card & Gamification
# ════════════════════════════════════════

```
Build the Profile tab and gamification system.

━━━ profile_screen.dart ━━━

Top section:
  - Avatar (initials-based circle, colour generated from name hash, 80px, thick border)
  - Name SpaceGrotesk Bold 22px
  - College roll + role chip below
  - "My QR Card" button → shows user's check-in QR in a modal

XP & Level section (NeoCard):
  - Level badge: big number in yellow circle
  - Level name: "Builder" (see level system below)
  - Progress bar: custom neobrutalist bar (thick, navy border, yellow fill)
  - "XXX XP / XXX XP to next level" label

Badge shelf (horizontal scroll):
  - Each badge: hexagon shape (or chunky rounded square), icon + name
  - Earned badges: yellow fill + navy border
  - Locked badges: grey fill, lock icon overlay
  - Tap badge → bottom sheet with badge description and how to earn

Stats grid (2x2, NeoCard each):
  - Lab Visits | Tools Used | Events Attended | Projects Built
  - Pull from respective tables (count queries)

My Bookings tab (inside profile or separate route):
  - Upcoming bookings with status chips
  - History: returned, cancelled

LEVEL SYSTEM (add to user logic):
  0–100 XP:    Level 1 — Newcomer
  101–300 XP:  Level 2 — Tinkerer
  301–600 XP:  Level 3 — Maker
  601–1000 XP: Level 4 — Builder
  1001–2000 XP: Level 5 — Innovator
  2000+ XP:    Level 6 — IdeaLab Legend

BADGE DEFINITIONS (store as constants, unlock triggers):
  "First Step"      → first lab check-in
  "Tool Time"       → first tool booking
  "Team Player"     → joined a project
  "Builder"         → completed a project
  "Organiser"       → created an event (core team)
  "Never Late"      → 10 on-time tool returns, zero overdues
  "Top Contributor" → top 3 on monthly leaderboard
  "Knowledge Maker" → published approved knowledge article
  "Event Goer"      → attended 5 events
  "IdeaLab OG"      → registered in the first month of app launch

Create a XP service:
  lib/features/profile/domain/xp_service.dart
  Method: Future<void> awardXP(userId, amount, reason)
  → updates users.xp, recalculates level, checks badge unlocks,
    sends in-app notification "You earned X XP for [reason]!"

Settings section (bottom of profile):
  - Notification preferences (toggles for each type)
  - Change password
  - Sign out button (red outline NeoButton)
```

---

# ════════════════════════════════════════
# TASK 12 — Admin Panel
# ════════════════════════════════════════

```
Build the Admin Panel (accessible only to op_head and faculty roles).

━━━ admin_panel_screen.dart ━━━

Navigation: from Profile tab, show "Admin Panel →" button only if role is op_head or faculty.
GoRouter redirect ensures /admin returns unauthorized users to /home.

Admin home: 4 dashboard metric cards + quick action sections:
  Cards: Pending Approvals | Active Sessions | Low Stock Items | Today's Events

Sections (each navigates to a dedicated screen):

1. INVENTORY MANAGEMENT (admin_inventory_screen.dart):
   - List all tools with health_status chips
   - Search + filter by category
   - Each tool row: image thumbnail, name, qty (available/total), status, Edit button
   - FAB "Add Tool" → form: name, category, description, image upload, total_qty, sop_url
   - Edit tool: same form pre-filled
   - Mark tool Under Maintenance: changes health_status, reduces available_qty
   - LOW STOCK: if available_qty = 0, show red badge on tool

2. BOOKING APPROVALS (admin_approvals_screen.dart):
   - List of pending bookings (status='pending')
   - Each row: user name, tool name, requested slot, date
   - Approve button (green) / Reject button (red) with optional rejection reason
   - OVERDUE section below: all bookings with status='overdue'
     Each overdue row shows: user name, tool, days overdue, "Send Reminder" + "Override Return" buttons

3. MEMBER MANAGEMENT (admin_members_screen.dart):
   - List all users with role chips
   - Search by name or roll number
   - Tap user → see their profile summary + change role dropdown
   - Only faculty can set role to 'faculty'
   - Toggle is_blocked (prevents bookings, shown with red badge)

4. EVENT MANAGEMENT: link to event creation (already in events feature)

5. ANALYTICS (admin_analytics_screen.dart):
   - Daily check-ins (last 7 days bar chart — use simple custom painter, no chart library)
   - Peak hours heatmap (simple grid showing visit count per hour)
   - Most used tools list
   - XP leaderboard (top 10 users)
   - Export as CSV button (generates CSV string from data, triggers file download/share)
```

---

# ════════════════════════════════════════
# TASK 13 — Push Notifications & Polish
# ════════════════════════════════════════

```
Wire up push notifications and final polish.

━━━ Push Notifications (Firebase FCM) ━━━

lib/core/services/notification_service.dart:

Setup:
  - Request permission on first launch (iOS asks, Android auto)
  - Get FCM token → save to users table (add fcm_token column to users)
  - Handle foreground messages: show flutter_local_notifications banner
  - Handle background tap: navigate to relevant screen using GoRouter

Notification types to send (triggered from Supabase Edge Functions or client-side):
  BOOKING_APPROVED  → "Your {tool} booking is confirmed for {date}"
  BOOKING_REMINDER  → "Return {tool} by {time} today"
  BOOKING_OVERDUE   → "Your {tool} booking is overdue. Please return immediately."
  EVENT_REMINDER    → "Event '{title}' starts in 1 hour"
  PROJECT_INVITE    → "{name} wants to join your project"
  XP_EARNED         → "You earned {amount} XP for {reason}!"
  NEW_EVENT         → "New event: {title} — RSVP now"

Supabase Edge Function (write SQL trigger + edge function):
  - On tool_booking.status change to 'overdue': 
    send FCM to user (use user's fcm_token)
  - Scheduled function: check bookings ending in 1hr → send reminder

━━━ FINAL POLISH ━━━

1. Loading states: all FutureProvider screens show a shimmer skeleton
   (simple grey containers animated with opacity, NOT a package)

2. Error states: all screens show a NeoCard with error icon + retry button

3. Empty states: empty lists show a relevant illustration placeholder 
   (just an icon + text, no external illustration assets needed)

4. Haptic feedback: add HapticFeedback.lightImpact() on all NeoButton taps

5. Pull to refresh: add RefreshIndicator to all main list screens

6. Transition animations: GoRouter page transitions
   - Push/detail screens: slide from right (standard)
   - Modal screens: slide from bottom
   - Tab switches: no animation (instant, like native apps)

7. Network handling: catch Supabase exceptions and map to user-friendly messages
   - AuthException → "Invalid email or password"
   - PostgrestException → "Something went wrong, please try again"
   - Network error → "No internet connection"

8. App icon: use the IdeaLab logo (place in assets/icons/app_icon.png,
   configure flutter_launcher_icons package)

Confirm: complete end-to-end flow works on both Android and iOS simulator.
```

---

# ════════════════════════════════════════
# QUICK REFERENCE — What Each Task Unlocks
# ════════════════════════════════════════

Task 1  → Project scaffold, folder structure, builds
Task 2  → Design system: colors, typography, NeoCard, NeoButton
Task 3  → Navigation: all routes, 5-tab shell, placeholder screens
Task 4  → Supabase schema: all 11 tables, Dart models
Task 5  → Auth: login, register, session, splash, onboarding
Task 6  → Home screen: real data, live status, quick actions
Task 7  → Lab check-in/out: QR scan, real-time visitor count
Task 8  → Tool catalog + booking flow (core operational feature)
Task 9  → Events + RSVP + QR tickets
Task 10 → Projects + teams + invites
Task 11 → Profile + gamification (XP, badges, levels)
Task 12 → Admin panel (inventory, approvals, analytics)
Task 13 → Push notifications + final polish

TOTAL ESTIMATED TIME (with AI IDE): 3–5 weeks part-time
MVP (Tasks 1–7): 1–2 weeks — enough to show and get real users

---
_IdeaLab App — AI IDE Task Guide v1.0 | MEC_
