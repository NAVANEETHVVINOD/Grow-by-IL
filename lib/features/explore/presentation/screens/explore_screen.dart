import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:grow/core/constants/app_colors.dart';
import 'package:grow/core/constants/app_sizes.dart';
import 'package:grow/core/constants/app_strings.dart';
import 'package:grow/shared/widgets/neo_card.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.explore,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              _buildSectionHeader(AppStrings.ourServices),
              const SizedBox(height: AppSizes.md),
              _buildServiceCard(
                title: AppStrings.innovationLab,
                desc: AppStrings.innovationLabDesc,
                icon: Icons.science_rounded,
                color: AppColors.yellow,
                onTap: () => context.go('/lab'),
              ),
              _buildServiceCard(
                title: AppStrings.toolCatalog,
                desc: AppStrings.toolCatalogDesc,
                icon: Icons.build_rounded,
                color: AppColors.cobalt,
                iconColor: Colors.white,
                onTap: () => context.push('/tools'),
              ),
              _buildServiceCard(
                title: AppStrings.projectSupport,
                desc: AppStrings.projectSupportDesc,
                icon: Icons.rocket_launch_rounded,
                color: AppColors.green,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(AppStrings.projectSupportComingSoon)),
                  );
                },
              ),
              const SizedBox(height: AppSizes.xl),
              _buildSectionHeader(AppStrings.knowledgeBase),
              const SizedBox(height: AppSizes.md),
              NeoCard(
                color: Colors.white,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(AppStrings.makerWikiComingSoon)),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.makerWiki,
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              AppStrings.makerWikiSubtitle,
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.xxl),
              _buildSectionHeader(AppStrings.aboutIdeaLab),
              const SizedBox(height: AppSizes.md),
              Text(
                AppStrings.ideaLabAbout,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text(
                AppStrings.appTagline,
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: NeoCard(
        color: color,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              Icon(icon, size: 32, color: iconColor ?? AppColors.navy),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: iconColor ?? AppColors.navy,
                      ),
                    ),
                    Text(
                      desc,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: (iconColor ?? AppColors.navy).withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: iconColor ?? AppColors.navy,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
