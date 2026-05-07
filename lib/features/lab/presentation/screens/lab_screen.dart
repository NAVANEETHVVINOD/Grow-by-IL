import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/supabase_error_handler.dart';
import '../../../../shared/widgets/neo_button.dart';
import '../../../../shared/widgets/neo_card.dart';
import '../../../../shared/widgets/neo_chip.dart';
import '../../../../shared/widgets/shimmer_skeleton.dart';
import '../../../auth/data/auth_repository.dart';
import '../../domain/lab_providers.dart';

/// State to prevent double-tap check-in/check-out
final _isCheckingInProvider = StateProvider.autoDispose<bool>((ref) => false);

class LabScreen extends ConsumerWidget {
  const LabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeSessionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: activeSession.when(
          data: (session) {
            if (session != null && session.checkinTime != null) {
              return _CheckedInView(sessionId: session.id, checkinTime: session.checkinTime!, purpose: session.purpose);
            }
            return const _NotCheckedInView();
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
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
                  onPressed: () => ref.invalidate(activeSessionProvider),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STATE A: Not checked in
// ═══════════════════════════════════════════════════════════════
class _NotCheckedInView extends ConsumerWidget {
  const _NotCheckedInView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(activeSessionProvider);
        ref.invalidate(liveLabVisitorCountProvider);
        ref.invalidate(mySessionHistoryProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        children: [
          _buildHeader(),
          const SizedBox(height: AppSizes.xl),
          _buildLiveCountCard(ref),
          const SizedBox(height: AppSizes.xl),
          _buildCheckInButton(context, ref),
          const SizedBox(height: AppSizes.xxl),
          _buildLabHours(),
          const SizedBox(height: AppSizes.xxl),
          _buildSessionHistory(ref),
          const SizedBox(height: AppSizes.xxl),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.science_rounded, size: 28, color: AppColors.navy),
        const SizedBox(width: AppSizes.sm),
        Text(
          'Grow~',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
      ],
    );
  }

  Widget _buildLiveCountCard(WidgetRef ref) {
    final countAsync = ref.watch(liveLabVisitorCountProvider);

    return NeoCard(
      color: Colors.white,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                child: Row(
                  children: [
                    const _PulsingDot(),
                    const SizedBox(width: AppSizes.sm),
                    countAsync.when(
                      data: (count) => Text(
                        '$count people in the lab right now',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      loading: () => const ShimmerSkeleton(width: 180, height: 18),
                      error: (err, stack) => Text(
                        'Unable to load count',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInButton(BuildContext context, WidgetRef ref) {
    return NeoButton(
      label: 'Check In',
      icon: Icons.login_rounded,
      onPressed: () => _handleCheckIn(context, ref),
    );
  }

  Future<void> _handleCheckIn(BuildContext context, WidgetRef ref) async {
    if (kIsWeb) {
      _showWebCheckInDialog(context, ref);
    } else {
      await _doCheckIn(context, ref, 'General visit');
    }
  }

  void _showWebCheckInDialog(BuildContext context, WidgetRef ref) {
    String purpose = 'General visit';
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Check-in (Web)', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Check-in on web is for testing. Select purpose:',
                style: GoogleFonts.dmSans(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSizes.md),
              StatefulBuilder(
                builder: (context, setDialogState) {
                  return DropdownButtonFormField<String>(
                    initialValue: purpose,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: const BorderSide(color: AppColors.navy, width: 2),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'General visit', child: Text('General visit')),
                      DropdownMenuItem(value: 'Project work', child: Text('Project work')),
                      DropdownMenuItem(value: '3D Printing', child: Text('3D Printing')),
                      DropdownMenuItem(value: 'Electronics', child: Text('Electronics')),
                      DropdownMenuItem(value: 'Woodwork', child: Text('Woodwork')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() { purpose = val; });
                      }
                    },
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            NeoButton(
              label: 'Check In',
              width: 120,
              height: 40,
              onPressed: () {
                Navigator.pop(ctx);
                _doCheckIn(context, ref, purpose);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _doCheckIn(BuildContext context, WidgetRef ref, String purpose) async {
    // Guard against double-tap
    if (ref.read(_isCheckingInProvider)) return;
    ref.read(_isCheckingInProvider.notifier).state = true;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) {
      ref.read(_isCheckingInProvider.notifier).state = false;
      return;
    }

    try {
      final repo = ref.read(labRepositoryProvider);
      await repo.checkIn(user.id, purpose);
      ref.invalidate(activeSessionProvider);
      ref.invalidate(liveLabVisitorCountProvider);
      ref.invalidate(mySessionHistoryProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Checked in! Have a great session.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(handleSupabaseError(e)),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      ref.read(_isCheckingInProvider.notifier).state = false;
    }
  }

  Widget _buildLabHours() {
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
          "Who's Here",
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        const Spacer(),
        Text(
          'Lab hours: 9 AM \u2013 6 PM, Mon\u2013Sat',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionHistory(WidgetRef ref) {
    return _SessionHistorySection();
  }
}

// ═══════════════════════════════════════════════════════════════
// STATE B: Checked in
// ═══════════════════════════════════════════════════════════════
class _CheckedInView extends ConsumerWidget {
  const _CheckedInView({
    required this.sessionId,
    required this.checkinTime,
    this.purpose,
  });

  final String sessionId;
  final DateTime checkinTime;
  final String? purpose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(activeSessionProvider);
        ref.invalidate(mySessionHistoryProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        children: [
          Row(
            children: [
              const Icon(Icons.science_rounded, size: 28, color: AppColors.navy),
              const SizedBox(width: AppSizes.sm),
              Text(
                'Grow~',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xl),

          // Status card
          NeoCard(
            color: AppColors.yellow,
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: AppColors.green, size: 32),
                    const SizedBox(width: AppSizes.md),
                    Text(
                      "You're checked in",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),
                _SessionTimer(checkinTime: checkinTime),
                if (purpose != null) ...[
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    purpose!,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSizes.xl),

          // Check-out button
          NeoButton(
            label: 'Check Out',
            icon: Icons.logout_rounded,
            color: AppColors.surface,
            textColor: AppColors.red,
            borderColor: AppColors.red,
            onPressed: () => _handleCheckOut(context, ref),
          ),
          const SizedBox(height: AppSizes.xl),

          // Quick access
          Row(
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
                'Quick Access',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: NeoCard(
                  color: Colors.white,
                  padding: const EdgeInsets.all(AppSizes.md),
                  onTap: () => context.push('/tools'),
                  child: Column(
                    children: [
                      const Icon(Icons.build_rounded, size: 28, color: AppColors.cobalt),
                      const SizedBox(height: AppSizes.sm),
                      Text(
                        'Book a Tool',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: NeoCard(
                  color: Colors.white,
                  padding: const EdgeInsets.all(AppSizes.md),
                  onTap: () => _showReportIssueSheet(context),
                  child: Column(
                    children: [
                      const Icon(Icons.report_outlined, size: 28, color: AppColors.orange),
                      const SizedBox(height: AppSizes.sm),
                      Text(
                        'Report Issue',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xxl),

          // Session history
          _SessionHistorySection(),
          const SizedBox(height: AppSizes.xxl),
        ],
      ),
    );
  }

  Future<void> _handleCheckOut(BuildContext context, WidgetRef ref) async {
    // Guard against double-tap
    if (ref.read(_isCheckingInProvider)) return;
    ref.read(_isCheckingInProvider.notifier).state = true;

    try {
      final repo = ref.read(labRepositoryProvider);
      await repo.checkOut(sessionId);
      ref.invalidate(activeSessionProvider);
      ref.invalidate(liveLabVisitorCountProvider);
      ref.invalidate(mySessionHistoryProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Checked out. Session logged.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(handleSupabaseError(e)),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      ref.read(_isCheckingInProvider.notifier).state = false;
    }
  }

  void _showReportIssueSheet(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: AppSizes.lg,
            right: AppSizes.lg,
            top: AppSizes.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Report an Issue',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe the issue...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: const BorderSide(color: AppColors.navy, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              NeoButton(
                label: 'Submit',
                onPressed: () {
                  AppLogger.action(LogCategory.LAB, 'Issue reported', {'issue': controller.text});
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Issue reported. Thank you!')),
                  );
                },
              ),
              const SizedBox(height: AppSizes.lg),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Shared widgets
// ═══════════════════════════════════════════════════════════════

/// Pulsing green dot indicator.
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.3, end: 1.0).animate(_controller),
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: AppColors.green,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Live session timer that ticks every second.
class _SessionTimer extends StatefulWidget {
  const _SessionTimer({required this.checkinTime});
  final DateTime checkinTime;

  @override
  State<_SessionTimer> createState() => _SessionTimerState();
}

class _SessionTimerState extends State<_SessionTimer> {
  late Timer _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateElapsed();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateElapsed();
    });
  }

  void _updateElapsed() {
    setState(() {
      _elapsed = DateTime.now().difference(widget.checkinTime);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _elapsed.inHours.toString().padLeft(2, '0');
    final minutes = (_elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');

    return Text(
      '$hours:$minutes:$seconds',
      style: GoogleFonts.spaceGrotesk(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.navy,
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// Session history list, shared between both states.
class _SessionHistorySection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(mySessionHistoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
              'My Sessions',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        historyAsync.when(
          data: (sessions) {
            if (sessions.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.xl),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.history, size: 40, color: AppColors.textSecondary),
                      const SizedBox(height: AppSizes.sm),
                      Text(
                        'No sessions yet. Check in to get started.',
                        style: GoogleFonts.dmSans(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sessions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final session = sessions[index];
                final checkin = session.checkinTime;
                final checkout = session.checkoutTime;

                final dateStr = checkin != null
                    ? DateFormat('EEE, d MMM').format(checkin)
                    : '--';
                final timeIn = checkin != null
                    ? DateFormat('h:mm a').format(checkin)
                    : '--';
                final timeOut = checkout != null
                    ? DateFormat('h:mm a').format(checkout)
                    : null;

                String durationStr = '';
                if (session.duration != null) {
                  final d = session.duration!;
                  if (d.inHours > 0) {
                    durationStr = '${d.inHours}h ${d.inMinutes % 60}m';
                  } else {
                    durationStr = '${d.inMinutes}m';
                  }
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateStr,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              timeOut != null
                                  ? '$timeIn \u2013 $timeOut'
                                  : timeIn,
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (session.isActive)
                        const NeoChip(label: 'Active', color: AppColors.green)
                      else
                        Text(
                          durationStr,
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.navy,
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => Column(
            children: List.generate(
              3,
              (i) => const Padding(
                padding: EdgeInsets.only(bottom: AppSizes.sm),
                child: ShimmerSkeleton(width: double.infinity, height: 48),
              ),
            ),
          ),
          error: (err, stack) => const Center(
            child: Text('Failed to load sessions'),
          ),
        ),
      ],
    );
  }
}
