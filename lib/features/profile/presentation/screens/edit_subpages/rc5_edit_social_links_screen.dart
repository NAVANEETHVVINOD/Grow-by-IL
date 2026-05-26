import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/profile/domain/rc5_profile_providers.dart';
import 'package:grow/shared/widgets/rc5/rc5_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RC5EditSocialLinksScreen extends ConsumerStatefulWidget {
  const RC5EditSocialLinksScreen({super.key});

  @override
  ConsumerState<RC5EditSocialLinksScreen> createState() =>
      _RC5EditSocialLinksScreenState();
}

class _RC5EditSocialLinksScreenState
    extends ConsumerState<RC5EditSocialLinksScreen> {
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _websiteController = TextEditingController();

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

      _githubController.text = prefs.getString('$key.social_github') ?? '';
      _linkedinController.text = prefs.getString('$key.social_linkedin') ?? '';
      _websiteController.text = prefs.getString('$key.social_website') ?? '';
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveData() async {
    setState(() => _isSaving = true);
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      final key = 'rc5_onboarding.${user.id}';

      await prefs.setString(
          '$key.social_github', _githubController.text.trim());
      await prefs.setString(
          '$key.social_linkedin', _linkedinController.text.trim());
      await prefs.setString(
          '$key.social_website', _websiteController.text.trim());

      ref.invalidate(rc5ProfileHeaderProvider);
    }
    setState(() => _isSaving = false);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _githubController.dispose();
    _linkedinController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: RC5DesignTokens.background,
      appBar: AppBar(title: const Text('Social Links')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('GitHub Username',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _githubController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'e.g. kannan',
              prefixText: 'github.com/',
            ),
          ),
          const SizedBox(height: RC5DesignTokens.space4),
          const Text('LinkedIn Profile',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _linkedinController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'e.g. in/kannan',
            ),
          ),
          const SizedBox(height: RC5DesignTokens.space4),
          const Text('Portfolio Website',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _websiteController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'e.g. https://myportfolio.com',
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
