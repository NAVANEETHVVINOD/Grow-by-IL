import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/repositories/supabase_client.dart';
import '../../data/auth_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // Show splash for at least 2 seconds for branding
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final session = supabase.auth.currentSession;
    if (session != null) {
      try {
        // Calling getCurrentUser() triggers the ensureUserProfileExists() sync
        final user = await ref.read(authRepositoryProvider).getCurrentUser();

        // Banned user guard — check is_active before allowing entry
        if (user != null && user.isActive == false) {
          AppLogger.warn(
            LogCategory.auth,
            'SUSPENDED_USER_DETECTED | userId=${user.id}',
          );
          await supabase.auth.signOut();
          if (mounted) {
            context.go('/login');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  user.banReason ?? 'Your account has been suspended.',
                ),
                backgroundColor: AppColors.red,
              ),
            );
          }
          return;
        }

        if (user != null) {
          AppLogger.info(
            LogCategory.auth,
            'PROFILE_CHECK | completed=${user.profileCompleted} | role=${user.role}',
          );
        }

        if (user?.profileCompleted == true) {
          if (mounted) context.go('/home');
        } else {
          if (mounted) context.go('/profile-setup');
        }
      } catch (e) {
        if (mounted) context.go('/profile-setup');
      }
    } else {
      if (mounted) context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Grow~',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 64,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
                letterSpacing: -2,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 6,
              width: 80,
              decoration: BoxDecoration(
                color: AppColors.yellow,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
