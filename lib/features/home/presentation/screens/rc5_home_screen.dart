import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:grow/core/constants/app_colors.dart';
import 'package:grow/core/constants/app_roles.dart';
import 'package:grow/core/constants/feature_flags.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/explore/domain/event_providers.dart';
import 'package:grow/features/lab/domain/lab_providers.dart';
import 'package:grow/features/notifications/domain/notification_providers.dart';
import 'package:grow/features/projects/domain/project_providers.dart';
import 'package:grow/shared/models/user_model.dart';
import 'package:grow/shared/widgets/neo_card.dart';
import 'package:grow/shared/widgets/rc5/rc5_widgets.dart';

class RC5HomeScreen extends StatelessWidget {
  const RC5HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RC5DesignTokens.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: RC5DesignTokens.primary,
          onRefresh: () async {
            final container = ProviderScope.containerOf(context);
            container.invalidate(currentUserProvider);
            container.invalidate(activeSessionProvider);
            container.invalidate(activeEventsProvider);
            container.invalidate(userProjectsProvider);
          },
          child: ListView(
            clipBehavior: Clip.none,
            padding: const EdgeInsets.fromLTRB(0, 18, 0, 120),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: HomeHeader(),
              ),
              const SizedBox(height: 16),
              Transform.rotate(
                angle: 0.035,
                child: const ScrollingTicker(
                  text:
                      '/// LATEST NEWS: New CNC Mill is now operational! Check out the updated safety guide in the Knowledge Base...',
                  backgroundColor: RC5DesignTokens.surfaceAlt,
                  textColor: RC5DesignTokens.ink,
                  speedMultiplier: 1.0,
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: HomeHandleCard(),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: CompactActionsBox(),
              ),
              const SizedBox(height: 20),
              const SlashDivider(),
              const SizedBox(height: 20),
              const FeaturedActivitiesSection(),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: OpportunitiesSection(),
              ),
              const SizedBox(height: 24),
              const SlashDivider(),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ThreeNavigationButtons(),
              ),
              const SizedBox(height: 32),
              Transform.rotate(
                angle: -0.035,
                child: const ScrollingTicker(
                  text:
                      '/// BUILD. BREAK. GROW. /// SHIP IDEAS. NOT EXCUSES. /// CREATE > CONSUME ///',
                  backgroundColor: RC5DesignTokens.ink,
                  textColor: Colors.white,
                  speedMultiplier: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SlashDivider extends StatelessWidget {
  const SlashDivider(
      {super.key, this.color = AppColors.navy, this.height = 20});

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              25,
              (index) => Text(
                ' //  ',
                style: TextStyle(
                  color: color.withValues(alpha: 0.35),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Row(
      children: [
        const RC5GrowLogo(size: 32),
        const SizedBox(width: 10),
        Text(
          'Grow~',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontFamilyFallback: const ['Roboto', 'sans-serif'],
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111111),
            letterSpacing: -1.0,
          ),
        ),
        const Spacer(),
        userAsync.maybeWhen(
          data: (user) {
            if (user == null) return const SizedBox.shrink();
            return Row(
              children: [
                const _NotificationBadge(),
                if (AppRole.isAdminRole(user.role)) ...[
                  const SizedBox(width: 10),
                  RC5Button(
                    label: 'Admin',
                    icon: Icons.admin_panel_settings_outlined,
                    variant: RC5ButtonVariant.secondary,
                    onPressed: () => context.push('/admin'),
                  ),
                ],
              ],
            );
          },
          orElse: () => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _NotificationBadge extends ConsumerWidget {
  const _NotificationBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return _IconBadgeButton(
      icon: Icons.notifications_outlined,
      count: unreadCount,
      onTap: () => context.push('/notifications'),
    );
  }
}

class HomeHandleCard extends ConsumerWidget {
  const HomeHandleCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        return NeoCard(
          color: Colors.white,
          onTap: () => context.go('/profile'),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              RC5Avatar(
                imageUrl: user.avatarUrl,
                displayName: user.name,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'idealab.org/${_profileHandle(user)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: AppColors.navy,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.navy,
                size: 18,
              ),
            ],
          ),
        );
      },
      loading: () => const RC5Skeleton(width: double.infinity, height: 56),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class CompactActionsBox extends StatelessWidget {
  const CompactActionsBox({super.key});

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _CompactActionItem(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Check In',
            color: const Color(0xFFFFEA00), // Pure/Vibrant yellow
            onTap: () => context.push('/lab'),
          ),
          _CompactActionItem(
            icon: FeatureFlags.enableWorkRequests
                ? Icons.assignment_add
                : Icons.construction_rounded,
            label: FeatureFlags.enableWorkRequests ? 'Request' : 'Book Tools',
            color: const Color(0xFF38BDF8), // Cyan
            onTap: () => context.push(
              FeatureFlags.enableWorkRequests ? '/work-requests' : '/tools',
            ),
          ),
          _CompactActionItem(
            icon: Icons.folder_copy_rounded,
            label: 'Projects',
            color: const Color(0xFF2ECC71), // Green
            onTap: () => context.push('/projects'),
          ),
          _CompactActionItem(
            icon: Icons.event_rounded,
            label: 'Events',
            color: const Color(0xFFFF8EFA), // Pink
            onTap: () => context.push('/events'),
          ),
        ],
      ),
    );
  }
}

class _CompactActionItem extends StatelessWidget {
  const _CompactActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.navy, width: 2.2),
              ),
              child: Icon(icon, color: AppColors.navy, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeaturedActivitiesSection extends ConsumerWidget {
  const FeaturedActivitiesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(activeEventsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Featured activities',
            style: RC5DesignTokens.sectionTitle,
          ),
        ),
        const SizedBox(height: 16),
        events.when(
          data: (items) {
            final upcoming = items.where((event) => !event.isPast).toList();

            if (upcoming.isEmpty) {
              return const SizedBox(
                height: 120,
                child: Center(
                  child: Text(
                    'No activities queued right now.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 330,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: upcoming.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final event = upcoming[index];

                  return SizedBox(
                    width: 280,
                    child: NeoCard(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      onTap: () {
                        context.push('/events/${event.id}');
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: AppColors.navy,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${_formatDate(event.eventDate)} · ${_timeOnly(event.eventDate)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  event.venue ?? 'IDEA Lab',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _SmallTag(label: event.type.toUpperCase()),
                              const SizedBox(width: 6),
                              const _SmallTag(label: 'OPEN'),
                            ],
                          ),
                          const Spacer(),
                          // Poster image at bottom of card
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 90,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F0),
                                border: Border.all(
                                    color: AppColors.navy, width: 1.5),
                              ),
                              child: event.imageUrl != null &&
                                      event.imageUrl!.isNotEmpty
                                  ? Image.network(
                                      event.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const _PosterPlaceholder(),
                                    )
                                  : const _PosterPlaceholder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(
            height: 330,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox(
            height: 330,
            child: Center(child: Text('Could not load events.')),
          ),
        ),
      ],
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE0F2FE),
      child: const Center(
        child: Icon(Icons.image_outlined, color: AppColors.navy, size: 32),
      ),
    );
  }
}

class _SmallTag extends StatelessWidget {
  const _SmallTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.navy, width: 1.2),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: AppColors.navy,
        ),
      ),
    );
  }
}

class OpportunitiesSection extends StatelessWidget {
  const OpportunitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final opportunities = [
      _OppItem(
        creator: 'FOSS United',
        title: 'Call for volunteers-IndiaFOSS 2026',
        tags: 'Part Time · Remote · Volunteering',
        logoColor: const Color(0xFFDFF4FF),
        logoText: 'FOSS',
      ),
      _OppItem(
        creator: 'TinkerHub Foundation',
        title: 'Operations Lead',
        tags: 'Full Time · Onsite · Job',
        logoColor: const Color(0xFFE5E7EB),
        logoText: 'TH',
      ),
      _OppItem(
        creator: 'MakerGram',
        title: 'Embedded Systems Engineer',
        tags: 'Full Time · Hybrid · Role',
        logoColor: const Color(0xFFF7EEB4),
        logoText: 'MG',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opportunities',
          style: RC5DesignTokens.sectionTitle,
        ),
        const SizedBox(height: 16),
        // Minimal list items
        ...opportunities.map((opp) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opp.creator,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontFamilyFallback: const ['Roboto', 'sans-serif'],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF71717A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        opp.title,
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontFamilyFallback: const ['Roboto', 'sans-serif'],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        opp.tags,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontFamilyFallback: const ['Roboto', 'sans-serif'],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF71717A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: opp.logoColor,
                    border:
                        Border.all(color: const Color(0xFF111111), width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      opp.logoText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontFamilyFallback: const ['Roboto', 'sans-serif'],
                        color: opp.logoColor == Colors.black
                            ? Colors.white
                            : const Color(0xFF111111),
                        fontWeight: FontWeight.bold,
                        fontSize: opp.logoText.contains('\n') ? 9 : 12,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class ThreeNavigationButtons extends StatelessWidget {
  const ThreeNavigationButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RowButton(
          title: 'Work Requests',
          subtitle: 'Request fabrication, design support, or machine work',
          icon: Icons.assignment_add,
          circleColor: const Color(0xFF38BDF8),
          onTap: () => context.push('/work-requests'),
        ),
        const SizedBox(height: 16),
        _RowButton(
          title: 'Tools & Machines',
          subtitle: 'Reserve available lab tools and equipment',
          icon: Icons.construction_rounded,
          circleColor: const Color(0xFFFFEA00),
          onTap: () => context.push('/tools'),
        ),
        const SizedBox(height: 16),
        _RowButton(
          title: 'Mentorship & Support',
          subtitle: 'Request help with blockers, designs, or guidance',
          icon: Icons.groups_rounded,
          circleColor: const Color(0xFF2ECC71), // Green
          onTap: () => context.push('/mentorship'),
        ),
        const SizedBox(height: 16),
        _RowButton(
          title: 'Learning & Knowledge Base',
          subtitle: 'A library with safety guides, roadmaps & resources',
          icon: Icons.menu_book_rounded,
          circleColor: const Color(0xFFFF8EFA), // Pink
          onTap: () => context.push('/knowledge'),
        ),
        const SizedBox(height: 16),
        _RowButton(
          title: "Don't just dream of a better future",
          subtitle: 'Help create it. Donate to support our space.',
          icon: Icons.diamond_rounded,
          circleColor: const Color(0xFFFFEA00), // Bright Yellow
          onTap: () => context.push('/donate'),
        ),
      ],
    );
  }
}

class _RowButton extends StatelessWidget {
  const _RowButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.circleColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color circleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.navy, width: 2),
            ),
            child: Center(
              child: Icon(icon, color: circleColor, size: 22),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class QuotesFooter extends StatelessWidget {
  const QuotesFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.02, // Opposite and slightly softer tilt
      child: const ScrollingTicker(
        text:
            '/// BUILD. LEARN. SHARE. REPEAT. /// LIVE TO INNOVATE, LEAVE AN IMPACT. /// HAKUNA MATATA /// WORKSHOP TODAY AT 4PM.',
        backgroundColor: Colors.black,
        textColor: Colors.white,
        speedMultiplier: 0.6, // Slower movement
      ),
    );
  }
}

class ScrollingTicker extends StatefulWidget {
  const ScrollingTicker({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.speedMultiplier = 1.0,
  });

  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double speedMultiplier;

  @override
  State<ScrollingTicker> createState() => _ScrollingTickerState();
}

class _ScrollingTickerState extends State<ScrollingTicker> {
  late ScrollController _scrollController;
  bool _scrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() async {
    if (!mounted) return;
    setState(() => _scrolling = true);

    while (mounted && _scrolling) {
      if (!_scrollController.hasClients) {
        await Future.delayed(const Duration(milliseconds: 100));
        continue;
      }
      final maxScroll = _scrollController.position.maxScrollExtent;
      if (maxScroll <= 0) {
        await Future.delayed(const Duration(milliseconds: 200));
        continue;
      }

      final duration = Duration(
          milliseconds: (maxScroll * 35 / widget.speedMultiplier).toInt());
      await _scrollController.animateTo(
        maxScroll,
        duration: duration,
        curve: Curves.linear,
      );
      if (!mounted) return;
      _scrollController.jumpTo(0.0);
    }
  }

  @override
  void dispose() {
    _scrolling = false;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        border: Border.all(color: AppColors.navy, width: 2),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          children: [
            Text(
              '${widget.text}   •   ${widget.text}   •   ${widget.text}   •   ${widget.text}   ',
              style: TextStyle(
                fontFamily: 'PressStart2P',
                fontFamilyFallback: const ['monospace'],
                fontSize: 12,
                color: widget.textColor,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBadgeButton extends StatelessWidget {
  const _IconBadgeButton({
    required this.icon,
    required this.onTap,
    this.count = 0,
  });

  final IconData icon;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.navy, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.navy,
                  offset: Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.navy, size: 22),
          ),
        ),
        if (count > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.navy, width: 1.5),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _OppItem {
  const _OppItem({
    required this.creator,
    required this.title,
    required this.tags,
    required this.logoColor,
    required this.logoText,
  });

  final String creator;
  final String title;
  final String tags;
  final Color logoColor;
  final String logoText;
}

// Mocks removed

String _profileHandle(UserModel user) {
  final localPart = user.email.split('@').first;
  final normalized = localPart
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9_]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  return '@${normalized.isEmpty ? user.id.substring(0, 6) : normalized}';
}

String _formatDate(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  final local = value.toLocal();
  return '${months[local.month - 1]} ${local.day}';
}

String _timeOnly(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final suffix = local.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}
