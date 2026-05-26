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

class RC5EditVisibilityScreen extends ConsumerStatefulWidget {
  const RC5EditVisibilityScreen({super.key});

  @override
  ConsumerState<RC5EditVisibilityScreen> createState() =>
      _RC5EditVisibilityScreenState();
}

class _RC5EditVisibilityScreenState
    extends ConsumerState<RC5EditVisibilityScreen> {
  bool _isPublic = true;
  bool _hideSocial = false;
  bool _hideActivity = false;

  UserProfileModel? _profile;
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
      try {
        _profile = await repo.getProfile(user.id);
        if (_profile != null) {
          _isPublic = _profile!.isPublic;
          _hideActivity = !_profile!.showStats;
        } else {
          final prefs = await SharedPreferences.getInstance();
          final key = 'rc5_onboarding.${user.id}';
          _isPublic = prefs.getBool('$key.visibility_public') ?? true;
          _hideActivity =
              prefs.getBool('$key.visibility_hide_activity') ?? false;
        }
      } catch (e) {
        final prefs = await SharedPreferences.getInstance();
        final key = 'rc5_onboarding.${user.id}';
        _isPublic = prefs.getBool('$key.visibility_public') ?? true;
        _hideActivity = prefs.getBool('$key.visibility_hide_activity') ?? false;
      }

      final prefs = await SharedPreferences.getInstance();
      final key = 'rc5_onboarding.${user.id}';
      _hideSocial = prefs.getBool('$key.visibility_hide_social') ?? false;
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveData() async {
    setState(() => _isSaving = true);
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user != null) {
      final repo = ref.read(profileEcosystemRepositoryProvider);

      final profile = _profile?.copyWith(
            isPublic: _isPublic,
            showStats: !_hideActivity,
          ) ??
          UserProfileModel(
            id: const Uuid().v4(),
            userId: user.id,
            isPublic: _isPublic,
            showStats: !_hideActivity,
          );

      try {
        // Write to Supabase
        await repo.upsertProfile(profile);

        // Cache locally in SharedPreferences onboarding draft
        final prefs = await SharedPreferences.getInstance();
        final key = 'rc5_onboarding.${user.id}';
        await prefs.setBool('$key.visibility_public', _isPublic);
        await prefs.setBool('$key.visibility_hide_social', _hideSocial);
        await prefs.setBool('$key.visibility_hide_activity', _hideActivity);

        ref.invalidate(rc5ProfileHeaderProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Visibility settings updated successfully!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        }
      } on OfflineQueueException catch (e) {
        // Cache locally on offline queue exception
        final prefs = await SharedPreferences.getInstance();
        final key = 'rc5_onboarding.${user.id}';
        await prefs.setBool('$key.visibility_public', _isPublic);
        await prefs.setBool('$key.visibility_hide_social', _hideSocial);
        await prefs.setBool('$key.visibility_hide_activity', _hideActivity);

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
              content: Text('Failed to save settings: $e'),
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
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: RC5DesignTokens.background,
      appBar: AppBar(title: const Text('Profile Visibility')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Control what the community sees.',
            style:
                TextStyle(fontSize: 16, color: RC5DesignTokens.textSecondary),
          ),
          const SizedBox(height: RC5DesignTokens.space4),
          SwitchListTile(
            title: const Text('Public Profile',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text(
                'Allow other Grow~ users to view your profile and portfolio.'),
            value: _isPublic,
            activeThumbColor: RC5DesignTokens.ink,
            onChanged: (val) => setState(() => _isPublic = val),
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Hide Social Links',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text(
                'Hide your LinkedIn, GitHub, and portfolio website from others.'),
            value: _hideSocial,
            activeThumbColor: RC5DesignTokens.ink,
            onChanged:
                _isPublic ? (val) => setState(() => _hideSocial = val) : null,
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Hide Activity History',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text(
                'Keep your event participation and lab check-ins private.'),
            value: _hideActivity,
            activeThumbColor: RC5DesignTokens.ink,
            onChanged:
                _isPublic ? (val) => setState(() => _hideActivity = val) : null,
            contentPadding: EdgeInsets.zero,
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
