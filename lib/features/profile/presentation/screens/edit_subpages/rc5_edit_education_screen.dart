import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/profile/domain/rc5_profile_providers.dart';
import 'package:grow/shared/widgets/rc5/rc5_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RC5EditEducationScreen extends ConsumerStatefulWidget {
  const RC5EditEducationScreen({super.key});

  @override
  ConsumerState<RC5EditEducationScreen> createState() =>
      _RC5EditEducationScreenState();
}

class _RC5EditEducationScreenState
    extends ConsumerState<RC5EditEducationScreen> {
  final _collegeController = TextEditingController();
  final _departmentController = TextEditingController();
  final _yearController = TextEditingController();
  final _ktuIdController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      final key = 'rc5_onboarding.${user.id}';

      _collegeController.text = prefs.getString('$key.edu_college') ?? '';

      final eduDept = prefs.getString('$key.edu_department') ?? '';
      if (eduDept.isNotEmpty) {
        _departmentController.text = eduDept;
      } else {
        _departmentController.text = prefs.getString('$key.department') ?? '';
      }

      _yearController.text = prefs.getString('$key.edu_year') ?? '';
      _ktuIdController.text = prefs.getString('$key.edu_ktuid') ?? '';
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveData() async {
    setState(() => _isSaving = true);
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      final key = 'rc5_onboarding.${user.id}';

      await prefs.setString('$key.edu_college', _collegeController.text.trim());
      await prefs.setString(
          '$key.edu_department', _departmentController.text.trim());
      await prefs.setString('$key.edu_year', _yearController.text.trim());
      await prefs.setString('$key.edu_ktuid', _ktuIdController.text.trim());

      if (_departmentController.text.trim().isNotEmpty) {
        await prefs.setString(
            '$key.department', _departmentController.text.trim());
      }

      ref.invalidate(rc5ProfileHeaderProvider);
    }
    setState(() => _isSaving = false);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _collegeController.dispose();
    _departmentController.dispose();
    _yearController.dispose();
    _ktuIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: RC5DesignTokens.background,
      appBar: AppBar(title: const Text('Education')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('College / University',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _collegeController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'e.g. Model Engineering College',
            ),
          ),
          const SizedBox(height: RC5DesignTokens.space4),
          const Text('Department / Degree',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _departmentController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'e.g. B.Tech Computer Science',
            ),
          ),
          const SizedBox(height: RC5DesignTokens.space4),
          const Text('Graduation Year / Batch',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _yearController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'e.g. 2026',
            ),
          ),
          const SizedBox(height: RC5DesignTokens.space4),
          const Text('KTU ID (Optional)',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _ktuIdController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'e.g. MDL19CS001',
            ),
          ),
          const SizedBox(height: RC5DesignTokens.space5),
          RC5Button(
            label: _isSaving ? 'Saving...' : 'Save Changes',
            onPressed: _isSaving ? null : _saveData,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
