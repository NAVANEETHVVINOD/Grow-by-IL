import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/profile/domain/rc5_profile_providers.dart';
import 'package:grow/shared/widgets/rc5/rc5_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _interestOptions = [
  'Programming',
  'Electronics',
  'Design',
  'Robotics',
  '3D Printing',
  'IoT',
  'Web Dev',
  'Gaming',
  'Fitness',
  'Music',
  'Photography',
  'Volunteering',
  'AI/ML',
  'Woodworking',
  'Sustainability',
  'Entrepreneurship',
  'Research',
  'Animation',
];

class RC5EditInterestsScreen extends ConsumerStatefulWidget {
  const RC5EditInterestsScreen({super.key});

  @override
  ConsumerState<RC5EditInterestsScreen> createState() =>
      _RC5EditInterestsScreenState();
}

class _RC5EditInterestsScreenState
    extends ConsumerState<RC5EditInterestsScreen> {
  final Set<String> _selected = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final header = await ref.read(rc5ProfileHeaderProvider.future);
    _selected.addAll(header?.interests ?? []);
    setState(() => _isLoading = false);
  }

  void _toggle(String interest) {
    setState(() {
      if (_selected.contains(interest)) {
        _selected.remove(interest);
      } else {
        if (_selected.length < 5) {
          _selected.add(interest);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can select exactly 5 interests max.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });
  }

  Future<void> _saveData() async {
    if (_selected.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select exactly 5 interests before saving.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: RC5DesignTokens.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      final key = 'rc5_onboarding.${user.id}';

      await prefs.setStringList('$key.interests', _selected.toList());
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
      appBar: AppBar(title: const Text('Edit Interests')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Pick exactly 5 interests',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'These help Grow~ personalize events, projects, mentors, and opportunities later.',
            style: TextStyle(color: RC5DesignTokens.textSecondary),
          ),
          const SizedBox(height: RC5DesignTokens.space4),
          Wrap(
            spacing: RC5DesignTokens.space2,
            runSpacing: RC5DesignTokens.space2,
            children: _interestOptions.map((interest) {
              final isSelected = _selected.contains(interest);
              return RC5Chip(
                label: interest,
                isSelected: isSelected,
                onTap: () => _toggle(interest),
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
