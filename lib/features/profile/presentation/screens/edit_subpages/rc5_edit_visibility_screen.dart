import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/profile/domain/rc5_profile_providers.dart';
import 'package:grow/shared/widgets/rc5/rc5_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

      _isPublic = prefs.getBool('$key.visibility_public') ?? true;
      _hideSocial = prefs.getBool('$key.visibility_hide_social') ?? false;
      _hideActivity = prefs.getBool('$key.visibility_hide_activity') ?? false;
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveData() async {
    setState(() => _isSaving = true);
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      final key = 'rc5_onboarding.${user.id}';

      await prefs.setBool('$key.visibility_public', _isPublic);
      await prefs.setBool('$key.visibility_hide_social', _hideSocial);
      await prefs.setBool('$key.visibility_hide_activity', _hideActivity);

      ref.invalidate(rc5ProfileHeaderProvider);
    }
    setState(() => _isSaving = false);
    if (mounted) Navigator.of(context).pop();
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
