import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/neo_button.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/project_providers.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  ConsumerState<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _linkController = TextEditingController();
  
  String _type = 'team';
  String _visibility = 'public';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Start a Project',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.lg),
          children: [
            _buildFieldLabel('Project Title'),
            _buildTextField(_titleController, 'e.g. Solar Powered Car', true),
            const SizedBox(height: AppSizes.md),
            
            _buildFieldLabel('Description'),
            _buildTextField(_descController, 'What are you building?', true, maxLines: 4),
            const SizedBox(height: AppSizes.md),

            _buildFieldLabel('Project Type'),
            _buildDropdown<String>(
              value: _type,
              items: ['personal', 'team', 'club', 'research', 'hackathon'],
              onChanged: (val) => setState(() => _type = val!),
            ),
            const SizedBox(height: AppSizes.md),

            _buildFieldLabel('Visibility'),
            _buildDropdown<String>(
              value: _visibility,
              items: ['public', 'private'],
              onChanged: (val) => setState(() => _visibility = val!),
            ),
            const SizedBox(height: AppSizes.md),

            _buildFieldLabel('External Link (Optional)'),
            _buildTextField(_linkController, 'WhatsApp/GitHub/Discord URL', false),
            
            const SizedBox(height: AppSizes.xl),
            NeoButton(
              label: 'Launch Project',
              isLoading: _isLoading,
              onPressed: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.bold,
          color: AppColors.navy,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, bool required, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.navy, width: 2),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.all(12),
          border: InputBorder.none,
        ),
        validator: required ? (v) => v?.isEmpty ?? true ? 'Required' : null : null,
      ),
    );
  }

  Widget _buildDropdown<T>({required T value, required List<T> items, required ValueChanged<T?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.navy, width: 2),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i.toString().toUpperCase(), style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.bold)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final project = await ref.read(projectRepositoryProvider).createProject({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'project_type': _type,
        'visibility': _visibility,
        'external_link': _linkController.text.trim().isEmpty ? null : _linkController.text.trim(),
        'created_by': user.id,
      });

      ref.invalidate(publicProjectsProvider);
      ref.invalidate(userProjectsProvider);

      if (mounted) {
        context.pushReplacement('/projects/${project.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to launch project: $e'), backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
