import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grow/core/constants/app_colors.dart';
import 'package:grow/core/constants/app_sizes.dart';
import 'package:grow/shared/widgets/neo_card.dart';
import 'package:grow/shared/widgets/neo_button.dart';
import 'package:grow/shared/widgets/shimmer_skeleton.dart';
import 'package:grow/features/lab/domain/tool_providers.dart';
import 'package:grow/features/lab/presentation/widgets/booking_bottom_sheet.dart';
import 'package:grow/shared/models/tool_model.dart';

class ToolsScreen extends ConsumerWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toolsAsync = ref.watch(toolsProvider);
    final selectedTool = ref.watch(selectedToolProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.navy),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Book a Tool',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Search & Filters
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: AppSizes.md),
                      _buildFilterChips(
                        ref,
                        ref.watch(toolCategoryFilterProvider),
                      ),
                    ],
                  ),
                ),
              ),

              // Tool Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                sliver: toolsAsync.when(
                  data: (tools) {
                    if (tools.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.build_outlined,
                                size: 64,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: AppSizes.md),
                              Text(
                                'No tools found in this category',
                                style: GoogleFonts.dmSans(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: AppSizes.md,
                            crossAxisSpacing: AppSizes.md,
                            childAspectRatio: 0.75,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final tool = tools[index];
                        final isSelected = selectedTool?.id == tool.id;
                        return _ToolCard(
                          tool: tool,
                          isSelected: isSelected,
                          onTap: () =>
                              ref.read(selectedToolProvider.notifier).state =
                                  tool,
                        );
                      }, childCount: tools.length),
                    );
                  },
                  loading: () => SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppSizes.md,
                          crossAxisSpacing: AppSizes.md,
                          childAspectRatio: 0.75,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const ShimmerSkeleton(
                        width: double.infinity,
                        height: 200,
                      ),
                      childCount: 4,
                    ),
                  ),
                  error: (e, st) => SliverFillRemaining(
                    child: Center(child: Text('Error: $e')),
                  ),
                ),
              ),

              // Bottom padding for floating button
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // Confirm Booking Floating Button
          if (selectedTool != null)
            Positioned(
              bottom: AppSizes.lg,
              left: AppSizes.lg,
              right: AppSizes.lg,
              child: NeoButton(
                label: 'Confirm Booking',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) =>
                        BookingBottomSheet(tool: selectedTool),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.navy, width: 2),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search tools...',
          hintStyle: GoogleFonts.dmSans(color: AppColors.textSecondary),
          icon: const Icon(Icons.search_rounded, color: AppColors.navy),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFilterChips(WidgetRef ref, String selected) {
    final categories = [
      'All',
      '3D Printer',
      'Laser',
      'Electronics',
      'Woodwork',
      'Fabrication',
    ];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSizes.sm),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selected;
          return GestureDetector(
            onTap: () =>
                ref.read(toolCategoryFilterProvider.notifier).state = category,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.yellow : Colors.white,
                border: Border.all(
                  color: isSelected ? AppColors.navy : Colors.grey.shade300,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.navy,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.tool,
    required this.isSelected,
    required this.onTap,
  });

  final ToolModel tool;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeoCard(
        color: Colors.white,
        padding: const EdgeInsets.all(AppSizes.sm),
        borderColor: isSelected ? AppColors.yellow : AppColors.navy,
        borderWidth: isSelected ? 3 : 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.navy.withValues(alpha: 0.1),
                  ),
                ),
                child: tool.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(tool.imageUrl!, fit: BoxFit.cover),
                      )
                    : const Icon(
                        Icons.build_rounded,
                        size: 40,
                        color: AppColors.navy,
                      ),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              tool.name,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            _buildStatusChip(tool.healthStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'available':
        color = AppColors.green;
        label = 'Available';
        break;
      case 'maintenance':
        color = AppColors.orange;
        label = 'Maintenance';
        break;
      default:
        color = AppColors.red;
        label = 'Out of Order';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
