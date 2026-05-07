import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/widgets/neo_button.dart';
import '../../../../shared/widgets/neo_card.dart';
import '../../../../shared/widgets/shimmer_skeleton.dart';
import '../widgets/digital_id_card.dart';
import '../../../auth/shared/models/user_model.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../lab/domain/lab_providers.dart';
import '../../../lab/domain/tool_providers.dart';
import '../../../projects/domain/project_providers.dart';
import '../domain/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: userAsync.when(
          data: (user) {
            if (user == null) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_off_rounded, size: 48, color: AppColors.textSecondary),
                    SizedBox(height: AppSizes.md),
                    Text('No user data'),
                  ],
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(AppSizes.lg),
              children: [
                // ── Maker Identity Card ────────────────────────
                DigitalIdCard(user: user),
                const SizedBox(height: AppSizes.md),
                _buildBadges(user),
                const SizedBox(height: AppSizes.xl),

                // ── Stats Row ──────────────────────────────────
                _buildStatsRow(ref),
                const SizedBox(height: AppSizes.xl),

                // ── Tool Belt (Expertise) ────────────────────────
                _buildSectionHeader('Tool Belt'),
                const SizedBox(height: AppSizes.md),
                _buildToolBelt(ref),
                const SizedBox(height: AppSizes.xl),

                // ── Portfolio Showcase ────────────────────────
                _buildSectionHeader(
                  'Project Showcase',
                  onAction: () => context.push('/projects/create'),
                  actionLabel: 'ADD',
                ),
                const SizedBox(height: AppSizes.md),
                _buildPortfolio(ref),
                const SizedBox(height: AppSizes.xl),

                // ── Recognition & Links ────────────────────────
                _buildSectionHeader('Links & Presence'),
                const SizedBox(height: AppSizes.md),
                Row(
                  children: [
                    _buildLinkTile(
                      label: 'GitHub',
                      icon: Icons.code_rounded,
                      color: AppColors.navy,
                      textColor: Colors.white,
                      onTap: () {}, // Link to GitHub
                    ),
                    const SizedBox(width: AppSizes.md),
                    _buildLinkTile(
                      label: 'Skills',
                      icon: Icons.psychology_outlined,
                      color: AppColors.yellow,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.xxl),

                // ── Sign Out ────────────────────────
                NeoButton(
                  label: 'Sign Out',
                  icon: Icons.logout_rounded,
                  color: AppColors.surface,
                  textColor: AppColors.red,
                  borderColor: AppColors.red,
                  onPressed: () async {
                    AppLogger.action(LogCategory.AUTH, 'signOut');
                    // Auto-checkout if user has active session
                    try {
                      final activeSession = await ref.read(activeSessionProvider.future);
                      if (activeSession != null) {
                        AppLogger.info(LogCategory.LAB, 'Auto-checking out session: ${activeSession.id}');
                        final repo = ref.read(labRepositoryProvider);
                        await repo.checkOut(activeSession.id);
                      }
                    } catch (e) {
                      AppLogger.warn(LogCategory.LAB, 'Auto-checkout failed, continuing sign-out: $e');
                    }

                    await ref.read(authRepositoryProvider).signOut();
                    if (context.mounted) {
                      context.go('/splash');
                    }
                  },
                ),
                const SizedBox(height: AppSizes.lg),
              ],
            );
          },
          loading: () => Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              children: const [
                ShimmerSkeleton(width: double.infinity, height: 300),
                SizedBox(height: AppSizes.xl),
                ShimmerSkeleton(width: double.infinity, height: 100),
                SizedBox(height: AppSizes.xl),
                ShimmerSkeleton(width: double.infinity, height: 60),
              ],
            ),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.red),
                const SizedBox(height: AppSizes.md),
                const Text('Something went wrong'),
                const SizedBox(height: AppSizes.md),
                NeoButton(
                  label: 'Retry',
                  width: 120,
                  onPressed: () => ref.invalidate(currentUserProvider),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _StatItem(
          label: 'Visits',
          countAsync: ref.watch(userLabVisitsCountProvider),
          icon: Icons.science_outlined,
        ),
        _StatItem(
          label: 'Tools',
          countAsync: ref.watch(userToolsUsedCountProvider),
          icon: Icons.build_outlined,
        ),
        _StatItem(
          label: 'Events',
          countAsync: ref.watch(userEventsCountProvider),
          icon: Icons.event_outlined,
        ),
        _StatItem(
          label: 'Projects',
          countAsync: ref.watch(userProjectsCountProvider),
          icon: Icons.rocket_launch_outlined,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onAction, String? actionLabel}) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.yellow,
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
        const Spacer(),
        if (onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel ?? 'VIEW ALL',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.cobalt,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildToolBelt(WidgetRef ref) {
    final bookingsAsync = ref.watch(myBookingsProvider);
    return bookingsAsync.when(
      data: (bookings) {
        if (bookings.isEmpty) return const Text('No equipment used yet.');
        final uniqueTools = bookings.map((b) => b.toolId).toSet().take(4).toList();
        return Wrap(
          spacing: 8,
          children: uniqueTools
              .map((id) => Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.navy, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.build_circle_outlined, size: 24),
                  ))
              .toList(),
        );
      },
      loading: () => const ShimmerSkeleton(width: double.infinity, height: 50),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildPortfolio(WidgetRef ref) {
    final projectsAsync = ref.watch(userProjectsProvider);
    return projectsAsync.when(
      data: (projects) {
        if (projects.isEmpty) return const Text('No projects started yet.');
        return SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: projects.length,
            separatorBuilder: (context, index) => const SizedBox(width: AppSizes.md),
            itemBuilder: (context, index) {
              final project = projects[index];
              return Container(
                width: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.navy, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: AppColors.navy, offset: Offset(4, 4))],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      project.type.toUpperCase(),
                      style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      loading: () => const ShimmerSkeleton(width: double.infinity, height: 100),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildLinkTile({required String label, required IconData icon, required Color color, Color? textColor, required VoidCallback onTap}) {
    return Expanded(
      child: NeoCard(
        color: color,
        padding: const EdgeInsets.all(12),
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: textColor ?? AppColors.navy),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textColor ?? AppColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadges(UserModel user) {
    final badges = <Map<String, dynamic>>[
      if (user.level >= 2) {'name': 'Tinkerer', 'icon': Icons.auto_awesome_rounded, 'color': AppColors.yellow},
      if (user.level >= 4) {'name': 'Builder', 'icon': Icons.construction_rounded, 'color': AppColors.orange},
      if (user.systemRole != 'user') {'name': 'Mentor', 'icon': Icons.school_rounded, 'color': AppColors.cobalt},
      {'name': 'Verified', 'icon': Icons.verified_user_rounded, 'color': AppColors.green},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: badges
          .map((b) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (b['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: b['color'] as Color, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(b['icon'] as IconData, size: 14, color: b['color'] as Color),
                    const SizedBox(width: 4),
                    Text(
                      b['name'] as String,
                      style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.bold, color: b['color'] as Color),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.countAsync, required this.icon});
  final String label;
  final AsyncValue<int> countAsync;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.navy.withOpacity(0.5)),
        const SizedBox(height: 4),
        countAsync.when(
          data: (count) => Text(
            count.toString(),
            style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy),
          ),
          loading: () => const ShimmerSkeleton(width: 24, height: 20),
          error: (_, __) => const Text('0'),
        ),
        Text(
          label,
          style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
