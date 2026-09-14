import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/profile/data/profile_ecosystem_repository.dart';
import 'package:grow/features/profile/domain/rc5_profile_providers.dart';
import 'package:grow/shared/models/profile_ecosystem_models.dart';
import 'package:grow/shared/repositories/supabase_client.dart';
import 'package:grow/shared/widgets/rc5/rc5_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

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

  String? _existingEducationId;
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
      final repo = ref.read(profileEcosystemRepositoryProvider);

      // Pre-fill KTU ID from user model if available
      _ktuIdController.text = user.collegeRoll ?? '';

      try {
        final serverEdu = await repo.getEducation(user.id);
        if (serverEdu.isNotEmpty) {
          final mainEdu = serverEdu.first;
          _collegeController.text = mainEdu.institution;
          _departmentController.text = mainEdu.degree;
          _yearController.text = mainEdu.endYear?.toString() ?? '';
          _existingEducationId = mainEdu.id;
        } else {
          // If server is empty, fallback to local SharedPreferences onboarding draft
          final prefs = await SharedPreferences.getInstance();
          final key = 'rc5_onboarding.${user.id}';
          _collegeController.text = prefs.getString('$key.edu_college') ?? '';
          final eduDept = prefs.getString('$key.edu_department') ?? '';
          if (eduDept.isNotEmpty) {
            _departmentController.text = eduDept;
          } else {
            _departmentController.text =
                prefs.getString('$key.department') ?? '';
          }
          _yearController.text = prefs.getString('$key.edu_year') ?? '';
          if (_ktuIdController.text.isEmpty) {
            _ktuIdController.text = prefs.getString('$key.edu_ktuid') ?? '';
          }
        }
      } catch (e) {
        // Network/error fallback to SharedPreferences
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
        if (_ktuIdController.text.isEmpty) {
          _ktuIdController.text = prefs.getString('$key.edu_ktuid') ?? '';
        }
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveData() async {
    setState(() => _isSaving = true);
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user != null) {
      final repo = ref.read(profileEcosystemRepositoryProvider);

      final eduItem = UserEducationModel(
        id: _existingEducationId ?? const Uuid().v4(),
        userId: user.id,
        institution: _collegeController.text.trim(),
        degree: _departmentController.text.trim(),
        endYear: int.tryParse(_yearController.text.trim()),
        isCurrent: true,
      );

      try {
        // Write to Supabase
        await repo.addEducation(eduItem);

        // Sync KTU ID to users table if modified
        final newKtuId = _ktuIdController.text.trim();
        if (newKtuId != (user.collegeRoll ?? '')) {
          await supabase.from('users').update({
            'college_roll': newKtuId.isNotEmpty ? newKtuId : null,
          }).eq('id', user.id);
        }

        // Save locally to SharedPreferences onboarding draft
        final prefs = await SharedPreferences.getInstance();
        final key = 'rc5_onboarding.${user.id}';
        await prefs.setString(
            '$key.edu_college', _collegeController.text.trim());
        await prefs.setString(
            '$key.edu_department', _departmentController.text.trim());
        await prefs.setString('$key.edu_year', _yearController.text.trim());
        await prefs.setString('$key.edu_ktuid', _ktuIdController.text.trim());
        if (_departmentController.text.trim().isNotEmpty) {
          await prefs.setString(
              '$key.department', _departmentController.text.trim());
        }

        ref.invalidate(rc5ProfileHeaderProvider);
        ref.invalidate(currentUserProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Education updated successfully!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        }
      } on OfflineQueueException catch (e) {
        // Cache locally on offline queue exception
        final prefs = await SharedPreferences.getInstance();
        final key = 'rc5_onboarding.${user.id}';
        await prefs.setString(
            '$key.edu_college', _collegeController.text.trim());
        await prefs.setString(
            '$key.edu_department', _departmentController.text.trim());
        await prefs.setString('$key.edu_year', _yearController.text.trim());
        await prefs.setString('$key.edu_ktuid', _ktuIdController.text.trim());
        if (_departmentController.text.trim().isNotEmpty) {
          await prefs.setString(
              '$key.department', _departmentController.text.trim());
        }

        ref.invalidate(rc5ProfileHeaderProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              behavior: SnackBarBehavior.floating,
              backgroundColor: RC5DesignTokens.ink,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save changes: $e'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: RC5DesignTokens.error,
            ),
          );
        }
      }
    }
    setState(() => _isSaving = false);
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
