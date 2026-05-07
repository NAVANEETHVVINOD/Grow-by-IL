import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/models/event_model.dart';
import '../../../../shared/widgets/neo_button.dart';
import '../../../../shared/widgets/neo_card.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/event_providers.dart';

class EventDetailsScreen extends ConsumerStatefulWidget {
  const EventDetailsScreen({super.key, required this.eventId});
  final String eventId;

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailProvider(widget.eventId));
    final rsvpAsync = ref.watch(userRsvpProvider(widget.eventId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: eventAsync.when(
        data: (event) => CustomScrollView(
          slivers: [
            _buildSliverAppBar(event),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(event),
                    const SizedBox(height: AppSizes.lg),
                    _buildInfoGrid(event),
                    const SizedBox(height: AppSizes.lg),
                    _buildDescription(event),
                    const SizedBox(height: 100), // Space for fab
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      bottomSheet: eventAsync.when(
        data: (event) => _buildActionButton(event, rsvpAsync.valueOrNull),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildSliverAppBar(EventModel event) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: AppColors.navy,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: event.imageUrl != null
            ? Image.network(event.imageUrl!, fit: BoxFit.cover)
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.navy.withOpacity(0.8), AppColors.navy],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.event_rounded, size: 80, color: AppColors.yellow),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(EventModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.yellow,
                border: Border.all(color: AppColors.navy, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                event.type.toUpperCase(),
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.navy,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            if (event.organizationName != null)
              Expanded(
                child: Text(
                  'by ${event.organizationName}',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        Text(
          event.title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(EventModel event) {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            icon: Icons.calendar_today_rounded,
            title: 'Date',
            subtitle: DateFormat('EEE, MMM d').format(event.startTime),
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: _InfoCard(
            icon: Icons.access_time_rounded,
            title: 'Time',
            subtitle: DateFormat('h:mm a').format(event.startTime),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(EventModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About the Event',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        Text(
          event.description ?? 'No description provided.',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSizes.lg),
        NeoCard(
          color: Colors.white,
          child: Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.navy),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: AppColors.navy),
                    ),
                    Text(
                      event.locationName ?? 'IdeaLab Main Room',
                      style: GoogleFonts.dmSans(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(EventModel event, dynamic rsvp) {
    final isGoing = rsvp?.status == 'going';
    final isFull = event.isFull;

    String label;
    Color color = AppColors.yellow;
    VoidCallback? onPressed;

    if (isGoing) {
      label = 'You are Going';
      color = AppColors.green;
      onPressed = _handleCancelRsvp;
    } else if (isFull) {
      label = 'Event Full';
      color = Colors.grey.shade300;
      onPressed = null;
    } else {
      label = 'RSVP Now';
      color = AppColors.yellow;
      onPressed = _handleRsvp;
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.navy, width: 2)),
      ),
      child: NeoButton(
        label: _isLoading ? 'Processing...' : label,
        onPressed: _isLoading ? null : onPressed,
        color: color,
        isLoading: _isLoading,
      ),
    );
  }

  Future<void> _handleRsvp() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(eventRepositoryProvider).rsvpToEvent(widget.eventId, user.id);
      ref.invalidate(userRsvpProvider(widget.eventId));
      ref.invalidate(eventDetailProvider(widget.eventId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('RSVP Confirmed!'), backgroundColor: AppColors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCancelRsvp() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel RSVP?'),
        content: const Text('Are you sure you want to cancel your spot?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes, Cancel')),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(eventRepositoryProvider).cancelRsvp(widget.eventId, user.id);
      ref.invalidate(userRsvpProvider(widget.eventId));
      ref.invalidate(eventDetailProvider(widget.eventId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      color: Colors.white,
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.navy, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary),
          ),
          Text(
            subtitle,
            style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.navy),
          ),
        ],
      ),
    );
  }
}
