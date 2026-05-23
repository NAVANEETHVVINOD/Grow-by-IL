import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/shared/repositories/supabase_client.dart';
import 'package:grow/shared/widgets/rc5/rc5_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

final rc5OnboardingStepProvider = StateProvider<int>((ref) => 0);
final rc5UsernameProvider = StateProvider<String>((ref) => '');
final rc5BioProvider = StateProvider<String>((ref) => '');
final rc5UserTypeProvider = StateProvider<String>((ref) => 'student');
final rc5DepartmentProvider = StateProvider<String>((ref) => '');
final rc5InterestsProvider =
    StateNotifierProvider<_StringSetNotifier, Set<String>>((ref) {
  return _StringSetNotifier(maxItems: 5);
});
final rc5SkillsProvider =
    StateNotifierProvider<_SkillLevelNotifier, Map<String, int>>((ref) {
  return _SkillLevelNotifier();
});
final rc5GoalsProvider =
    StateNotifierProvider<_StringSetNotifier, Set<String>>((ref) {
  return _StringSetNotifier(maxItems: 3);
});

class RC5OnboardingScreen extends ConsumerStatefulWidget {
  const RC5OnboardingScreen({super.key});

  @override
  ConsumerState<RC5OnboardingScreen> createState() =>
      _RC5OnboardingScreenState();
}

class _RC5OnboardingScreenState extends ConsumerState<RC5OnboardingScreen> {
  static const _stepCount = 9;

  final _pageController = PageController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _departmentController = TextEditingController();

  bool _isLoadingDraft = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  @override
  void dispose() {
    _persistDraft();
    _pageController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _draftKey;

    final step = prefs.getInt('$key.step') ?? 0;
    final username = prefs.getString('$key.username') ?? '';
    final bio = prefs.getString('$key.bio') ?? '';
    final userType = prefs.getString('$key.userType') ?? 'student';
    final department = prefs.getString('$key.department') ?? '';
    final interests = prefs.getStringList('$key.interests') ?? [];
    final goals = prefs.getStringList('$key.goals') ?? [];

    final skillEntries = prefs.getStringList('$key.skills') ?? [];
    final skills = <String, int>{};
    for (final entry in skillEntries) {
      final parts = entry.split(':');
      if (parts.length != 2) continue;
      skills[parts.first] = int.tryParse(parts.last) ?? 1;
    }

    ref.read(rc5OnboardingStepProvider.notifier).state =
        step.clamp(0, _stepCount - 1);
    ref.read(rc5UsernameProvider.notifier).state = username;
    ref.read(rc5BioProvider.notifier).state = bio;
    ref.read(rc5UserTypeProvider.notifier).state = userType;
    ref.read(rc5DepartmentProvider.notifier).state = department;
    ref.read(rc5InterestsProvider.notifier).replace(interests);
    ref.read(rc5SkillsProvider.notifier).replace(skills);
    ref.read(rc5GoalsProvider.notifier).replace(goals);

    _usernameController.text = username;
    _bioController.text = bio;
    _departmentController.text = department;

    if (mounted) {
      setState(() => _isLoadingDraft = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(ref.read(rc5OnboardingStepProvider));
        }
      });
    }
  }

  Future<void> _persistDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _draftKey;
    final skills = ref.read(rc5SkillsProvider);

    await prefs.setInt('$key.step', ref.read(rc5OnboardingStepProvider));
    await prefs.setString('$key.username', ref.read(rc5UsernameProvider));
    await prefs.setString('$key.bio', ref.read(rc5BioProvider));
    await prefs.setString('$key.userType', ref.read(rc5UserTypeProvider));
    await prefs.setString('$key.department', ref.read(rc5DepartmentProvider));
    await prefs.setStringList(
      '$key.interests',
      ref.read(rc5InterestsProvider).toList(),
    );
    await prefs.setStringList(
      '$key.goals',
      ref.read(rc5GoalsProvider).toList(),
    );
    await prefs.setStringList(
      '$key.skills',
      skills.entries.map((entry) => '${entry.key}:${entry.value}').toList(),
    );
  }

  Future<void> _completeOnboarding() async {
    if (!_validateStep(7)) return;

    setState(() => _isSaving = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        if (mounted) context.go('/login');
        return;
      }

      await supabase.from('users').update({
        'profile_completed': true,
      }).eq('id', user.id);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_draftKey.step');
      await prefs.setBool('$_draftKey.completedLocally', true);

      ref.invalidate(currentUserProvider);

      if (mounted) {
        ref.read(rc5OnboardingStepProvider.notifier).state = 8;
        await _pageController.animateToPage(
          8,
          duration: RC5DesignTokens.motionSlow,
          curve: RC5DesignTokens.easeOut,
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not complete onboarding: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String get _draftKey {
    final userId = supabase.auth.currentUser?.id ?? 'anonymous';
    return 'rc5_onboarding.$userId';
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(rc5OnboardingStepProvider);

    if (_isLoadingDraft) {
      return const Scaffold(
        backgroundColor: RC5DesignTokens.background,
        body: Center(
          child: RC5Skeleton(width: 260, height: 420),
        ),
      );
    }

    return PopScope(
      canPop: step == 0,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _goBack();
      },
      child: Scaffold(
        backgroundColor: RC5DesignTokens.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: _ProgressHeader(
                  step: step,
                  totalSteps: _stepCount,
                  onSaveAndExit: () async {
                    await _persistDraft();
                    if (!context.mounted) return;
                    context.go('/login');
                  },
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _WelcomeStep(onNext: _goNext),
                    _UsernameStep(controller: _usernameController),
                    _BasicProfileStep(bioController: _bioController),
                    const _InterestsStep(),
                    const _SkillsStep(),
                    _RoleDepartmentStep(
                      departmentController: _departmentController,
                    ),
                    const _GoalsStep(),
                    const _PreviewStep(),
                    _CompletionStep(onContinue: () => context.go('/home')),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Row(
                  children: [
                    if (step > 0 && step < _stepCount - 1)
                      Expanded(
                        child: RC5Button(
                          label: 'Back',
                          icon: Icons.arrow_back_rounded,
                          variant: RC5ButtonVariant.secondary,
                          onPressed: _goBack,
                        ),
                      ),
                    if (step > 0 && step < _stepCount - 1)
                      const SizedBox(width: RC5DesignTokens.space3),
                    Expanded(
                      flex: 2,
                      child: RC5Button(
                        label: step == 7
                            ? 'Complete'
                            : step == _stepCount - 1
                                ? 'Enter Grow~'
                                : 'Continue',
                        icon: step == _stepCount - 1
                            ? Icons.home_rounded
                            : Icons.arrow_forward_rounded,
                        isLoading: _isSaving,
                        onPressed: step == _stepCount - 1
                            ? () => context.go('/home')
                            : step == 7
                                ? _completeOnboarding
                                : _goNext,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _goNext() async {
    final current = ref.read(rc5OnboardingStepProvider);
    if (!_validateStep(current)) return;
    final next = (current + 1).clamp(0, _stepCount - 1);
    ref.read(rc5OnboardingStepProvider.notifier).state = next;
    await _persistDraft();
    await _pageController.animateToPage(
      next,
      duration: RC5DesignTokens.motionSlow,
      curve: RC5DesignTokens.easeOut,
    );
  }

  Future<void> _goBack() async {
    final current = ref.read(rc5OnboardingStepProvider);
    final previous = (current - 1).clamp(0, _stepCount - 1);
    ref.read(rc5OnboardingStepProvider.notifier).state = previous;
    await _persistDraft();
    await _pageController.animateToPage(
      previous,
      duration: RC5DesignTokens.motionBase,
      curve: RC5DesignTokens.easeOut,
    );
  }

  bool _validateStep(int step) {
    final message = switch (step) {
      1 => _validateUsername(ref.read(rc5UsernameProvider)).message,
      2 => _bioValidationMessage(ref.read(rc5BioProvider)),
      3 => ref.read(rc5InterestsProvider).length == 5
          ? null
          : 'Choose exactly 5 interests.',
      5 => ref.read(rc5DepartmentProvider).trim().isEmpty
          ? 'Add your department, class, company, or role.'
          : null,
      6 =>
        ref.read(rc5GoalsProvider).isEmpty ? 'Choose at least one goal.' : null,
      7 => _previewValidationMessage(),
      _ => null,
    };

    if (message == null) return true;
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
    return false;
  }

  String? _previewValidationMessage() {
    return _validateUsername(ref.read(rc5UsernameProvider)).message ??
        _bioValidationMessage(ref.read(rc5BioProvider));
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.step,
    required this.totalSteps,
    required this.onSaveAndExit,
  });

  final int step;
  final int totalSteps;
  final VoidCallback onSaveAndExit;

  @override
  Widget build(BuildContext context) {
    final progress = (step + 1) / totalSteps;

    return Column(
      children: [
        Row(
          children: [
            Text(
              'Grow~',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: RC5DesignTokens.ink,
                  ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onSaveAndExit,
              child: const Text('Save & exit'),
            ),
          ],
        ),
        const SizedBox(height: RC5DesignTokens.space2),
        ClipRRect(
          borderRadius: BorderRadius.circular(RC5DesignTokens.radiusPill),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: progress,
            backgroundColor: RC5DesignTokens.surfaceAlt,
            valueColor: const AlwaysStoppedAnimation(RC5DesignTokens.primary),
          ),
        ),
      ],
    );
  }
}

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: RC5DesignTokens.space4),
        RC5Card(
          gradient: RC5DesignTokens.softGradient,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: RC5DesignTokens.primaryGradient,
                  borderRadius: BorderRadius.circular(RC5DesignTokens.radiusLg),
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(height: RC5DesignTokens.space5),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: RC5DesignTokens.ink,
                    ),
              ),
              const SizedBox(height: RC5DesignTokens.space2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: RC5DesignTokens.textSecondary,
                      height: 1.45,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: RC5DesignTokens.space5),
        child,
      ],
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      icon: Icons.auto_awesome_rounded,
      title: 'Build your maker identity',
      subtitle:
          'Grow~ is becoming your IDEA Lab identity: projects, events, skills, opportunities, and community trust.',
      child: Column(
        children: [
          const _ValuePill(
            icon: Icons.badge_rounded,
            title: 'Public maker profile',
            subtitle: 'Show what you build and what you care about.',
          ),
          const SizedBox(height: RC5DesignTokens.space3),
          const _ValuePill(
            icon: Icons.diversity_3_rounded,
            title: 'Community discovery',
            subtitle: 'Find collaborators, mentors, and events faster.',
          ),
          const SizedBox(height: RC5DesignTokens.space3),
          const _ValuePill(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy-aware by default',
            subtitle: 'Bookings and detailed activity stay private.',
          ),
          const SizedBox(height: RC5DesignTokens.space5),
          RC5Button(
            label: 'Start setup',
            icon: Icons.arrow_forward_rounded,
            fullWidth: true,
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _UsernameStep extends ConsumerWidget {
  const _UsernameStep({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(rc5UsernameProvider);
    final validation = _validateUsername(username);

    return _StepScaffold(
      icon: Icons.alternate_email_rounded,
      title: 'Choose your username',
      subtitle:
          'Use letters, numbers, and underscores only. No dots. This will become your public Grow~ handle.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
              LowerCaseTextFormatter(),
            ],
            decoration: const InputDecoration(
              prefixText: '@',
              labelText: 'Username',
              hintText: 'navaneeth_v',
            ),
            onChanged: (value) {
              ref.read(rc5UsernameProvider.notifier).state = value;
            },
          ),
          const SizedBox(height: RC5DesignTokens.space3),
          _ValidationHint(validation: validation),
        ],
      ),
    );
  }
}

class _BasicProfileStep extends ConsumerWidget {
  const _BasicProfileStep({required this.bioController});

  final TextEditingController bioController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final bio = ref.watch(rc5BioProvider);

    return _StepScaffold(
      icon: Icons.person_rounded,
      title: 'Basic profile',
      subtitle:
          'Your Google name and email stay trusted. Add a short bio so people know what you build.',
      child: Column(
        children: [
          RC5Card(
            backgroundColor: Colors.white,
            shadowOpacity: 0.65,
            child: Row(
              children: [
                RC5Avatar(
                  imageUrl: user?.avatarUrl,
                  displayName: user?.name,
                  size: 54,
                ),
                const SizedBox(width: RC5DesignTokens.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Grow user',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        user?.email ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: RC5DesignTokens.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: RC5DesignTokens.space4),
          TextField(
            controller: bioController,
            maxLength: 300,
            minLines: 4,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Bio',
              hintText: 'Maker. Builder. Tinkerer. Tell us your angle...',
            ),
            onChanged: (value) =>
                ref.read(rc5BioProvider.notifier).state = value.trimLeft(),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _bioValidationMessage(bio) ?? 'Looks good.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _bioValidationMessage(bio) == null
                        ? RC5DesignTokens.success
                        : RC5DesignTokens.textSecondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InterestsStep extends ConsumerWidget {
  const _InterestsStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(rc5InterestsProvider);

    return _StepScaffold(
      icon: Icons.interests_rounded,
      title: 'Pick exactly 5 interests',
      subtitle:
          'These help Grow~ personalize events, projects, mentors, and opportunities later.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${selected.length}/5 selected',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: RC5DesignTokens.space3),
          Wrap(
            spacing: RC5DesignTokens.space2,
            runSpacing: RC5DesignTokens.space2,
            children: _interestOptions.map((interest) {
              final isSelected = selected.contains(interest);
              return RC5Chip(
                label: interest,
                isSelected: isSelected,
                onTap: () =>
                    ref.read(rc5InterestsProvider.notifier).toggle(interest),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SkillsStep extends ConsumerWidget {
  const _SkillsStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skills = ref.watch(rc5SkillsProvider);

    return _StepScaffold(
      icon: Icons.code_rounded,
      title: 'Add skills and languages',
      subtitle:
          'Optional for now. Tap a skill to cycle through beginner, familiar, and strong.',
      child: Wrap(
        spacing: RC5DesignTokens.space2,
        runSpacing: RC5DesignTokens.space2,
        children: _skillOptions.map((skill) {
          final level = skills[skill] ?? 0;
          return _SkillChip(
            label: skill,
            level: level,
            onTap: () => ref.read(rc5SkillsProvider.notifier).cycle(skill),
          );
        }).toList(),
      ),
    );
  }
}

class _RoleDepartmentStep extends ConsumerWidget {
  const _RoleDepartmentStep({required this.departmentController});

  final TextEditingController departmentController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userType = ref.watch(rc5UserTypeProvider);

    return _StepScaffold(
      icon: Icons.school_rounded,
      title: 'Your current context',
      subtitle:
          'This stays ready for the RC5 profile migration. Your database role is not changed here.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RC5Card(
                  onTap: () =>
                      ref.read(rc5UserTypeProvider.notifier).state = 'student',
                  backgroundColor: userType == 'student'
                      ? RC5DesignTokens.surface
                      : Colors.white,
                  child: const _ChoiceContent(
                    icon: Icons.school_rounded,
                    title: 'Student',
                    subtitle: 'KTU, department, batch',
                  ),
                ),
              ),
              const SizedBox(width: RC5DesignTokens.space3),
              Expanded(
                child: RC5Card(
                  onTap: () => ref.read(rc5UserTypeProvider.notifier).state =
                      'professional',
                  backgroundColor: userType == 'professional'
                      ? RC5DesignTokens.surface
                      : Colors.white,
                  child: const _ChoiceContent(
                    icon: Icons.work_rounded,
                    title: 'Professional',
                    subtitle: 'Role, company, work',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: RC5DesignTokens.space4),
          TextField(
            controller: departmentController,
            decoration: InputDecoration(
              labelText:
                  userType == 'student' ? 'Department / class' : 'Role / org',
              hintText: userType == 'student'
                  ? 'CSE S6, ECE S4...'
                  : 'Frontend intern, MakerGram...',
            ),
            onChanged: (value) =>
                ref.read(rc5DepartmentProvider.notifier).state = value,
          ),
        ],
      ),
    );
  }
}

class _GoalsStep extends ConsumerWidget {
  const _GoalsStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(rc5GoalsProvider);

    return _StepScaffold(
      icon: Icons.flag_rounded,
      title: 'What do you want from Grow~?',
      subtitle:
          'Choose up to three. This guides Home, opportunities, support, and event recommendations later.',
      child: Wrap(
        spacing: RC5DesignTokens.space2,
        runSpacing: RC5DesignTokens.space2,
        children: _goalOptions.map((goal) {
          return RC5Chip(
            label: goal,
            isSelected: selected.contains(goal),
            onTap: () => ref.read(rc5GoalsProvider.notifier).toggle(goal),
          );
        }).toList(),
      ),
    );
  }
}

class _PreviewStep extends ConsumerWidget {
  const _PreviewStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final username = ref.watch(rc5UsernameProvider);
    final bio = ref.watch(rc5BioProvider);
    final interests = ref.watch(rc5InterestsProvider);
    final skills = ref.watch(rc5SkillsProvider);
    final department = ref.watch(rc5DepartmentProvider);

    return _StepScaffold(
      icon: Icons.preview_rounded,
      title: 'Preview your maker profile',
      subtitle:
          'This is the identity direction. Future RC5 migrations will sync the draft fields to public profile tables.',
      child: RC5Card(
        backgroundColor: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                RC5Avatar(
                  imageUrl: user?.avatarUrl,
                  displayName: user?.name,
                  size: 64,
                ),
                const SizedBox(width: RC5DesignTokens.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Grow user',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '@$username',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: RC5DesignTokens.textSecondary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: RC5DesignTokens.space4),
            Text(bio),
            const SizedBox(height: RC5DesignTokens.space4),
            Text(
              department,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: RC5DesignTokens.space4),
            Wrap(
              spacing: RC5DesignTokens.space2,
              runSpacing: RC5DesignTokens.space2,
              children: interests
                  .map((interest) => RC5Chip(label: interest, compact: true))
                  .toList(),
            ),
            if (skills.isNotEmpty) ...[
              const SizedBox(height: RC5DesignTokens.space4),
              Wrap(
                spacing: RC5DesignTokens.space2,
                runSpacing: RC5DesignTokens.space2,
                children: skills.entries
                    .map(
                      (entry) => _SkillChip(
                        label: entry.key,
                        level: entry.value,
                        onTap: () {},
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CompletionStep extends StatelessWidget {
  const _CompletionStep({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      icon: Icons.check_circle_rounded,
      title: 'You are ready',
      subtitle:
          'Your profile completion is saved. Grow~ will keep expanding this identity into portfolio, projects, events, and opportunities.',
      child: RC5Button(
        label: 'Enter Grow~',
        icon: Icons.home_rounded,
        fullWidth: true,
        onPressed: onContinue,
      ),
    );
  }
}

class _ValuePill extends StatelessWidget {
  const _ValuePill({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return RC5Card(
      backgroundColor: Colors.white,
      shadowOpacity: 0.55,
      child: Row(
        children: [
          Icon(icon, color: RC5DesignTokens.primary),
          const SizedBox(width: RC5DesignTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: RC5DesignTokens.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceContent extends StatelessWidget {
  const _ChoiceContent({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: RC5DesignTokens.primary),
        const SizedBox(height: RC5DesignTokens.space4),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: RC5DesignTokens.textSecondary,
              ),
        ),
      ],
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

class _ValidationHint extends StatelessWidget {
  const _ValidationHint({required this.validation});

  final _UsernameValidation validation;

  @override
  Widget build(BuildContext context) {
    final isValid = validation.message == null;

    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle_rounded : Icons.info_rounded,
          color: isValid ? RC5DesignTokens.success : RC5DesignTokens.warning,
          size: 18,
        ),
        const SizedBox(width: RC5DesignTokens.space2),
        Expanded(
          child: Text(
            isValid
                ? 'Format accepted. Uniqueness will be enforced when the username schema lands.'
                : validation.message!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isValid
                      ? RC5DesignTokens.success
                      : RC5DesignTokens.textSecondary,
                ),
          ),
        ),
      ],
    );
  }
}

class _StringSetNotifier extends StateNotifier<Set<String>> {
  _StringSetNotifier({this.maxItems}) : super({});

  final int? maxItems;

  void toggle(String value) {
    final next = {...state};
    if (next.contains(value)) {
      next.remove(value);
    } else if (maxItems == null || next.length < maxItems!) {
      next.add(value);
    }
    state = next;
  }

  void replace(Iterable<String> values) {
    state = values.take(maxItems ?? values.length).toSet();
  }
}

class _SkillLevelNotifier extends StateNotifier<Map<String, int>> {
  _SkillLevelNotifier() : super({});

  void cycle(String skill) {
    final current = state[skill] ?? 0;
    final next = {...state};
    if (current >= 3) {
      next.remove(skill);
    } else {
      next[skill] = current + 1;
    }
    state = next;
  }

  void replace(Map<String, int> skills) {
    state = Map.fromEntries(
      skills.entries.where((entry) => entry.value >= 1 && entry.value <= 3),
    );
  }
}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

class _UsernameValidation {
  const _UsernameValidation(this.message);

  final String? message;
}

_UsernameValidation _validateUsername(String value) {
  final username = value.trim();
  if (username.length < 3) {
    return const _UsernameValidation('Use at least 3 characters.');
  }
  if (username.length > 24) {
    return const _UsernameValidation('Keep it under 24 characters.');
  }
  if (!_usernamePattern.hasMatch(username)) {
    return const _UsernameValidation(
      'Only lowercase letters, numbers, and underscores are allowed.',
    );
  }
  if (_reservedUsernames.contains(username)) {
    return const _UsernameValidation('That username is reserved.');
  }
  return const _UsernameValidation(null);
}

String? _bioValidationMessage(String value) {
  final bio = value.trim();
  if (bio.length < 30) return 'Bio must be at least 30 characters.';
  if (bio.length > 300) return 'Bio must stay under 300 characters.';
  return null;
}

Color _skillDotColor(int index) {
  return switch (index) {
    0 => const Color(0xFF86EFAC),
    1 => const Color(0xFF22C55E),
    _ => const Color(0xFF15803D),
  };
}

final _usernamePattern = RegExp(r'^[a-z0-9_]+$');

const _reservedUsernames = {
  'admin',
  'support',
  'system',
  'settings',
  'notifications',
  'api',
  'root',
  'grow',
  'idealab',
  'akathalam',
  'home',
  'profile',
  'null',
  'undefined',
};

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

const _goalOptions = [
  'Build projects',
  'Find teammates',
  'Attend workshops',
  'Get mentorship',
  'Learn machines',
  'Find internships',
  'Volunteer',
  'Showcase portfolio',
];
