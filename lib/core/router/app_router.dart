import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/admin/presentation/screens/admin_dashboard.dart';
import '../../features/akathalam/presentation/screens/akathalam_screen.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/rc5_onboarding_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/unauthorized_screen.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/explore/presentation/screens/event_details_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/home/presentation/screens/rc5_home_screen.dart';
import '../../features/home/presentation/screens/mentorship_screen.dart';
import '../../features/home/presentation/screens/knowledge_base_screen.dart';
import '../../features/home/presentation/screens/donation_screen.dart';
import '../../features/lab/presentation/screens/lab_screen.dart';
import '../../features/lab/presentation/screens/qr_scan_screen.dart';
import '../../features/lab/presentation/screens/tools_screen.dart';
import '../../features/notifications/presentation/screens/notification_inbox_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/rc5_edit_profile_hub.dart';
import '../../features/profile/presentation/screens/rc5_profile_screen.dart';
import '../../features/profile/presentation/screens/edit_subpages/rc5_edit_basic_profile_screen.dart';
import '../../features/profile/presentation/screens/edit_subpages/rc5_edit_education_screen.dart';
import '../../features/profile/presentation/screens/edit_subpages/rc5_edit_interests_screen.dart';
import '../../features/profile/presentation/screens/edit_subpages/rc5_edit_skills_screen.dart';
import '../../features/profile/presentation/screens/edit_subpages/rc5_edit_social_links_screen.dart';
import '../../features/profile/presentation/screens/edit_subpages/rc5_edit_visibility_screen.dart';
import '../../features/projects/presentation/screens/create_project_screen.dart';
import '../../features/projects/presentation/screens/project_details_screen.dart';
import '../../features/projects/presentation/screens/project_list_screen.dart';
import '../../shared/repositories/supabase_client.dart';
import '../../shared/widgets/main_shell.dart';
import '../constants/feature_flags.dart';
import '../constants/app_roles.dart';
import '../utils/app_logger.dart';

/// Adapter class to refresh GoRouter when a Stream triggers a new event.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Central route configuration for the Grow~ app.
final routerProvider = Provider<GoRouter>((ref) {
  // Only trigger router refresh on major auth state changes, NOT token refreshes.
  final filteredAuthStream = supabase.auth.onAuthStateChange.where((event) {
    return event.event == AuthChangeEvent.signedIn ||
        event.event == AuthChangeEvent.signedOut ||
        event.event == AuthChangeEvent.initialSession;
  });

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    refreshListenable: GoRouterRefreshStream(filteredAuthStream),
    redirect: (context, state) {
      final session = supabase.auth.currentSession;
      final path = state.uri.path;

      final publicRoutes = {
        '/splash',
        '/onboarding',
        '/login',
        '/register',
      };
      final isPublic = publicRoutes.contains(path);

      AppLogger.info(
        LogCategory.router,
        'REDIRECT_CHECK | path=$path authed=${session != null}',
      );

      if (session == null && !isPublic) {
        AppLogger.warn(
          LogCategory.router,
          'UNAUTH_ACCESS_BLOCKED | path=$path',
        );
        return '/login';
      }

      if (session != null &&
          (path == '/onboarding' || path == '/login' || path == '/register')) {
        AppLogger.info(
          LogCategory.router,
          'AUTH_USER_REDIRECTED_HOME | from=$path',
        );
        return '/home';
      }

      // ---------------------------------------------------------
      // RC5 STRICT ONBOARDING ENFORCEMENT
      // ---------------------------------------------------------
      if (session != null &&
          !isPublic &&
          path != '/splash' &&
          path != '/profile-setup') {
        final userProfileAsync = ref.read(currentUserProvider);
        final user = userProfileAsync.valueOrNull;

        if (user != null && !user.profileCompleted) {
          AppLogger.warn(
            LogCategory.router,
            'INCOMPLETE_PROFILE_REDIRECT | path=$path',
          );
          return '/profile-setup';
        }
      }

      if (session != null && path == '/profile-setup') {
        final userProfileAsync = ref.read(currentUserProvider);
        final user = userProfileAsync.valueOrNull;

        if (user != null && user.profileCompleted) {
          return '/home';
        }
      }

      if (path.startsWith('/admin')) {
        if (session == null) return '/login';

        final userProfileAsync = ref.read(currentUserProvider);
        final user = userProfileAsync.valueOrNull;
        if (user == null) {
          if (userProfileAsync.isLoading) return null;
          return '/home';
        }

        if (!AppRole.isAdminRole(user.role)) {
          AppLogger.warn(
            LogCategory.router,
            'UNAUTHORIZED_ADMIN_ACCESS | role=${user.role} user=${session.user.email}',
          );
          return '/unauthorized';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
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
        builder: (context, state) => const RC5OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const RC5HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/akathalam',
                builder: (context, state) => const AkathalamScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => FeatureFlags.enableNewProfile
                    ? const RC5ProfileScreen()
                    : const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const RC5EditProfileHub(),
      ),
      GoRoute(
        path: '/profile/edit/basic',
        builder: (context, state) => const RC5EditBasicProfileScreen(),
      ),
      GoRoute(
        path: '/profile/edit/interests',
        builder: (context, state) => const RC5EditInterestsScreen(),
      ),
      GoRoute(
        path: '/profile/edit/skills',
        builder: (context, state) => const RC5EditSkillsScreen(),
      ),
      GoRoute(
        path: '/profile/edit/education',
        builder: (context, state) => const RC5EditEducationScreen(),
      ),
      GoRoute(
        path: '/profile/edit/social-links',
        builder: (context, state) => const RC5EditSocialLinksScreen(),
      ),
      GoRoute(
        path: '/profile/edit/visibility',
        builder: (context, state) => const RC5EditVisibilityScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/unauthorized',
        builder: (context, state) => const UnauthorizedScreen(),
      ),
      GoRoute(
        path: '/lab/scan',
        builder: (context, state) => const QrScanScreen(),
      ),
      GoRoute(
        path: '/mentorship',
        builder: (context, state) => const MentorshipScreen(),
      ),
      GoRoute(
        path: '/knowledge',
        builder: (context, state) => const KnowledgeBaseScreen(),
      ),
      GoRoute(
        path: '/donate',
        builder: (context, state) => const DonationScreen(),
      ),
      GoRoute(path: '/lab', builder: (context, state) => const LabScreen()),
      GoRoute(path: '/tools', builder: (context, state) => const ToolsScreen()),
      GoRoute(
        path: '/events',
        builder: (context, state) => const EventsScreen(),
      ),
      GoRoute(
        path: '/explore',
        builder: (context, state) => const ExploreScreen(),
      ),
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
        path: '/projects',
        builder: (context, state) => const ProjectListScreen(),
      ),
      GoRoute(
        path: '/projects/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProjectDetailsScreen(projectId: id);
        },
      ),
    ],
  );
});
