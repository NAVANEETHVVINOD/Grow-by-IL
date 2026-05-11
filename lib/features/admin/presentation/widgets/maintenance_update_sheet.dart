import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grow/core/constants/app_colors.dart';
import 'package:grow/core/constants/app_sizes.dart';
import 'package:grow/core/utils/app_logger.dart';
import 'package:grow/shared/models/tool_model.dart';
import 'package:grow/shared/widgets/neo_button.dart';
import 'package:grow/shared/repositories/supabase_client.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/lab/domain/tool_providers.dart';

class MaintenanceUpdateSheet extends ConsumerStatefulWidget {
  const MaintenanceUpdateSheet({super.key, required this.tool});
  final ToolModel tool;

  @override
  ConsumerState<MaintenanceUpdateSheet> createState() =>
      _MaintenanceUpdateSheetState();
}

class _MaintenanceUpdateSheetState
    extends ConsumerState<MaintenanceUpdateSheet> {
  final _notesController = TextEditingController();
  late String _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _status = widget.tool.healthStatus;
  }

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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Update Status: ${widget.tool.name}',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          _buildDropdown(),
          const SizedBox(height: AppSizes.lg),
          _buildTextField(
            _notesController,
            'Describe the maintenance or issue...',
          ),
          const SizedBox(height: AppSizes.xl),
          NeoButton(
            label: 'Save Status',
            isLoading: _isLoading,
            onPressed: _handleSubmit,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.navy, width: 2),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _status,
          items: ['available', 'booked', 'in_use', 'maintenance', 'retired']
              .map(
                (s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())),
              )
              .toList(),
          onChanged: (val) => setState(() => _status = val!),
        ),
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
        maxLines: 3,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.all(12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      // Update tool health_status directly in tools table
      final updateData = <String, dynamic>{
        'health_status': _status,
      };

      // Set last_maintained timestamp when marking as available after maintenance
      if (_status == 'available' || _status == 'maintenance') {
        updateData['last_maintained'] =
            DateTime.now().toUtc().toIso8601String();
      }

      await supabase
          .from('tools')
          .update(updateData)
          .eq('id', widget.tool.id);

      AppLogger.action(LogCategory.tools, 'TOOL_STATUS_UPDATED', {
        'toolId': widget.tool.id,
        'oldStatus': widget.tool.healthStatus,
        'newStatus': _status,
        'actorId': user.id,
      });

      // Refresh tools list
      ref.invalidate(toolsProvider);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      AppLogger.error(
        LogCategory.tools,
        'TOOL_STATUS_UPDATE_FAILED',
        error: e,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
