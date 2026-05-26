import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/profile/domain/rc5_profile_providers.dart';
import 'package:grow/shared/widgets/rc5/rc5_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _skillOptions = [
  'Python',
  'Dart',
  'Flutter',
  'JavaScript',
  'C',
  'C++',
  'Arduino',
  'PCB Design',
  'CAD',
  'SolidWorks',
  'Figma',
  'Git',
  'Linux',
  'Supabase',
  'Firebase',
];

class RC5EditSkillsScreen extends ConsumerStatefulWidget {
  const RC5EditSkillsScreen({super.key});

  @override
  ConsumerState<RC5EditSkillsScreen> createState() =>
      _RC5EditSkillsScreenState();
}

class _RC5EditSkillsScreenState extends ConsumerState<RC5EditSkillsScreen> {
  final Map<String, int> _skills = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final header = await ref.read(rc5ProfileHeaderProvider.future);
    _skills.addAll(header?.skills ?? {});
    setState(() => _isLoading = false);
  }

  void _cycle(String skill) {
    setState(() {
      final current = _skills[skill] ?? 0;
      if (current >= 3) {
        _skills.remove(skill);
      } else {
        _skills[skill] = current + 1;
      }
    });
  }

  Future<void> _saveData() async {
    setState(() => _isSaving = true);
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      final key = 'rc5_onboarding.${user.id}';

      final serialized =
          _skills.entries.map((e) => '${e.key}:${e.value}').toList();
      await prefs.setStringList('$key.skills', serialized);

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
      appBar: AppBar(title: const Text('Edit Code Languages')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Add skills and languages',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap a skill to cycle through beginner, familiar, and strong.',
            style: TextStyle(color: RC5DesignTokens.textSecondary),
          ),
          const SizedBox(height: RC5DesignTokens.space4),
          Wrap(
            spacing: RC5DesignTokens.space2,
            runSpacing: RC5DesignTokens.space2,
            children: _skillOptions.map((skill) {
              final level = _skills[skill] ?? 0;
              return _SkillChip(
                label: skill,
                level: level,
                onTap: () => _cycle(skill),
              );
            }).toList(),
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

class _SkillChip extends StatelessWidget {
  const _SkillChip({
    required this.label,
    required this.level,
    required this.onTap,
  });

  final String label;
  final int level;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: level > 0 ? RC5DesignTokens.surface : Colors.white,
          borderRadius: BorderRadius.circular(RC5DesignTokens.radiusPill),
          border: Border.all(color: RC5DesignTokens.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: RC5DesignTokens.space2),
            Row(
              children: List.generate(3, (index) {
                final filled = index < level;
                return Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(left: 3),
                  decoration: BoxDecoration(
                    color:
                        filled ? _skillDotColor(index) : RC5DesignTokens.border,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

Color _skillDotColor(int index) {
  return switch (index) {
    0 => const Color(0xFF86EFAC),
    1 => const Color(0xFF22C55E),
    _ => const Color(0xFF15803D),
  };
}
