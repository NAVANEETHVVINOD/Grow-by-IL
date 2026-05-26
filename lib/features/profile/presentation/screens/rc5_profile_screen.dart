import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grow/core/constants/app_roles.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/lab/domain/lab_providers.dart';
import 'package:grow/features/profile/domain/rc5_profile_providers.dart';
import 'package:grow/features/profile/presentation/widgets/digital_id_card.dart';
import 'package:grow/shared/models/project_model.dart';
import 'package:grow/shared/widgets/neo_card.dart';
import 'package:grow/shared/widgets/rc5/rc5_widgets.dart';
import 'package:grow/features/home/presentation/screens/rc5_home_screen.dart';

/// Set to `false` to disable the ticker during DevTools profiling.
/// Compare raster thread timing with ticker ON vs OFF.
const _kEnableProfileTicker = true;

class RC5ProfileScreen extends ConsumerStatefulWidget {
  const RC5ProfileScreen({super.key});

  @override
  ConsumerState<RC5ProfileScreen> createState() => _RC5ProfileScreenState();
}

class _RC5ProfileScreenState extends ConsumerState<RC5ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final header = ref.watch(rc5ProfileHeaderProvider).valueOrNull;
    final tabs = [
      header?.username != null && header!.username.isNotEmpty ? '@${header.username}' : 'Overview',
      'Projects',
      'Experience',
      'Education',
      'Volunteering',
    ];
    assert(() {
      debugPrint('[PROFILE TAB BUILD] TabBarView Container / Root');
      return true;
    }());
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: RC5DesignTokens.background,
        appBar: AppBar(
          backgroundColor: RC5DesignTokens.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          toolbarHeight: 56,
          title: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
            child: _TopActions(
              onShare: _shareProfile,
              onSettings: _openSettingsSheet,
            ),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: RC5DesignTokens.ink,
            labelColor: RC5DesignTokens.ink,
            unselectedLabelColor: RC5DesignTokens.textSecondary,
            labelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 13),
            unselectedLabelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 13),
            tabs: tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            color: RC5DesignTokens.ink,
            onRefresh: _refresh,
            child: const _LazyTabBarView(),
          ),
        ),
      ),
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
              const Divider(),
              _SettingsTile(
                icon: Icons.delete_outline_rounded,
                title: 'Delete account',
                textColor: RC5DesignTokens.error,
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoon('Delete account');
                },
              ),
              _SettingsTile(
                icon: Icons.logout_rounded,
                title: 'Log out',
                onTap: () {
                  Navigator.pop(context);
                  _signOut();
                },
              ),
              const SizedBox(height: RC5DesignTokens.space4),
            ],
          ),
        );
      },
    );
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
  });

  final VoidCallback onShare;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '/// Profile',
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
      ],
    );
  }
}

class _ProfileHeaderCard extends ConsumerWidget {
  const _ProfileHeaderCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    assert(() {
      debugPrint('[PROFILE TAB BUILD] ProfileHeaderCard');
      return true;
    }());
    final headerAsync = ref.watch(rc5ProfileHeaderProvider);

    return headerAsync.when(
      data: (header) {
        if (header == null) {
          return const RC5EmptyState(
            icon: Icons.person_off_rounded,
            title: 'Profile unavailable',
            message: 'Pull to refresh and try again.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RepaintBoundary(child: DigitalIdCard(user: header.user)),
            const SizedBox(height: RC5DesignTokens.space4),
            NeoCard(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ABOUT ME',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: RC5DesignTokens.textSecondary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    header.bio.isNotEmpty ? header.bio : 'Builder at IDEA Lab, exploring projects and collaboration.',
                    style: RC5DesignTokens.body,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: RC5Button(
                          label: 'Edit Profile',
                          icon: Icons.edit_rounded,
                          variant: RC5ButtonVariant.secondary,
                          onPressed: () => context.push('/profile/edit'),
                        ),
                      ),
                    ],
                  ),
                  if (AppRole.isAdminRole(header.user.role)) ...[
                    const SizedBox(height: RC5DesignTokens.space3),
                    RC5Button(
                      label: 'Open Admin Dashboard',
                      icon: Icons.admin_panel_settings_outlined,
                      variant: RC5ButtonVariant.ghost,
                      fullWidth: true,
                      onPressed: () => context.push('/admin'),
                    ),
                  ],
                ],
              ),
            ),
          ],
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
            color: RC5DesignTokens.textSecondary,
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

// _ProfileTabs removed
class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    assert(() {
      debugPrint('[PROFILE TAB BUILD] OverviewTab');
      return true;
    }());
    final interestsAsync = ref.watch(rc5ProfileInterestsProvider);
    final skillsAsync = ref.watch(rc5ProfileSkillsProvider);
    final eventsAsync = ref.watch(rc5ProfileEventParticipationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: RC5DesignTokens.space3),
        if (_kEnableProfileTicker)
          Transform.rotate(
            angle: 0.02,
            child: const RepaintBoundary(
              child: ScrollingTicker(
                text: '/// MAKER PROFILE · KEEP BUILDING · UPDATE YOUR SKILLS IN SECTIONS BELOW · CONNECT WITH MENTORS ///',
                backgroundColor: Color(0xFFFFEA00), // Yellow
                textColor: Colors.black,
              ),
            ),
          ),
        const SizedBox(height: RC5DesignTokens.space4),
        const RepaintBoundary(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _ProfileHeaderCard(),
          ),
        ),
        const SizedBox(height: RC5DesignTokens.space5),
        const RepaintBoundary(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _CollectibleBadgesSection(),
          ),
        ),
        const SizedBox(height: RC5DesignTokens.space5),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _ContributionStatsGrid(),
        ),
        const SizedBox(height: RC5DesignTokens.space5),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _PrivacyBoundaryCard(),
        ),
        const SizedBox(height: RC5DesignTokens.space5),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          child: Column(
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
                  accentColor: RC5DesignTokens.accent,
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
                  accentColor: RC5DesignTokens.success,
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
                  accentColor: RC5DesignTokens.warning,
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
                              color: RC5DesignTokens.textSecondary),
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
    assert(() {
      debugPrint('[PROFILE TAB BUILD] ProjectsTab');
      return true;
    }());
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
              accentColor: RC5DesignTokens.accent,
            );
          }

          final publicProjects = publicAsync.valueOrNull ?? [];
          final otherProjects = ref.watch(rc5PrivateProjectsProvider).valueOrNull ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (publicProjects.isNotEmpty) ...[
                Text(
                  'Pinned',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: RC5DesignTokens.ink,
                      ),
                ),
                const SizedBox(height: RC5DesignTokens.space2),
                _ProjectCard(
                  project: publicProjects.first,
                  isPublic: true,
                  isPinned: true,
                ),
                const SizedBox(height: RC5DesignTokens.space4),
              ],
              ...[...publicProjects.skip(1), ...otherProjects]
                  .take(7)
                  .map((project) {
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: RC5DesignTokens.space3),
                  child: _ProjectCard(
                    project: project,
                    isPublic: false,
                  ),
                );
              }),
            ],
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
    assert(() {
      debugPrint('[PROFILE TAB BUILD] ExperienceTab');
      return true;
    }());
    return _TabSection(
      title: 'Experience',
      subtitle: 'Internships, part-time roles, and practical work.',
      child: RC5EmptyState(
        icon: Icons.work_outline_rounded,
        title: 'No experience entries yet',
        message: 'Add internships and work roles from Edit Profile.',
        primaryActionLabel: 'Add experience',
        onPrimaryAction: () => context.push('/profile/edit'),
        accentColor: RC5DesignTokens.warning,
      ),
    );
  }
}

class _EducationTab extends StatelessWidget {
  const _EducationTab();

  @override
  Widget build(BuildContext context) {
    assert(() {
      debugPrint('[PROFILE TAB BUILD] EducationTab');
      return true;
    }());
    return _TabSection(
      title: 'Education',
      subtitle: 'Current and past learning timeline.',
      child: RC5EmptyState(
        icon: Icons.school_outlined,
        title: 'No education timeline yet',
        message: 'Add your department, batch, and education history.',
        primaryActionLabel: 'Add education',
        onPrimaryAction: () => context.push('/profile/edit'),
        accentColor: RC5DesignTokens.accent,
      ),
    );
  }
}

class _VolunteeringTab extends StatelessWidget {
  const _VolunteeringTab();

  @override
  Widget build(BuildContext context) {
    assert(() {
      debugPrint('[PROFILE TAB BUILD] VolunteeringTab');
      return true;
    }());
    return _TabSection(
      title: 'Volunteering',
      subtitle: 'Community and social contributions.',
      child: RC5EmptyState(
        icon: Icons.volunteer_activism_outlined,
        title: 'No volunteering entries yet',
        message: 'You can add volunteering details now or later.',
        primaryActionLabel: 'Add volunteering',
        onPrimaryAction: () => context.push('/profile/edit'),
        accentColor: RC5DesignTokens.success,
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
    this.textColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: textColor ?? RC5DesignTokens.textSecondary),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.isPublic,
    this.isPinned = false,
  });

  final ProjectModel project;
  final bool isPublic;
  final bool isPinned;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: RC5DesignTokens.surface,
        borderRadius: BorderRadius.circular(RC5DesignTokens.radiusMd),
        border: Border.all(color: RC5DesignTokens.border, width: RC5DesignTokens.borderWidth),
        boxShadow: RC5DesignTokens.neoShadow(offset: const Offset(3, 3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/projects/${project.id}'),
          borderRadius: BorderRadius.circular(RC5DesignTokens.radiusMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Banner zone ──
              Container(
                height: 100,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: RC5DesignTokens.surfaceAlt,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(RC5DesignTokens.radiusMd - RC5DesignTokens.borderWidth)),
                  border: Border(bottom: BorderSide(color: RC5DesignTokens.border, width: RC5DesignTokens.borderWidth)),
                ),
                child: const Center(
                  child: Icon(Icons.rocket_launch_rounded, size: 36, color: RC5DesignTokens.ink),
                ),
              ),
              // ── Content zone ──
              Padding(
                padding: const EdgeInsets.fromLTRB(RC5DesignTokens.space4, RC5DesignTokens.space3, RC5DesignTokens.space4, RC5DesignTokens.space3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: RC5DesignTokens.ink,
                      ),
                    ),
                    if (project.description != null && project.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        project.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: RC5DesignTokens.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // ── Footer zone (compact) ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: RC5DesignTokens.space4, vertical: RC5DesignTokens.space2),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: RC5DesignTokens.border, width: RC5DesignTokens.borderWidth)),
                ),
                child: Row(
                  children: [
                    if (isPinned) ...[
                      const Icon(Icons.push_pin_rounded, size: 12, color: RC5DesignTokens.ink),
                      const SizedBox(width: 3),
                      Text('PINNED', style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w700, color: RC5DesignTokens.ink, letterSpacing: 0.5)),
                      const SizedBox(width: RC5DesignTokens.space3),
                    ],
                    Icon(isPublic ? Icons.public_rounded : Icons.lock_rounded, size: 12, color: RC5DesignTokens.muted),
                    const SizedBox(width: 3),
                    Text(isPublic ? 'PUBLIC' : 'PRIVATE', style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w700, color: RC5DesignTokens.muted, letterSpacing: 0.5)),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_rounded, size: 14, color: RC5DesignTokens.muted),
                  ],
                ),
              ),
            ],
          ),
        ),
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

Color _skillDotColor(int index) {
  return switch (index) {
    0 => const Color(0xFF86EFAC),
    1 => const Color(0xFF22C55E),
    _ => const Color(0xFF15803D),
  };
}

// Empty
class _CollectibleBadgesSection extends StatelessWidget {
  const _CollectibleBadgesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Collectible Badges',
            style: RC5DesignTokens.sectionTitle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Wrap(
            spacing: 14,
            runSpacing: 16,
            children: const [
              _StickerBadge(
                icon: Icons.build_rounded,
                label: 'Builder',
                color: Color(0xFFDFF4FF),
                angle: -0.04,
              ),
              _StickerBadge(
                icon: Icons.precision_manufacturing_rounded,
                label: 'Robotics',
                color: Color(0xFFF7EEB4),
                angle: 0.02,
              ),
              _StickerBadge(
                icon: Icons.lightbulb_outline_rounded,
                label: 'Innovator',
                color: Color(0xFFE5E7EB),
                angle: -0.01,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StickerBadge extends StatelessWidget {
  const _StickerBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.angle,
  });

  final IconData icon;
  final String label;
  final Color color;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF111111), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF111111),
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF111111)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111111),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContributionStatsGrid extends ConsumerWidget {
  const _ContributionStatsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    assert(() {
      debugPrint('[PROFILE TAB BUILD] ContributionStatsGrid');
      return true;
    }());
    final statsAsync = ref.watch(rc5ProfileStatsProvider);

    return statsAsync.when(
      data: (stats) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Contribution Stats',
                style: RC5DesignTokens.sectionTitle,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Projects Created',
                    value: stats.projects.toString(),
                    icon: Icons.rocket_launch_outlined,
                    color: const Color(0xFFDFF4FF),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    label: 'Events Attended',
                    value: stats.events.toString(),
                    icon: Icons.event_outlined,
                    color: const Color(0xFFE5E7EB),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Tools Booked',
                    value: stats.tools.toString(),
                    icon: Icons.construction_outlined,
                    color: const Color(0xFFF7EEB4),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatCard(
                    label: 'Lab Check-ins',
                    value: stats.visits.toString(),
                    icon: Icons.login_outlined,
                    color: const Color(0xFFDDF5D7),
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const RC5Skeleton(width: double.infinity, height: 160),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF111111), width: 1.5),
                ),
                child: Icon(icon, size: 16, color: const Color(0xFF111111)),
              ),
              Text(
                value,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111111),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF71717A),
            ),
          ),
        ],
      ),
    );
  }
}

class _LazyTabBarView extends StatefulWidget {
  const _LazyTabBarView();

  @override
  State<_LazyTabBarView> createState() => _LazyTabBarViewState();
}

class _LazyTabBarViewState extends State<_LazyTabBarView> {
  int _currentIndex = 0;
  final Set<int> _visited = {0};
  TabController? _tabController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newController = DefaultTabController.of(context);
    if (newController != _tabController) {
      _tabController?.removeListener(_handleTabChange);
      _tabController = newController;
      _tabController?.addListener(_handleTabChange);

      if (_tabController != null) {
        _currentIndex = _tabController!.index;
        _visited.add(_currentIndex);
      }
    }
  }

  void _handleTabChange() {
    if (mounted && _tabController != null) {
      if (_tabController!.index != _currentIndex) {
        setState(() {
          _currentIndex = _tabController!.index;
          _visited.add(_currentIndex);
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabChange);
    super.dispose();
  }

  Widget _buildTab(int index, Widget child) {
    if (!_visited.contains(index)) {
      return const SizedBox.shrink();
    }
    assert(() {
      debugPrint('[PROFILE TAB BUILD] LazyTabBarView rendering (Index $index)');
      return true;
    }());
    return child;
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _currentIndex,
      children: [
        _buildTab(0, const SingleChildScrollView(child: _OverviewTab())),
        _buildTab(1, const SingleChildScrollView(padding: EdgeInsets.fromLTRB(20, 24, 20, 40), child: _ProjectsTab())),
        _buildTab(2, const SingleChildScrollView(padding: EdgeInsets.fromLTRB(20, 24, 20, 40), child: _ExperienceTab())),
        _buildTab(3, const SingleChildScrollView(padding: EdgeInsets.fromLTRB(20, 24, 20, 40), child: _EducationTab())),
        _buildTab(4, const SingleChildScrollView(padding: EdgeInsets.fromLTRB(20, 24, 20, 40), child: _VolunteeringTab())),
      ],
    );
  }
}

