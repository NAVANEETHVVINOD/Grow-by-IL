import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/supabase_error_handler.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/repositories/supabase_client.dart';
import '../../../../shared/widgets/neo_button.dart';
import '../../../../shared/widgets/neo_card.dart';
import '../../../../shared/widgets/neo_text_field.dart';
import '../../data/auth_repository.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _rollController = TextEditingController();
  final _pageController = PageController();
  bool _fieldsLoaded = false;
  bool _isLoading = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    ref.read(currentUserProvider.future).then(_seedFields).catchError((_) {});
  }

  void _seedFields(UserModel? user) {
    if (!mounted || _fieldsLoaded || user == null) return;
    _nameController.text = user.name;
    _phoneController.text = user.phone ?? '';
    _rollController.text = user.collegeRoll ?? '';
    _fieldsLoaded = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _rollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _advanceStep() async {
    FocusScope.of(context).unfocus();
    if (_currentStep == 0 && !_formKey.currentState!.validate()) return;

    if (_currentStep < 2) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
      if (mounted) setState(() => _currentStep++);
      return;
    }

    await _completeProfile();
  }

  Future<void> _previousStep() async {
    FocusScope.of(context).unfocus();
    if (_currentStep == 0) return;
    await _pageController.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
    if (mounted) setState(() => _currentStep--);
  }

  Widget _buildStep({
    required String title,
    required String subtitle,
    required Widget field,
    String? note,
  }) {
    final compact = MediaQuery.viewInsetsOf(context).bottom > 0 ||
        MediaQuery.sizeOf(context).height < 620;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: (compact
                      ? Theme.of(context).textTheme.headlineSmall
                      : Theme.of(context).textTheme.headlineMedium)
                  ?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: compact ? AppSizes.md : AppSizes.xl),
            NeoCard(
              padding: EdgeInsets.all(compact ? AppSizes.md : AppSizes.lg),
              child: field,
            ),
            if (note != null) ...[
              SizedBox(height: compact ? AppSizes.sm : AppSizes.md),
              Text(
                note,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      final updated = await supabase
          .from('users')
          .update({
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            'college_roll': _rollController.text.trim().isEmpty
                ? null
                : _rollController.text.trim(),
            'profile_completed': true,
          })
          .eq('id', user.id)
          .select('profile_completed')
          .single();
      if (updated['profile_completed'] != true) {
        throw StateError('Profile completion was not saved');
      }

      final profile = await ref.refresh(currentUserProvider.future);
      if (profile?.profileCompleted != true) {
        throw StateError('Could not verify the saved profile');
      }

      if (mounted) {
        context.go('/home');
      }
    } catch (e, st) {
      AppLogger.error(
        LogCategory.auth,
        'Profile setup failed',
        error: e,
        stack: st,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(handleSupabaseError(e)),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    ref.listen(currentUserProvider, (_, next) {
      _seedFields(next.valueOrNull);
    });

    final canContinue =
        !_isLoading && userAsync.hasValue && userAsync.valueOrNull != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (!keyboardVisible) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.lg,
                    AppSizes.md,
                    AppSizes.lg,
                    AppSizes.sm,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tune_rounded, color: AppColors.navy),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: Text(
                          AppStrings.completeYourProfile,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                        ),
                      ),
                      Text(
                        '${_currentStep + 1} / 3',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                  child: userAsync.when(
                    data: (user) => user == null
                        ? TextButton(
                            onPressed: () =>
                                ref.invalidate(currentUserProvider),
                            child: const Text('Profile unavailable. Retry'),
                          )
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              user.email,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                    loading: () => const LinearProgressIndicator(),
                    error: (error, stack) => TextButton(
                      onPressed: () => ref.invalidate(currentUserProvider),
                      child: const Text('Profile unavailable. Retry'),
                    ),
                  ),
                ),
              ],
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep(
                      title: 'What should we call you?',
                      subtitle:
                          'Choose the name people will see on your profile.',
                      field: NeoTextField(
                        label: 'Display name',
                        controller: _nameController,
                        prefixIcon: Icons.person_outline,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          final name = value?.trim() ?? '';
                          if (name.isEmpty) return 'Enter your name';
                          if (name.length > 100) {
                            return 'Keep your name under 100 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    _buildStep(
                      title: 'Add a phone number',
                      subtitle: 'Optional. You can add or change this later.',
                      field: NeoTextField(
                        label: 'Phone number',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Icons.phone_outlined,
                      ),
                      note:
                          'Skip this step by continuing with the field blank.',
                    ),
                    _buildStep(
                      title: 'College details',
                      subtitle:
                          'Your roll number is optional and editable later.',
                      field: NeoTextField(
                        label: 'College roll number (optional)',
                        controller: _rollController,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Icons.badge_outlined,
                      ),
                      note: 'Your account access is assigned by IDEA Lab.',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  keyboardVisible ? 0 : AppSizes.sm,
                  AppSizes.lg,
                  keyboardVisible ? AppSizes.sm : AppSizes.md,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!keyboardVisible) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: index == _currentStep ? 28 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: index == _currentStep
                                  ? AppColors.navy
                                  : AppColors.navy.withValues(alpha: 0.24),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                    ],
                    Row(
                      children: [
                        if (_currentStep > 0)
                          TextButton(
                            onPressed: _isLoading ? null : _previousStep,
                            child: const Text('Back'),
                          )
                        else
                          const SizedBox(width: 64),
                        const Spacer(),
                        NeoButton(
                          onPressed: canContinue ? _advanceStep : null,
                          label: _isLoading
                              ? AppStrings.saving
                              : _currentStep == 2
                                  ? 'Finish'
                                  : 'Continue',
                          width: 190,
                        ),
                      ],
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
}
