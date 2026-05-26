import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/profile/data/profile_ecosystem_repository.dart';
import 'package:grow/features/profile/domain/rc5_profile_providers.dart';
import 'package:grow/shared/models/profile_ecosystem_models.dart';
import 'package:grow/shared/widgets/rc5/rc5_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class RC5EditBasicProfileScreen extends ConsumerStatefulWidget {
  const RC5EditBasicProfileScreen({super.key});

  @override
  ConsumerState<RC5EditBasicProfileScreen> createState() =>
      _RC5EditBasicProfileScreenState();
}

class _RC5EditBasicProfileScreenState
    extends ConsumerState<RC5EditBasicProfileScreen> {
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _departmentController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final headerData = await ref.read(rc5ProfileHeaderProvider.future);
    if (headerData != null) {
      _usernameController.text = headerData.username;
      _bioController.text = headerData.bio;
      _departmentController.text = headerData.departmentOrRole;
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveData() async {
    setState(() => _isSaving = true);
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user != null) {
      final repo = ref.read(profileEcosystemRepositoryProvider);

      final profileModel = UserProfileModel(
        id: const Uuid().v4(),
        userId: user.id,
        username: _usernameController.text.trim(),
        bio: _bioController.text.trim(),
        department: _departmentController.text.trim(),
      );

      try {
        await repo.upsertProfile(profileModel);

        final prefs = await SharedPreferences.getInstance();
        final key = 'rc5_onboarding.${user.id}';
        await prefs.setString('$key.username', _usernameController.text.trim());
        await prefs.setString('$key.bio', _bioController.text.trim());
        await prefs.setString(
            '$key.department', _departmentController.text.trim());

        ref.invalidate(rc5ProfileHeaderProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        }
      } on OfflineQueueException catch (e) {
        final prefs = await SharedPreferences.getInstance();
        final key = 'rc5_onboarding.${user.id}';
        await prefs.setString('$key.username', _usernameController.text.trim());
        await prefs.setString('$key.bio', _bioController.text.trim());
        await prefs.setString(
            '$key.department', _departmentController.text.trim());

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
    _usernameController.dispose();
    _bioController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: RC5DesignTokens.background,
      appBar: AppBar(title: const Text('Basic Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Username', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'e.g. maker_john',
            ),
          ),
          const SizedBox(height: RC5DesignTokens.space4),
          const Text('Bio', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _bioController,
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Tell the community about yourself',
            ),
          ),
          const SizedBox(height: RC5DesignTokens.space4),
          const Text('Department / Role',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _departmentController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'e.g. Computer Science / UI Designer',
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
