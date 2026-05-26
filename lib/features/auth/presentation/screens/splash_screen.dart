import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/rc5_design_tokens.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/repositories/supabase_client.dart';
import '../../../../shared/widgets/rc5/rc5_grow_logo.dart';
import '../../data/auth_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
    _redirect();
  }

  Future<void> _redirect() async {
    // Show splash for at least 2 seconds for branding
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final session = supabase.auth.currentSession;
    AppLogger.info(
      LogCategory.auth,
      'SPLASH_SESSION_CHECK | sessionExists=${session != null} | userId=${session?.user.id} | email=${session?.user.email}',
    );

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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RC5DesignTokens.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: _slideUp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const RC5GrowLogo(size: 64),
                const SizedBox(height: 16),
                Text(
                  'Grow~',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: RC5DesignTokens.ink,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 4,
                  width: 60,
                  decoration: BoxDecoration(
                    color: RC5DesignTokens.surfaceAlt,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: RC5DesignTokens.ink, width: 1.5),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'IDEA Lab Platform',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: RC5DesignTokens.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
