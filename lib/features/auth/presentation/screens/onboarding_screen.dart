import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/neo_button.dart';
import '../../../../shared/widgets/neo_card.dart';
import '../../../../shared/repositories/supabase_client.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Book Lab Tools Instantly',
      'subtitle':
          'No more paper registers. Reserve 3D printers, laser cutters, and more right from your phone.',
      'icon': Icons.precision_manufacturing_rounded,
      'color': AppColors.yellow,
    },
    {
      'title': 'Join Projects, Build Things',
      'subtitle':
          'Find teammates, join clubs, and showcase your maker projects to the entire college.',
      'icon': Icons.rocket_launch_rounded,
      'color': AppColors.cobalt,
      'iconColor': Colors.white,
    },
    {
      'title': 'Check In, Level Up',
      'subtitle':
          'Scan the lab QR to check in. Earn XP for every hour spent building and unlock new tools.',
      'icon': Icons.qr_code_scanner_rounded,
      'color': AppColors.green,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  'Skip',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        NeoCard(
                          color: page['color'],
                          padding: const EdgeInsets.all(AppSizes.xl),
                          child: Icon(
                            page['icon'],
                            size: 80,
                            color: page['iconColor'] ?? AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: AppSizes.xxl),
                        Text(
                          page['title'],
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.md),
                        Text(
                          page['subtitle'],
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.navy
                              : AppColors.navy.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  NeoButton(
                    label: _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    width: 140,
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        final session = supabase.auth.currentSession;
                        if (session != null) {
                          context.go('/profile-setup');
                        } else {
                          context.go('/login');
                        }
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
