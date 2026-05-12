import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grow/core/constants/app_colors.dart';
import 'package:grow/core/constants/app_sizes.dart';
import 'package:grow/core/utils/app_logger.dart';
import 'package:grow/core/utils/supabase_error_handler.dart';
import 'package:grow/shared/models/tool_model.dart';
import 'package:grow/shared/models/booking_model.dart';
import 'package:grow/shared/widgets/neo_card.dart';
import 'package:grow/shared/widgets/neo_button.dart';
import 'package:grow/shared/widgets/neo_text_field.dart';
import 'package:grow/shared/widgets/neo_chip.dart';
import 'package:grow/features/lab/domain/lab_providers.dart';
import 'package:grow/features/lab/domain/tool_providers.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/admin/presentation/widgets/maintenance_update_sheet.dart';
import 'package:grow/shared/repositories/supabase_client.dart';

final pendingBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final data = await supabase
      .from('tool_bookings')
      .select('*, tools(name), users(name)')
      .eq('status', 'requested')
      .order('created_at', ascending: false);
  return (data as List).map((row) => BookingModel.fromJson(row)).toList();
});

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.navy,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.yellow,
          indicatorWeight: 4,
          labelStyle: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'OVERVIEW'),
            Tab(text: 'EQUIPMENT'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _OverviewTab(),
          _EquipmentTab(),
        ],
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingBookingsProvider);
    final activeSessionsAsync = ref.watch(liveLabVisitorCountProvider);
    final toolsAsync = ref.watch(toolsProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSizes.lg),
      children: [
        _buildStatCards(pendingAsync, activeSessionsAsync, toolsAsync),
        const SizedBox(height: AppSizes.xl),
        Row(
          children: [
            Text(
              'Pending Approvals',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            pendingAsync.maybeWhen(
              data: (b) => b.isNotEmpty
                  ? CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.red,
                      child: Text(
                        b.length.toString(),
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.md),
        pendingAsync.when(
          data: (bookings) {
            if (bookings.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.xl),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: AppColors.green, size: 48),
                      const SizedBox(height: AppSizes.md),
                      Text(
                        'No pending approvals',
                        style:
                            GoogleFonts.dmSans(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children:
                  bookings.map((b) => _PendingBookingCard(booking: b)).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, __) => Text('Error: $e'),
        ),
      ],
    );
  }

  Widget _buildStatCards(
    AsyncValue<List<BookingModel>> pending,
    AsyncValue<int> active,
    AsyncValue<List<ToolModel>> tools,
  ) {
    return Row(
      children: [
        _QuickStatCard(
          label: 'Pending',
          value: pending.maybeWhen(
            data: (d) => d.length.toString(),
            orElse: () => '...',
          ),
          color: AppColors.yellow,
        ),
        const SizedBox(width: AppSizes.md),
        _QuickStatCard(
          label: 'In Lab',
          value: active.maybeWhen(
            data: (d) => d.toString(),
            orElse: () => '...',
          ),
          color: AppColors.green,
        ),
        const SizedBox(width: AppSizes.md),
        _QuickStatCard(
          label: 'Total Tools',
          value: tools.maybeWhen(
            data: (d) => d.length.toString(),
            orElse: () => '...',
          ),
          color: AppColors.cobalt,
          textColor: Colors.white,
        ),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.label,
    required this.value,
    required this.color,
    this.textColor,
  });
  final String label;
  final String value;
  final Color color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: NeoCard(
        color: color,
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor ?? AppColors.navy,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: (textColor ?? AppColors.navy).withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingBookingCard extends ConsumerWidget {
  const _PendingBookingCard({required this.booking});
  final BookingModel booking;

  Future<void> _handleReject(BuildContext context, WidgetRef ref) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Booking'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Enter rejection reason (optional)',
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, reasonController.text),
            child: const Text('Reject', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );

    if (reason == null) return;

    try {
      await supabase.from('tool_bookings').update({
        'status': 'rejected',
        'rejection_reason': reason.trim(),
      }).eq('id', booking.id);

      AppLogger.action(LogCategory.admin, 'BOOKING_REJECTED', {
        'bookingId': booking.id,
        'reason': reason,
      });

      ref.invalidate(pendingBookingsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Booking rejected'),
              backgroundColor: AppColors.navy),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(handleSupabaseError(e)),
              backgroundColor: AppColors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: NeoCard(
        color: Colors.white,
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.toolName ?? 'Unknown Tool',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'By: ${booking.userName ?? 'Unknown User'}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  booking.slotStart.toLocal().toString().substring(5, 16),
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                Expanded(
                  child: NeoButton(
                    label: 'Reject',
                    color: Colors.white,
                    textColor: AppColors.red,
                    onPressed: () => _handleReject(context, ref),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: NeoButton(
                    label: 'Approve',
                    color: AppColors.green,
                    onPressed: () async {
                      final actor = ref.read(currentUserProvider).value;
                      if (actor == null) return;
                      await ref
                          .read(toolRepositoryProvider)
                          .approveBooking(booking.id, actor);
                      ref.invalidate(pendingBookingsProvider);

                      AppLogger.action(LogCategory.admin, 'BOOKING_APPROVED', {
                        'bookingId': booking.id,
                        'toolId': booking.toolId,
                      });
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Booking approved'),
                              backgroundColor: AppColors.green),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EquipmentTab extends ConsumerWidget {
  const _EquipmentTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolsAsync = ref.watch(toolsProvider);

    return Column(
      children: [
        _buildAlertSection(ref),
        Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: NeoButton(
            label: 'Add Tool',
            icon: Icons.add_rounded,
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => const _AddToolSheet(),
            ),
          ),
        ),
        Expanded(
          child: toolsAsync.when(
            data: (tools) => ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              itemCount: tools.length,
              itemBuilder: (context, index) =>
                  _ToolAdminCard(tool: tools[index]),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, __) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertSection(WidgetRef ref) {
    final toolsAsync = ref.watch(toolsProvider);
    return toolsAsync.maybeWhen(
      data: (tools) {
        final needingRepair = tools
            .where(
              (t) =>
                  t.healthStatus == 'maintenance' ||
                  t.healthStatus == 'retired',
            )
            .toList();
        if (needingRepair.isEmpty) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(
              top: AppSizes.lg, left: AppSizes.lg, right: AppSizes.lg),
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.red.withValues(alpha: 0.1),
            border: Border.all(color: AppColors.red, width: 2),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.red),
              const SizedBox(width: AppSizes.md),
              Text(
                '${needingRepair.length} items need attention',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  color: AppColors.red,
                ),
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _ToolAdminCard extends ConsumerWidget {
  const _ToolAdminCard({required this.tool});
  final ToolModel tool;

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case '3d_printer':
        return AppColors.cobalt;
      case 'laser':
        return AppColors.red;
      case 'electronics':
        return AppColors.green;
      case 'fabrication':
        return AppColors.orange;
      case 'woodwork':
        return AppColors.yellow;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getCategoryLabel(String cat) {
    switch (cat) {
      case '3d_printer':
        return '3D Printer';
      case 'laser':
        return 'Laser Cutter';
      case 'electronics':
        return 'Electronics';
      case 'fabrication':
        return 'Fabrication';
      case 'woodwork':
        return 'Woodwork';
      default:
        return 'Other';
    }
  }

  Color _getHealthColor(String status) {
    switch (status) {
      case 'available':
        return AppColors.green;
      case 'maintenance':
        return AppColors.orange;
      case 'retired':
        return AppColors.textSecondary;
      case 'in_use':
      case 'booked':
        return AppColors.cobalt;
      default:
        return AppColors.navy;
    }
  }

  Future<void> _handleRetire(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Retire Tool?'),
        content: const Text(
            'This will mark the tool as retired and prevent any future bookings. Past records will be kept.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Retire', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await supabase.from('tools').update({
        'health_status': 'retired',
      }).eq('id', tool.id);

      AppLogger.action(LogCategory.admin, 'TOOL_RETIRED', {'toolId': tool.id});
      ref.invalidate(toolsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tool retired successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(handleSupabaseError(e)),
              backgroundColor: AppColors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: NeoCard(
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tool.name,
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      NeoChip(
                        label: _getCategoryLabel(tool.category),
                        color: _getCategoryColor(tool.category),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      Text(
                        '${tool.availableQty} / ${tool.totalQty} available',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      NeoChip(
                        label: tool.healthStatus.toUpperCase(),
                        color: _getHealthColor(tool.healthStatus),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (val) {
                if (val == 'edit') {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => _EditToolSheet(tool: tool),
                  );
                } else if (val == 'status') {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => MaintenanceUpdateSheet(tool: tool),
                  );
                } else if (val == 'retire') {
                  _handleRetire(context, ref);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit Details'),
                ),
                const PopupMenuItem(
                  value: 'status',
                  child: Text('Update Status'),
                ),
                const PopupMenuItem(
                  value: 'retire',
                  child: Text('Retire Tool',
                      style: TextStyle(color: AppColors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddToolSheet extends ConsumerStatefulWidget {
  const _AddToolSheet();
  @override
  ConsumerState<_AddToolSheet> createState() => _AddToolSheetState();
}

class _AddToolSheetState extends ConsumerState<_AddToolSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  final _sopController = TextEditingController();
  String _category = 'other';
  bool _requiresApproval = false;
  bool _isLoading = false;

  final _categories = const {
    '3d_printer': '3D Printer',
    'laser': 'Laser Cutter',
    'electronics': 'Electronics',
    'fabrication': 'Fabrication',
    'woodwork': 'Woodwork',
    'other': 'Other',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _qtyController.dispose();
    _sopController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final qty = int.tryParse(_qtyController.text) ?? 1;

      final insertData = {
        'name': _nameController.text.trim(),
        'category': _category,
        'description': _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        'total_qty': qty,
        'available_qty': qty,
        'health_status': 'available',
        'sop_url': _sopController.text.trim().isEmpty
            ? null
            : _sopController.text.trim(),
      };

      await supabase.from('tools').insert(insertData);

      AppLogger.info(LogCategory.admin,
          'TOOL_CREATED | name=${insertData['name']} requiresApproval=$_requiresApproval');

      ref.invalidate(toolsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tool added successfully'),
              backgroundColor: AppColors.green),
        );
        Navigator.pop(context);
      }
    } catch (e, st) {
      AppLogger.error(LogCategory.admin, 'TOOL_CREATE_FAILED',
          error: e, stack: st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(handleSupabaseError(e)),
              backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
      ),
      padding: EdgeInsets.only(
        left: AppSizes.lg,
        right: AppSizes.lg,
        top: AppSizes.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.lg,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add Tool',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              NeoTextField(
                label: 'Tool Name',
                controller: _nameController,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSizes.md),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.entries.map((e) {
                  return DropdownMenuItem(value: e.key, child: Text(e.value));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
              const SizedBox(height: AppSizes.md),
              NeoTextField(
                label: 'Description (Optional)',
                controller: _descController,
                maxLines: 3,
              ),
              const SizedBox(height: AppSizes.md),
              NeoTextField(
                label: 'Total Quantity',
                controller: _qtyController,
                keyboardType: TextInputType.number,
                validator: (val) {
                  final n = int.tryParse(val ?? '');
                  if (n == null || n < 1) return 'Must be >= 1';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),
              NeoTextField(
                label: 'SOP URL (Optional)',
                controller: _sopController,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: AppSizes.md),
              SwitchListTile(
                title: const Text('Requires admin approval to book'),
                subtitle:
                    const Text('Enable for high-value tools (laser, CNC)'),
                value: _requiresApproval,
                onChanged: (val) => setState(() => _requiresApproval = val),
              ),
              const SizedBox(height: AppSizes.xl),
              NeoButton(
                label: 'Save Tool',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditToolSheet extends ConsumerStatefulWidget {
  const _EditToolSheet({required this.tool});
  final ToolModel tool;

  @override
  ConsumerState<_EditToolSheet> createState() => _EditToolSheetState();
}

class _EditToolSheetState extends ConsumerState<_EditToolSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _sopController;
  late String _category;
  bool _isLoading = false;

  final _categories = const {
    '3d_printer': '3D Printer',
    'laser': 'Laser Cutter',
    'electronics': 'Electronics',
    'fabrication': 'Fabrication',
    'woodwork': 'Woodwork',
    'other': 'Other',
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tool.name);
    _descController =
        TextEditingController(text: widget.tool.description ?? '');
    _sopController = TextEditingController(text: widget.tool.sopUrl ?? '');
    _category = _categories.containsKey(widget.tool.category)
        ? widget.tool.category
        : 'other';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _sopController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final updateData = {
        'name': _nameController.text.trim(),
        'category': _category,
        'description': _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        'sop_url': _sopController.text.trim().isEmpty
            ? null
            : _sopController.text.trim(),
      };

      await supabase.from('tools').update(updateData).eq('id', widget.tool.id);

      ref.invalidate(toolsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tool updated successfully'),
              backgroundColor: AppColors.green),
        );
        Navigator.pop(context);
      }
    } catch (e, st) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(handleSupabaseError(e)),
              backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
      ),
      padding: EdgeInsets.only(
        left: AppSizes.lg,
        right: AppSizes.lg,
        top: AppSizes.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.lg,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit Details',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              NeoTextField(
                label: 'Tool Name',
                controller: _nameController,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSizes.md),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.entries.map((e) {
                  return DropdownMenuItem(value: e.key, child: Text(e.value));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
              const SizedBox(height: AppSizes.md),
              NeoTextField(
                label: 'Description',
                controller: _descController,
                maxLines: 3,
              ),
              const SizedBox(height: AppSizes.md),
              NeoTextField(
                label: 'SOP URL',
                controller: _sopController,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: AppSizes.xl),
              NeoButton(
                label: 'Save Details',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
