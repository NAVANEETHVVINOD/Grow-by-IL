import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:grow/core/constants/app_colors.dart';
import 'package:grow/core/constants/app_sizes.dart';
import 'package:grow/shared/models/tool_model.dart';
import 'package:grow/shared/widgets/neo_button.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/lab/domain/tool_providers.dart';
import 'package:grow/features/projects/domain/project_providers.dart';

class BookingBottomSheet extends ConsumerStatefulWidget {
  const BookingBottomSheet({super.key, required this.tool});

  final ToolModel tool;

  @override
  ConsumerState<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends ConsumerState<BookingBottomSheet> {
  late DateTime _selectedDate;
  int _selectedDurationMinutes = 60;
  DateTime? _selectedStartTime;
  String? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(userProjectsProvider);
    final bookingsAsync = ref.watch(
      toolBookingsForDayProvider((toolId: widget.tool.id, date: _selectedDate)),
    );

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLg),
        ),
        border: Border(top: BorderSide(color: AppColors.navy, width: 3)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSizes.lg),
              _buildSectionTitle('Select Date'),
              const SizedBox(height: AppSizes.sm),
              _buildDateSelector(),
              const SizedBox(height: AppSizes.lg),
              _buildSectionTitle('Duration'),
              const SizedBox(height: AppSizes.sm),
              _buildDurationSelector(),
              const SizedBox(height: AppSizes.lg),
              _buildSectionTitle('Available Slots'),
              const SizedBox(height: AppSizes.sm),
              bookingsAsync.when(
                data: (bookings) => _buildTimeSlotPicker(bookings),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text('Error: $e'),
              ),
              const SizedBox(height: AppSizes.lg),
              _buildSectionTitle('Link to Project (Optional)'),
              const SizedBox(height: AppSizes.sm),
              projectsAsync.when(
                data: (projects) => _buildProjectDropdown(projects),
                loading: () => const SizedBox.shrink(),
                error: (e, st) => const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSizes.xl),
              NeoButton(
                label: widget.tool.requiresApproval
                    ? 'Request Booking'
                    : 'Book Now',
                isLoading: _isLoading,
                onPressed: _selectedStartTime == null ? null : _handleBooking,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.tool.name,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
              Text(
                widget.tool.category.toUpperCase().replaceAll('_', ' '),
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (widget.tool.imageUrl != null)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.navy, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(widget.tool.imageUrl!, fit: BoxFit.cover),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.navy,
      ),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSizes.sm),
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = DateFormat('yyyy-MM-dd').format(date) ==
              DateFormat('yyyy-MM-dd').format(_selectedDate);

          return GestureDetector(
            onTap: () => setState(() {
              _selectedDate = date;
              _selectedStartTime = null;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.yellow : Colors.white,
                border: Border.all(color: AppColors.navy, width: 2),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date),
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected ? AppColors.navy : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    DateFormat('d').format(date),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDurationSelector() {
    final options = [
      {'label': '1 hr', 'value': 60},
      {'label': '2 hrs', 'value': 120},
      {'label': '3 hrs', 'value': 180},
      {'label': 'Full Day', 'value': 480},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: options.map((opt) {
        final isSelected = _selectedDurationMinutes == opt['value'];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedDurationMinutes = opt['value'] as int;
                _selectedStartTime = null;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.cobalt : Colors.white,
                  border: Border.all(color: AppColors.navy, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  opt['label'] as String,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isSelected ? Colors.white : AppColors.navy,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeSlotPicker(List<dynamic> bookings) {
    final slots = <DateTime>[];
    // Lab Hours: 9 AM to 6 PM
    var current = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      9,
      0,
    );
    final endLimit = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      18,
      0,
    );

    while (current.isBefore(endLimit)) {
      // Don't show slots in the past for today
      if (current.isAfter(DateTime.now().add(const Duration(minutes: 15)))) {
        slots.add(current);
      }
      current = current.add(const Duration(minutes: 30));
    }

    if (slots.isEmpty) {
      return Center(
        child: Text(
          'No slots available for this day.',
          style: GoogleFonts.dmSans(color: AppColors.textSecondary),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((slot) {
        final slotEnd = slot.add(Duration(minutes: _selectedDurationMinutes));

        // Conflict check
        final isConflict = bookings.any((b) {
              return slot.isBefore(b.slotEnd) && slotEnd.isAfter(b.slotStart);
            }) ||
            slotEnd.isAfter(endLimit);

        final isSelected = _selectedStartTime == slot;

        return GestureDetector(
          onTap: isConflict
              ? null
              : () => setState(() => _selectedStartTime = slot),
          child: Opacity(
            opacity: isConflict ? 0.4 : 1.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.yellow
                    : (isConflict ? Colors.grey.shade200 : Colors.white),
                border: Border.all(
                  color: isSelected ? AppColors.navy : Colors.grey.shade300,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                DateFormat('h:mm a').format(slot),
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: AppColors.navy,
                  decoration: isConflict ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProjectDropdown(List<dynamic> projects) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.navy, width: 2),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedProjectId,
          isExpanded: true,
          hint: Text(
            'Select a project...',
            style: GoogleFonts.dmSans(fontSize: 14),
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('Personal Booking'),
            ),
            ...projects.map(
              (p) => DropdownMenuItem(
                value: p.id as String,
                child: Text(p.title as String),
              ),
            ),
          ],
          onChanged: (val) => setState(() => _selectedProjectId = val),
        ),
      ),
    );
  }

  bool _isLoading = false;

  Future<void> _handleBooking() async {
    if (_selectedStartTime == null || _isLoading) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final slotEnd = _selectedStartTime!.add(
        Duration(minutes: _selectedDurationMinutes),
      );

      await ref.read(toolRepositoryProvider).createBooking(
            toolId: widget.tool.id,
            userId: user.id,
            slotStart: _selectedStartTime!.toUtc(),
            slotEnd: slotEnd.toUtc(),
            projectId: _selectedProjectId,
          );

      // Invalidate providers to refresh UI
      ref.invalidate(myBookingsProvider);
      ref.invalidate(toolBookingsForDayProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.tool.requiresApproval
                ? 'Booking requested! Waiting for approval.'
                : 'Tool booked successfully!',
          ),
          backgroundColor: AppColors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create booking: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }
}
