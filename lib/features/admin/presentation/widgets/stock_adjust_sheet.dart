import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grow/core/constants/app_colors.dart';
import 'package:grow/core/constants/app_sizes.dart';
import 'package:grow/shared/models/inventory_item_model.dart';
import 'package:grow/shared/widgets/neo_button.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/admin/domain/inventory_providers.dart';

class StockAdjustSheet extends ConsumerStatefulWidget {
  const StockAdjustSheet({super.key, required this.item});
  final InventoryItemModel item;

  @override
  ConsumerState<StockAdjustSheet> createState() => _StockAdjustSheetState();
}

class _StockAdjustSheetState extends ConsumerState<StockAdjustSheet> {
  final _notesController = TextEditingController();
  int _change = 1;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.lg,
        top: AppSizes.lg,
        left: AppSizes.lg,
        right: AppSizes.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Adjust Stock: ${widget.item.name}',
            style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy),
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAdjustButton(Icons.remove, () => setState(() => _change--)),
              const SizedBox(width: AppSizes.xl),
              Text(
                _change > 0 ? '+$_change' : '$_change',
                style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.bold, color: _change >= 0 ? AppColors.green : AppColors.red),
              ),
              const SizedBox(width: AppSizes.xl),
              _buildAdjustButton(Icons.add, () => setState(() => _change++)),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          _buildTextField(_notesController, 'Notes (optional)'),
          const SizedBox(height: AppSizes.xl),
          NeoButton(
            label: 'Confirm Adjustment',
            isLoading: _isLoading,
            onPressed: _handleSubmit,
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.navy, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.navy),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.navy, width: 2),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.all(12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(inventoryRepositoryProvider).adjustStock(
        itemId: widget.item.id,
        userId: user.id,
        change: _change,
        transactionType: _change >= 0 ? 'stock_in' : 'stock_out',
        notes: _notesController.text.trim(),
      );
      
      ref.invalidate(inventoryItemsProvider(null));
      ref.invalidate(lowStockItemsProvider);
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to adjust stock: $e'), backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
