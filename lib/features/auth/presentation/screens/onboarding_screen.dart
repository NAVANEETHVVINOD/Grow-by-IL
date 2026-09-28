import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      'title': 'Make ideas real.',
      'subtitle':
          'IDEA Lab at MEC is a place to explore, prototype, learn technical craft, and work across disciplines.',
      'icon': Icons.precision_manufacturing_rounded,
      'color': AppColors.yellow,
    },
    {
      'title': 'Build your maker story.',
      'subtitle':
          'Add projects, experience, education, skills, interests, and volunteering to your profile when you are ready.',
      'icon': Icons.auto_awesome_mosaic_outlined,
      'color': AppColors.cobalt,
      'iconColor': Colors.white,
    },
    {
      'title': 'Find your next build.',
      'subtitle':
          'Explore lab activity, projects, resources, and events. Lab entry and safety approvals stay with the IDEA Lab team.',
      'icon': Icons.explore_outlined,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 760;
            return Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      'Skip',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                      final iconSize = compact ? 64.0 : 80.0;
                      return Padding(
                        padding: EdgeInsets.all(
                          compact ? AppSizes.md : AppSizes.lg,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            NeoCard(
                              color: page['color'],
                              padding: EdgeInsets.all(
                                compact ? AppSizes.lg : AppSizes.xl,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    right: -8,
                                    top: -24,
                                    child: Text(
                                      '///',
                                      style: Theme.of(context)
                                          .textTheme
                                          .displayLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.navy
                                                .withValues(alpha: .12),
                                          ),
                                    ),
                                  ),
                                  Icon(
                                    page['icon'],
                                    size: iconSize,
                                    color: page['iconColor'] ?? AppColors.navy,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: compact ? AppSizes.lg : AppSizes.xxl,
                            ),
                            Text(
                              page['title'],
                              style: (compact
                                      ? Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                      : Theme.of(context)
                                          .textTheme
                                          .headlineMedium)
                                  ?.copyWith(fontWeight: FontWeight.w800),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSizes.md),
                            Text(
                              page['subtitle'],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.4,
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
                  padding: EdgeInsets.all(
                    compact ? AppSizes.md : AppSizes.lg,
                  ),
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
                        width: 190,
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
                              duration: const Duration(milliseconds: 280),
                              curve: Curves.easeOutCubic,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
