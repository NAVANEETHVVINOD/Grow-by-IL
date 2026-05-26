import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';
import 'package:grow/features/explore/domain/event_providers.dart';
import 'package:grow/features/lab/domain/lab_providers.dart';
import 'package:grow/features/lab/domain/tool_providers.dart';
import 'package:grow/shared/models/booking_model.dart';
import 'package:grow/shared/models/event_model.dart';
import 'package:grow/shared/widgets/neo_card.dart';
import 'package:grow/shared/widgets/rc5/rc5_widgets.dart';

class AkathalamScreen extends ConsumerWidget {
  const AkathalamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitorCount = ref.watch(liveLabVisitorCountProvider);
    final activeSession = ref.watch(activeSessionProvider);
    final activeBooking = ref.watch(activeBookingProvider);
    final events = ref.watch(activeEventsProvider);

    return Scaffold(
      backgroundColor: RC5DesignTokens.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 140),
          children: [
            Row(
              children: [
                const RC5GrowLogo(size: 36),
                const SizedBox(width: 12),
                Text(
                  'അകത്തളം',
                  style: RC5DesignTokens.hero,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const _FacilityStatusChips(),
            const SizedBox(height: 16),
            Text(
              'The living IDEA Lab space. Breathable, slower, and focused on making.',
              style: RC5DesignTokens.body.copyWith(
                color: RC5DesignTokens.textSecondary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 36),
            _LiveStatusCards(
              visitorCount: visitorCount,
              booking: activeBooking,
            ),
            const SizedBox(height: 24),
            _CheckInCard(isCheckedIn: activeSession.valueOrNull != null),
            const SizedBox(height: 40),
            _UpcomingEvents(events: events),
            const SizedBox(height: 40),
            const _InstitutionalSection(),
          ],
        ),
      ),
    );
  }
}

class _FacilityStatusChips extends StatelessWidget {
  const _FacilityStatusChips();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatusChip(
          icon: Icons.wifi_rounded,
          label: 'Wi-Fi: Active',
          color: const Color(0xFFDDF5D7), // Soft Green
        ),
        const SizedBox(width: 12),
        _StatusChip(
          icon: Icons.power_rounded,
          label: 'Power: Stable',
          color: const Color(0xFFDDF5D7), // Soft Green
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF111111), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF111111)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstitutionalSection extends StatelessWidget {
  const _InstitutionalSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Institution', style: RC5DesignTokens.sectionTitle),
        const SizedBox(height: 16),
        _EditorialItem(
          title: 'About IDEA Lab',
          subtitle: 'Our mission, vision, and history',
          icon: Icons.auto_stories_rounded,
          color: const Color(0xFFDFF4FF),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('About IDEA Lab coming soon'))),
        ),
        _EditorialItem(
          title: 'Faculty & Mentors',
          subtitle: 'The minds guiding the lab',
          icon: Icons.people_alt_rounded,
          color: const Color(0xFFF7EEB4),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faculty Directory coming soon'))),
        ),
        _EditorialItem(
          title: 'Facilities & Zones',
          subtitle: 'Equipment areas and floor plan',
          icon: Icons.map_rounded,
          color: const Color(0xFFE5E7EB),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Facilities coming soon'))),
        ),
        _EditorialItem(
          title: 'Lab Rules & Safety',
          subtitle: 'Guidelines for a safe workspace',
          icon: Icons.rule_rounded,
          color: const Color(0xFFFFD6D6),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lab Rules coming soon'))),
        ),
        _EditorialItem(
          title: 'Contact',
          subtitle: 'Reach out to the core team',
          icon: Icons.contact_support_rounded,
          color: const Color(0xFFE5E7EB),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact details coming soon'))),
        ),
      ],
    );
  }
}

class _EditorialItem extends StatelessWidget {
  const _EditorialItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeoCard(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF111111), width: 1.5),
              ),
              child: Icon(icon, color: const Color(0xFF111111), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: RC5DesignTokens.cardTitle),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: RC5DesignTokens.body.copyWith(
                      color: const Color(0xFF71717A),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: Color(0xFF111111), size: 16),
          ],
        ),
      ),
    );
  }
}

class _LiveStatusCards extends StatelessWidget {
  const _LiveStatusCards({
    required this.visitorCount,
    required this.booking,
  });

  final AsyncValue<int> visitorCount;
  final AsyncValue<BookingModel?> booking;

  @override
  Widget build(BuildContext context) {
    final activeBooking = booking.valueOrNull;

    return Row(
      children: [
        Expanded(
          child: NeoCard(
            color: const Color(0xFFDDF5D7), // Soft Green
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.groups_outlined, color: Color(0xFF111111), size: 24),
                const SizedBox(height: 16),
                Text(
                  visitorCount.maybeWhen(
                    data: (count) => '$count Active',
                    orElse: () => '--',
                  ),
                  style: RC5DesignTokens.cardTitle,
                ),
                const SizedBox(height: 4),
                Text(
                  'Makers in lab now',
                  style: RC5DesignTokens.body.copyWith(
                    color: const Color(0xFF71717A),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: NeoCard(
            color: const Color(0xFFDFF4FF), // Soft Blue
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.construction_outlined, color: Color(0xFF111111), size: 24),
                const SizedBox(height: 16),
                Text(
                  activeBooking == null ? 'No Booking' : (activeBooking.toolName ?? 'Active'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RC5DesignTokens.cardTitle,
                ),
                const SizedBox(height: 4),
                Text(
                  activeBooking == null
                      ? 'No active tool reservation'
                      : 'Expires ${_timeOnly(activeBooking.slotEnd)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RC5DesignTokens.body.copyWith(
                    color: const Color(0xFF71717A),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckInCard extends StatelessWidget {
  const _CheckInCard({required this.isCheckedIn});

  final bool isCheckedIn;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      color: isCheckedIn ? const Color(0xFFDDF5D7) : Colors.white, // Soft Green or White
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCheckedIn ? 'ACTIVE SESSION' : 'CHECK-IN REQUIRED',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isCheckedIn ? const Color(0xFF111111) : const Color(0xFF71717A),
              letterSpacing: 1.0,
          ),
          ),
          const SizedBox(height: 12),
          Text(
            isCheckedIn ? 'You are checked in to the IDEA Lab.' : 'Access the Creative Space',
            style: RC5DesignTokens.cardTitle,
          ),
          const SizedBox(height: 8),
          Text(
            isCheckedIn
                ? 'Your session is active. Remember to check out when you leave the lab.'
                : 'Scan the Lab QR code to start a session and reserve tools.',
            style: RC5DesignTokens.body.copyWith(color: const Color(0xFF71717A)),
          ),
          const SizedBox(height: 24),
          RC5Button(
            label: isCheckedIn ? 'Check Out' : 'Scan QR to Check In',
            icon: isCheckedIn ? Icons.logout_rounded : Icons.qr_code_scanner_rounded,
            variant: isCheckedIn ? RC5ButtonVariant.destructive : RC5ButtonVariant.secondary,
            fullWidth: true,
            onPressed: () => context.push('/lab/scan'),
          ),
        ],
      ),
    );
  }
}

class _UpcomingEvents extends StatelessWidget {
  const _UpcomingEvents({required this.events});

  final AsyncValue<List<EventModel>> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Upcoming Events',
                style: RC5DesignTokens.sectionTitle,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/events'),
              child: Text(
                'View all',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111111),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        events.when(
          data: (items) {
            final eventList = items.where((event) => !event.isPast).take(3).toList();
            if (eventList.isEmpty) {
              return const NeoCard(
                color: Colors.white,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No events queued right now.',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF71717A)),
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: eventList.map((event) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: NeoCard(
                    onTap: () => context.push('/events/${event.id}'),
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB), // Soft Gray
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF111111), width: 1.5),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_outlined,
                            color: Color(0xFF111111),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: RC5DesignTokens.cardTitle,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                event.venue ?? 'IDEA Lab',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: RC5DesignTokens.body.copyWith(
                                  color: const Color(0xFF71717A),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_rounded, color: Color(0xFF111111), size: 18),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const RC5SkeletonList(itemCount: 3, itemHeight: 78),
          error: (_, __) => const NeoCard(
            color: Colors.white,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('Events could not load.', style: TextStyle(fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _timeOnly(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final suffix = local.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}
