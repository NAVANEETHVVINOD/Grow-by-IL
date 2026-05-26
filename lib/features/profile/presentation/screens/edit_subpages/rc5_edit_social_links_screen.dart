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

  String _cleanGithubUsername(String url) {
    if (url.isEmpty) return '';
    var cleaned = url;
    cleaned = cleaned.replaceFirst('https://github.com/', '');
    cleaned = cleaned.replaceFirst('http://github.com/', '');
    cleaned = cleaned.replaceFirst('github.com/', '');
    return cleaned;
  }

  Future<void> _loadData() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user != null) {
      final repo = ref.read(profileEcosystemRepositoryProvider);

      try {
        final serverLinks = await repo.getSocialLinks(user.id);
        
        final github = serverLinks.firstWhere((l) => l.platform == 'github', orElse: () => const UserSocialLinkModel(id: '', userId: '', platform: 'github', url: '')).url;
        final linkedin = serverLinks.firstWhere((l) => l.platform == 'linkedin', orElse: () => const UserSocialLinkModel(id: '', userId: '', platform: 'linkedin', url: '')).url;
        final website = serverLinks.firstWhere((l) => l.platform == 'website', orElse: () => const UserSocialLinkModel(id: '', userId: '', platform: 'website', url: '')).url;

        _githubController.text = _cleanGithubUsername(github);
        _linkedinController.text = linkedin;
        _websiteController.text = website;

        if (github.isEmpty && linkedin.isEmpty && website.isEmpty) {
          final prefs = await SharedPreferences.getInstance();
          final key = 'rc5_onboarding.${user.id}';
          _githubController.text = prefs.getString('$key.social_github') ?? '';
          _linkedinController.text = prefs.getString('$key.social_linkedin') ?? '';
          _websiteController.text = prefs.getString('$key.social_website') ?? '';
        }
      } catch (e) {
        final prefs = await SharedPreferences.getInstance();
        final key = 'rc5_onboarding.${user.id}';
        _githubController.text = prefs.getString('$key.social_github') ?? '';
        _linkedinController.text = prefs.getString('$key.social_linkedin') ?? '';
        _websiteController.text = prefs.getString('$key.social_website') ?? '';
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveData() async {
    setState(() => _isSaving = true);
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user != null) {
      final repo = ref.read(profileEcosystemRepositoryProvider);

      final ghVal = _githubController.text.trim();
      final githubUrl = ghVal.isNotEmpty
          ? (ghVal.startsWith('http') ? ghVal : 'https://github.com/$ghVal')
          : '';

      final liVal = _linkedinController.text.trim();
      final linkedinUrl = liVal.isNotEmpty
          ? (liVal.startsWith('http') ? liVal : (liVal.startsWith('in/') ? 'https://linkedin.com/$liVal' : 'https://linkedin.com/in/$liVal'))
          : '';

      final wsVal = _websiteController.text.trim();
      final websiteUrl = wsVal.isNotEmpty
          ? (wsVal.startsWith('http') ? wsVal : 'https://$wsVal')
          : '';

      try {
        // Write to Supabase (upsert if present, delete if cleared)
        if (githubUrl.isNotEmpty) {
          await repo.upsertSocialLink(UserSocialLinkModel(
            id: const Uuid().v4(),
            userId: user.id,
            platform: 'github',
            url: githubUrl,
          ));
        } else {
          await repo.deleteSocialLinkByPlatform(user.id, 'github');
        }

        if (linkedinUrl.isNotEmpty) {
          await repo.upsertSocialLink(UserSocialLinkModel(
            id: const Uuid().v4(),
            userId: user.id,
            platform: 'linkedin',
            url: linkedinUrl,
          ));
        } else {
          await repo.deleteSocialLinkByPlatform(user.id, 'linkedin');
        }

        if (websiteUrl.isNotEmpty) {
          await repo.upsertSocialLink(UserSocialLinkModel(
            id: const Uuid().v4(),
            userId: user.id,
            platform: 'website',
            url: websiteUrl,
          ));
        } else {
          await repo.deleteSocialLinkByPlatform(user.id, 'website');
        }

        // Cache locally in SharedPreferences onboarding draft
        final prefs = await SharedPreferences.getInstance();
        final key = 'rc5_onboarding.${user.id}';
        await prefs.setString('$key.social_github', ghVal);
        await prefs.setString('$key.social_linkedin', liVal);
        await prefs.setString('$key.social_website', wsVal);

        ref.invalidate(rc5ProfileHeaderProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Social links updated successfully!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        }
      } on OfflineQueueException catch (e) {
        // Cache locally on offline queue exception
        final prefs = await SharedPreferences.getInstance();
        final key = 'rc5_onboarding.${user.id}';
        await prefs.setString('$key.social_github', ghVal);
        await prefs.setString('$key.social_linkedin', liVal);
        await prefs.setString('$key.social_website', wsVal);

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
              content: Text('Failed to save social links: $e'),
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
