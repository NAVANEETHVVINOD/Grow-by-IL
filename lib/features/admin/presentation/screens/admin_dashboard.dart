import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/models/inventory_item_model.dart';
import '../../../../shared/models/tool_model.dart';
import '../../../../shared/models/booking_model.dart';
import '../../../../shared/widgets/neo_card.dart';
import '../../../../shared/widgets/neo_button.dart';
import '../../../../shared/widgets/shimmer_skeleton.dart';
import '../../../lab/domain/lab_providers.dart';
import '../../../lab/domain/tool_providers.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/inventory_providers.dart';
import '../widgets/maintenance_update_sheet.dart';
import '../widgets/stock_adjust_sheet.dart';

final pendingBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final repo = ref.watch(toolRepositoryProvider);
  final data = await repo.client
      .from('tool_bookings')
      .select('*, tools(name), users(full_name)')
      .eq('status', 'pending')
      .order('created_at', ascending: false);
  return (data as List).map((row) => BookingModel.fromJson(row)).toList();
});

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.navy),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.navy,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.yellow,
          indicatorWeight: 4,
          labelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'OVERVIEW'),
            Tab(text: 'EQUIPMENT'),
            Tab(text: 'INVENTORY'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _OverviewTab(),
          const _EquipmentTab(),
          const _InventoryTab(),
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
        Text('Pending Approvals', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy)),
        const SizedBox(height: AppSizes.md),
        pendingAsync.when(
          data: (bookings) {
            if (bookings.isEmpty) return const Center(child: Text('No pending bookings.'));
            return Column(
              children: bookings.map((b) => _PendingBookingCard(booking: b)).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, __) => Text('Error: $e'),
        ),
      ],
    );
  }

  Widget _buildStatCards(AsyncValue<List<BookingModel>> pending, AsyncValue<int> active, AsyncValue<List<ToolModel>> tools) {
    return Row(
      children: [
        _QuickStatCard(
          label: 'Pending',
          value: pending.maybeWhen(data: (d) => d.length.toString(), orElse: () => '...'),
          color: AppColors.yellow,
        ),
        const SizedBox(width: AppSizes.md),
        _QuickStatCard(
          label: 'In Lab',
          value: active.maybeWhen(data: (d) => d.toString(), orElse: () => '...'),
          color: AppColors.green,
        ),
        const SizedBox(width: AppSizes.md),
        _QuickStatCard(
          label: 'Total Tools',
          value: tools.maybeWhen(data: (d) => d.length.toString(), orElse: () => '...'),
          color: AppColors.cobalt,
          textColor: Colors.white,
        ),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({required this.label, required this.value, required this.color, this.textColor});
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
            Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.bold, color: textColor ?? AppColors.navy)),
            Text(label, style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.bold, color: (textColor ?? AppColors.navy).withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}

class _PendingBookingCard extends ConsumerWidget {
  const _PendingBookingCard({required this.booking});
  final BookingModel booking;

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
                      Text(booking.toolName ?? 'Unknown Tool', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('By: ${booking.userName ?? 'Unknown User'}', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Text(
                  '${booking.slotStart.toLocal().toString().substring(5, 16)}',
                  style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                Expanded(
                  child: NeoButton(
                    label: 'Approve',
                    onPressed: () async {
                      final actor = ref.read(currentUserProvider).valueOrNull;
                      if (actor == null) return;
                      await ref.read(toolRepositoryProvider).approveBooking(booking.id, actor);
                      ref.invalidate(pendingBookingsProvider);
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
        Expanded(
          child: toolsAsync.when(
            data: (tools) => ListView.builder(
              padding: const EdgeInsets.all(AppSizes.lg),
              itemCount: tools.length,
              itemBuilder: (context, index) => _ToolAdminCard(tool: tools[index]),
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
        final needingRepair = tools.where((t) => t.healthStatus == 'maintenance' || t.healthStatus == 'broken').toList();
        if (needingRepair.isEmpty) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(AppSizes.lg),
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(color: AppColors.red.withOpacity(0.1), border: Border.all(color: AppColors.red, width: 2), borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.red),
              const SizedBox(width: AppSizes.md),
              Text('${needingRepair.length} items need attention', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: AppColors.red)),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _InventoryTab extends ConsumerWidget {
  const _InventoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(inventoryItemsProvider(null));

    return Column(
      children: [
        _buildLowStockSection(ref),
        Expanded(
          child: itemsAsync.when(
            data: (items) => ListView.builder(
              padding: const EdgeInsets.all(AppSizes.lg),
              itemCount: items.length,
              itemBuilder: (context, index) => _ItemAdminCard(item: items[index]),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, __) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildLowStockSection(WidgetRef ref) {
    final lowStockAsync = ref.watch(lowStockItemsProvider);
    return lowStockAsync.maybeWhen(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.all(AppSizes.lg),
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(color: AppColors.orange.withOpacity(0.1), border: Border.all(color: AppColors.orange, width: 2), borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
          child: Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: AppColors.orange),
              const SizedBox(width: AppSizes.md),
              Text('${items.length} items running low', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: AppColors.orange)),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _ToolAdminCard extends StatelessWidget {
  const _ToolAdminCard({required this.tool});
  final ToolModel tool;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: NeoCard(
        color: Colors.white,
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.navy, width: 1.5)),
              child: const Icon(Icons.build_circle_outlined, color: AppColors.navy),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tool.name, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(tool.healthStatus.toUpperCase(), style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: tool.healthStatus == 'available' ? AppColors.green : AppColors.red)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_note_rounded),
              onPressed: () {
                showModalBottomSheet(context: context, isScrollControlled: true, builder: (context) => MaintenanceUpdateSheet(tool: tool));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemAdminCard extends StatelessWidget {
  const _ItemAdminCard({required this.item});
  final InventoryItemModel item;

  @override
  Widget build(BuildContext context) {
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
                  Text(item.name, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('Stock: ${item.quantity} ${item.unit}', style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: item.isLowStock ? AppColors.red : AppColors.textSecondary)),
                      if (item.storageLocation != null) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(item.storageLocation!, style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.cobalt),
              onPressed: () {
                showModalBottomSheet(context: context, isScrollControlled: true, builder: (context) => StockAdjustSheet(item: item));
              },
            ),
          ],
        ),
      ),
    );
  }
}
