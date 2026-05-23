import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:grow/core/constants/app_roles.dart';
import 'package:grow/core/constants/feature_flags.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/lab/domain/lab_providers.dart';
import 'package:grow/features/profile/domain/rc5_profile_providers.dart';
import 'package:grow/shared/models/project_model.dart';
import 'package:grow/shared/widgets/rc5/rc5_widgets.dart';

class RC5ProfileScreen extends ConsumerStatefulWidget {
  const RC5ProfileScreen({super.key});

  @override
  ConsumerState<RC5ProfileScreen> createState() => _RC5ProfileScreenState();
}

class _RC5ProfileScreenState extends ConsumerState<RC5ProfileScreen> {
  static const _tabs = [
    'Overview',
    'Projects',
    'Experience',
    'Education',
    'Volunteering',
  ];

  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RC5DesignTokens.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: RC5DesignTokens.primary,
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              _TopActions(
                onShare: _shareProfile,
                onSettings: _openSettingsSheet,
                onOverflowSelect: _handleOverflowAction,
              ),
              const SizedBox(height: RC5DesignTokens.space3),
              const _ProfileHeaderCard(),
              const SizedBox(height: RC5DesignTokens.space4),
              const _PrivacyBoundaryCard(),
              const SizedBox(height: RC5DesignTokens.space4),
              _ProfileTabs(
                tabs: _tabs,
                activeIndex: _activeTabIndex,
                onSelect: (index) => setState(() => _activeTabIndex = index),
              ),
              const SizedBox(height: RC5DesignTokens.space4),
              AnimatedSwitcher(
                duration: RC5DesignTokens.motionBase,
                child: _buildTabBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBody() {
    return KeyedSubtree(
      key: ValueKey<int>(_activeTabIndex),
      child: switch (_activeTabIndex) {
        0 => const _OverviewTab(),
        1 => const _ProjectsTab(),
        2 => const _ExperienceTab(),
        3 => const _EducationTab(),
        _ => const _VolunteeringTab(),
      },
    );
  }

  Future<void> _refresh() async {
    ref.invalidate(rc5ProfileHeaderProvider);
    ref.invalidate(rc5ProfileStatsProvider);
    ref.invalidate(rc5ProfileProjectsProvider);
    ref.invalidate(rc5PublicProjectsProvider);
    ref.invalidate(rc5ProfileEventParticipationProvider);
    ref.invalidate(rc5ProfileInterestsProvider);
    ref.invalidate(rc5ProfileSkillsProvider);
  }

  void _shareProfile() {
    final header = ref.read(rc5ProfileHeaderProvider).valueOrNull;
    if (header == null) {
      _showSnack('Profile still loading.');
      return;
    }
    final profileUrl = 'https://grow.app/u/${header.username}';
    Clipboard.setData(ClipboardData(text: profileUrl));
    _showSnack('Profile link copied.');
  }

  void _openSettingsSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: RC5DesignTokens.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const SizedBox(height: 8),
              _SettingsTile(
                icon: Icons.forum_rounded,
                title: 'Feedback / Talk to us',
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoon('Feedback');
                },
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms and Conditions',
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoon('Terms and Conditions');
                },
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoon('Privacy Policy');
                },
              ),
              _SettingsTile(
                icon: Icons.groups_rounded,
                title: 'Community Guidelines',
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoon('Community Guidelines');
                },
              ),
              _SettingsTile(
                icon: Icons.volunteer_activism_rounded,
                title: 'Vouch a friend',
                subtitle: 'Let\'s grow our community together.',
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoon('Vouch a friend');
                },
              ),
              const SizedBox(height: RC5DesignTokens.space4),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleOverflowAction(_ProfileOverflowAction action) async {
    switch (action) {
      case _ProfileOverflowAction.deleteAccount:
        _showComingSoon('Delete account');
      case _ProfileOverflowAction.logout:
        await _signOut();
    }
  }

  Future<void> _signOut() async {
    final shouldSignOut = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              backgroundColor: RC5DesignTokens.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RC5DesignTokens.radiusMd),
                side: const BorderSide(color: RC5DesignTokens.ink, width: 2),
              ),
              title: const Text('Sign out?'),
              content: const Text('You can sign in again anytime with Google.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text(
                    'Sign out',
                    style: TextStyle(color: RC5DesignTokens.error),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldSignOut || !mounted) return;

    try {
      final activeSession = await ref.read(activeSessionProvider.future);
      if (activeSession != null) {
        await ref.read(labRepositoryProvider).checkOut(activeSession.id);
      }
    } catch (_) {
      // Best-effort checkout. Sign-out should still continue.
    }

    await ref.read(authRepositoryProvider).signOut();
    if (mounted) context.go('/splash');
  }

  void _showComingSoon(String title) {
    _showSnack('$title is coming in the next RC5 slice.');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _TopActions extends StatelessWidget {
  const _TopActions({
    required this.onShare,
    required this.onSettings,
    required this.onOverflowSelect,
  });

  final VoidCallback onShare;
  final VoidCallback onSettings;
  final ValueChanged<_ProfileOverflowAction> onOverflowSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Profile',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: RC5DesignTokens.ink,
              ),
        ),
        const Spacer(),
        IconButton.filledTonal(
          onPressed: onShare,
          style: IconButton.styleFrom(
            backgroundColor: RC5DesignTokens.surface,
            foregroundColor: RC5DesignTokens.ink,
          ),
          icon: const Icon(Icons.share_outlined),
        ),
        const SizedBox(width: RC5DesignTokens.space2),
        IconButton.filledTonal(
          onPressed: onSettings,
          style: IconButton.styleFrom(
            backgroundColor: RC5DesignTokens.surface,
            foregroundColor: RC5DesignTokens.ink,
          ),
          icon: const Icon(Icons.settings_outlined),
        ),
        const SizedBox(width: RC5DesignTokens.space2),
        PopupMenuButton<_ProfileOverflowAction>(
          onSelected: onOverflowSelect,
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: _ProfileOverflowAction.deleteAccount,
              child: Text(
                'Delete account',
                style: TextStyle(color: RC5DesignTokens.error),
              ),
            ),
            PopupMenuItem(
              value: _ProfileOverflowAction.logout,
              child: Text('Log out'),
            ),
          ],
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.more_horiz_rounded),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeaderCard extends ConsumerWidget {
  const _ProfileHeaderCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headerAsync = ref.watch(rc5ProfileHeaderProvider);
    final statsAsync = ref.watch(rc5ProfileStatsProvider);

    return headerAsync.when(
      data: (header) {
        if (header == null) {
          return const RC5EmptyState(
            icon: Icons.person_off_rounded,
            title: 'Profile unavailable',
            message: 'Pull to refresh and try again.',
          );
        }

        return RC5Card(
          gradient: RC5DesignTokens.softGradient,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  RC5Avatar(
                    imageUrl: header.user.avatarUrl,
                    displayName: header.user.name,
                    size: 72,
                  ),
                  const SizedBox(width: RC5DesignTokens.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          header.user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '@${header.username}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: RC5DesignTokens.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: RC5DesignTokens.space2),
                        Wrap(
                          spacing: RC5DesignTokens.space2,
                          runSpacing: RC5DesignTokens.space2,
                          children: [
                            RC5Chip(
                              label: header.departmentOrRole,
                              compact: true,
                            ),
                            if (FeatureFlags.enableVouches)
                              const RC5Chip(
                                label: 'Vouches: coming soon',
                                icon: Icons.verified_outlined,
                                compact: true,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: RC5DesignTokens.space4),
              Text(
                header.bio,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: RC5DesignTokens.space4),
              Row(
                children: [
                  Expanded(
                    child: RC5Button(
                      label: 'Edit profile',
                      icon: Icons.edit_rounded,
                      variant: RC5ButtonVariant.secondary,
                      onPressed: () => context.push('/profile/edit'),
                    ),
                  ),
                  const SizedBox(width: RC5DesignTokens.space3),
                  Expanded(
                    child: statsAsync.when(
                      data: (stats) => _StatPill(
                        text:
                            '${stats.projects} projects • ${stats.events} events',
                      ),
                      loading: () => const _StatPill(text: 'Loading stats...'),
                      error: (_, __) =>
                          const _StatPill(text: 'Stats unavailable'),
                    ),
                  ),
                ],
              ),
              if (AppRole.isAdminRole(header.user.role)) ...[
                const SizedBox(height: RC5DesignTokens.space3),
                RC5Button(
                  label: 'Open admin dashboard',
                  icon: Icons.admin_panel_settings_outlined,
                  variant: RC5ButtonVariant.ghost,
                  fullWidth: true,
                  onPressed: () => context.push('/admin'),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const RC5Skeleton(width: double.infinity, height: 280),
      error: (_, __) => const RC5EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Could not load profile',
        message: 'Pull to refresh and try again.',
      ),
    );
  }
}

class _PrivacyBoundaryCard extends StatelessWidget {
  const _PrivacyBoundaryCard();

  @override
  Widget build(BuildContext context) {
    return RC5Card(
      backgroundColor: Colors.white,
      shadowOpacity: 0.55,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: RC5DesignTokens.primary,
          ),
          const SizedBox(width: RC5DesignTokens.space3),
          Expanded(
            child: Text(
              'Profile basics, public projects, and event participation are visible to Grow users. '
              'Detailed activity history, booking history, and KTU ID remain private.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: RC5DesignTokens.textSecondary,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs({
    required this.tabs,
    required this.activeIndex,
    required this.onSelect,
  });

  final List<String> tabs;
  final int activeIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: RC5DesignTokens.space2),
        itemBuilder: (context, index) {
          return RC5Chip(
            label: tabs[index],
            isSelected: index == activeIndex,
            onTap: () => onSelect(index),
          );
        },
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interestsAsync = ref.watch(rc5ProfileInterestsProvider);
    final skillsAsync = ref.watch(rc5ProfileSkillsProvider);
    final eventsAsync = ref.watch(rc5ProfileEventParticipationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TabSection(
          title: 'Interests',
          child: interestsAsync.when(
            data: (interests) {
              if (interests.isEmpty) {
                return const RC5EmptyState(
                  icon: Icons.interests_rounded,
                  title: 'No interests yet',
                  message: 'Add interests from Edit Profile.',
                );
              }
              return Wrap(
                spacing: RC5DesignTokens.space2,
                runSpacing: RC5DesignTokens.space2,
                children: interests
                    .map((item) => RC5Chip(label: item, compact: true))
                    .toList(),
              );
            },
            loading: () =>
                const RC5Skeleton(width: double.infinity, height: 72),
            error: (_, __) => const Text('Could not load interests.'),
          ),
        ),
        const SizedBox(height: RC5DesignTokens.space4),
        _TabSection(
          title: 'Skills',
          child: skillsAsync.when(
            data: (skills) {
              if (skills.isEmpty) {
                return const RC5EmptyState(
                  icon: Icons.code_rounded,
                  title: 'No skills added yet',
                  message: 'You can add skills and familiarity later.',
                );
              }
              return Wrap(
                spacing: RC5DesignTokens.space2,
                runSpacing: RC5DesignTokens.space2,
                children: skills.entries.map((entry) {
                  return _SkillLevelPill(
                    skill: entry.key,
                    level: entry.value.clamp(1, 3),
                  );
                }).toList(),
              );
            },
            loading: () =>
                const RC5Skeleton(width: double.infinity, height: 72),
            error: (_, __) => const Text('Could not load skills.'),
          ),
        ),
        const SizedBox(height: RC5DesignTokens.space4),
        _TabSection(
          title: 'Public event participation',
          child: eventsAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const RC5EmptyState(
                  icon: Icons.event_busy_rounded,
                  title: 'No event participation yet',
                  message: 'Upcoming workshop participation will show up here.',
                );
              }
              return Column(
                children: items.take(5).map((event) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: RC5DesignTokens.space2),
                    child: RC5Card(
                      backgroundColor: Colors.white,
                      shadowOpacity: 0.5,
                      onTap: () => context.push('/events/${event.eventId}'),
                      child: Row(
                        children: [
                          const Icon(Icons.event_rounded,
                              color: RC5DesignTokens.primary),
                          const SizedBox(width: RC5DesignTokens.space3),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                                Text(
                                  '${event.status} • ${event.venue ?? 'IDEA Lab'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: RC5DesignTokens.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const RC5SkeletonList(itemCount: 3),
            error: (_, __) => const Text('Could not load events.'),
          ),
        ),
      ],
    );
  }
}

class _ProjectsTab extends ConsumerWidget {
  const _ProjectsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(rc5ProfileProjectsProvider);
    final publicAsync = ref.watch(rc5PublicProjectsProvider);

    return _TabSection(
      title: 'Projects',
      subtitle:
          'Projects are visible by default. Public items are highlighted.',
      child: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return RC5EmptyState(
              icon: Icons.folder_open_rounded,
              title: 'No projects yet',
              message: 'Create or join projects to start your portfolio.',
              primaryActionLabel: 'Browse projects',
              onPrimaryAction: () => context.push('/projects'),
            );
          }

          final publicIds =
              publicAsync.valueOrNull?.map((p) => p.id).toSet() ?? <String>{};

          return Column(
            children: projects.take(8).map((project) {
              return Padding(
                padding: const EdgeInsets.only(bottom: RC5DesignTokens.space3),
                child: _ProjectCard(
                  project: project,
                  isPublic: publicIds.contains(project.id),
                ),
              );
            }).toList(),
          );
        },
        loading: () => const RC5SkeletonList(itemCount: 4),
        error: (_, __) => const RC5EmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'Projects unavailable',
          message: 'Pull to refresh and try again.',
        ),
      ),
    );
  }
}

class _ExperienceTab extends StatelessWidget {
  const _ExperienceTab();

  @override
  Widget build(BuildContext context) {
    return _TabSection(
      title: 'Experience',
      subtitle: 'Internships, part-time roles, and practical work.',
      child: RC5EmptyState(
        icon: Icons.work_outline_rounded,
        title: 'No experience entries yet',
        message: 'Add internships and work roles from Edit Profile.',
        primaryActionLabel: 'Add experience',
        onPrimaryAction: () => context.push('/profile/edit'),
      ),
    );
  }
}

class _EducationTab extends StatelessWidget {
  const _EducationTab();

  @override
  Widget build(BuildContext context) {
    return _TabSection(
      title: 'Education',
      subtitle: 'Current and past learning timeline.',
      child: RC5EmptyState(
        icon: Icons.school_outlined,
        title: 'No education timeline yet',
        message: 'Add your department, batch, and education history.',
        primaryActionLabel: 'Add education',
        onPrimaryAction: () => context.push('/profile/edit'),
      ),
    );
  }
}

class _VolunteeringTab extends StatelessWidget {
  const _VolunteeringTab();

  @override
  Widget build(BuildContext context) {
    return _TabSection(
      title: 'Volunteering',
      subtitle: 'Community and social contributions.',
      child: RC5EmptyState(
        icon: Icons.volunteer_activism_outlined,
        title: 'No volunteering entries yet',
        message: 'You can add volunteering details now or later.',
        primaryActionLabel: 'Add volunteering',
        onPrimaryAction: () => context.push('/profile/edit'),
      ),
    );
  }
}

class _TabSection extends StatelessWidget {
  const _TabSection({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RC5Card(
      backgroundColor: Colors.white,
      shadowOpacity: 0.65,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: RC5DesignTokens.space2),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: RC5DesignTokens.textSecondary,
                  ),
            ),
          ],
          const SizedBox(height: RC5DesignTokens.space3),
          child,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: RC5DesignTokens.primary),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.isPublic,
  });

  final ProjectModel project;
  final bool isPublic;

  @override
  Widget build(BuildContext context) {
    return RC5Card(
      backgroundColor: RC5DesignTokens.surface,
      shadowOpacity: 0.55,
      onTap: () => context.push('/projects/${project.id}'),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: RC5DesignTokens.primaryGradient,
              borderRadius: BorderRadius.circular(RC5DesignTokens.radiusMd),
            ),
            child: const Icon(Icons.rocket_launch_rounded, color: Colors.white),
          ),
          const SizedBox(width: RC5DesignTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  '${project.status} • ${project.visibility}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: RC5DesignTokens.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          RC5Chip(
            label: isPublic ? 'Public' : 'Private',
            compact: true,
            isSelected: isPublic,
            color: isPublic ? RC5DesignTokens.success : RC5DesignTokens.ink,
          ),
        ],
      ),
    );
  }
}

class _SkillLevelPill extends StatelessWidget {
  const _SkillLevelPill({
    required this.skill,
    required this.level,
  });

  final String skill;
  final int level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: RC5DesignTokens.surface,
        borderRadius: BorderRadius.circular(RC5DesignTokens.radiusPill),
        border: Border.all(color: RC5DesignTokens.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(width: RC5DesignTokens.space2),
          Row(
            children: List.generate(3, (index) {
              final isFilled = index < level;
              return Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(left: 3),
                decoration: BoxDecoration(
                  color:
                      isFilled ? _skillDotColor(index) : RC5DesignTokens.border,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RC5DesignTokens.radiusMd),
        border: Border.all(color: RC5DesignTokens.border),
      ),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: RC5DesignTokens.textSecondary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

Color _skillDotColor(int index) {
  return switch (index) {
    0 => const Color(0xFF86EFAC),
    1 => const Color(0xFF22C55E),
    _ => const Color(0xFF15803D),
  };
}

enum _ProfileOverflowAction {
  deleteAccount,
  logout,
}
