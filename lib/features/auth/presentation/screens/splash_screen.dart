import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/repositories/supabase_client.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
        final data = await supabase
            .from('users')
            .select('profile_completed')
            .eq('id', session.user.id)
            .maybeSingle();

        if (data != null && data['profile_completed'] == true) {
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
