import 'package:go_router/go_router.dart';

import '../../shared/repositories/supabase_client.dart';
import '../utils/app_logger.dart';
import '../../features/admin/presentation/screens/admin_dashboard.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/profile_setup_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/explore/presentation/screens/event_details_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/notifications/presentation/screens/notification_inbox_screen.dart';
import '../../features/projects/presentation/screens/create_project_screen.dart';
import '../../features/projects/presentation/screens/project_details_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/lab/presentation/screens/lab_screen.dart';
import '../../features/lab/presentation/screens/qr_scan_screen.dart';
import '../../features/lab/presentation/screens/tools_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../shared/widgets/main_shell.dart';

/// Central route configuration for the Grow~ app.
///
/// Public routes (splash, onboarding, login, register) sit outside the shell.
/// The 5 main tabs live inside a [StatefulShellRoute] so the bottom nav persists.
/// Detail routes push on top without bottom nav.
final goRouter = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  redirect: (context, state) {
    final session = supabase.auth.currentSession;
    final path = state.uri.path;

    final publicRoutes = {'/splash', '/onboarding', '/login', '/register'};
    final isPublic = publicRoutes.contains(path);

    AppLogger.info(
      LogCategory.router,
      'REDIRECT_CHECK | '
      'path=$path authed=${session != null}',
    );

    // Unauthenticated trying to access protected route
    if (session == null && !isPublic) {
      AppLogger.warn(LogCategory.router, 'UNAUTH_ACCESS_BLOCKED | path=$path');
      return '/login';
    }

    // Authenticated user trying to access auth routes (onboarding/login) → send home
    // We EXCLUDE /splash here so SplashScreen can do its async database check.
    if (session != null &&
        (path == '/onboarding' || path == '/login' || path == '/register')) {
      AppLogger.info(
        LogCategory.router,
        'AUTH_USER_REDIRECTED_HOME | from=$path',
      );
      return '/home';
    }

    // Authenticated but profile not complete → profile setup
    // (Only redirect if NOT already going to profile-setup)
    if (session != null && path != '/profile-setup') {
      // Check profile_completed via a synchronous cache check only
      // Full async check happens in splash_screen.dart
    }

    return null;
  },
  routes: [
    // ── Public routes (no bottom nav) ────────────────────────
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),

    // ── Main shell (5 tabs with persistent bottom nav) ───────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0 — Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Tab 1 — Explore
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/explore',
              builder: (context, state) => const ExploreScreen(),
            ),
          ],
        ),
        // Tab 2 — Events
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/events',
              builder: (context, state) => const EventsScreen(),
            ),
          ],
        ),
        // Tab 3 — Lab
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/lab',
              builder: (context, state) => const LabScreen(),
            ),
          ],
        ),
        // Tab 4 — Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // ── Detail routes (pushed on top, no bottom nav) ─────────
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboard(),
    ),
    GoRoute(
      path: '/lab/scan',
      builder: (context, state) => const QrScanScreen(),
    ),
    GoRoute(path: '/tools', builder: (context, state) => const ToolsScreen()),
    GoRoute(
      path: '/events/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return EventDetailsScreen(eventId: id);
      },
    ),
    GoRoute(
      path: '/projects/create',
      builder: (context, state) => const CreateProjectScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationInboxScreen(),
    ),
    GoRoute(
      path: '/projects/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProjectDetailsScreen(projectId: id);
      },
    ),
    // More detail routes added in later tasks:
    // /tools/:id, /tools/:id/book,
    // /notifications
  ],
);
