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
  bool _fieldsLoaded = false;
  bool _isLoading = false;

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
    super.dispose();
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
    ref.listen(currentUserProvider, (_, next) {
      _seedFields(next.valueOrNull);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    AppStrings.completeYourProfile,
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  const Text(
                    AppStrings.profileSetupSubtitle,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.xl),
                  NeoCard(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        userAsync.when(
                          data: (user) => user == null
                              ? TextButton(
                                  onPressed: () =>
                                      ref.invalidate(currentUserProvider),
                                  child:
                                      const Text('Profile unavailable. Retry'),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSizes.md,
                                  ),
                                  child: Text(
                                    user.email,
                                    style: const TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stack) => TextButton(
                            onPressed: () =>
                                ref.invalidate(currentUserProvider),
                            child: const Text('Profile unavailable. Retry'),
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        NeoTextField(
                          label: 'Display name',
                          controller: _nameController,
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            final name = value?.trim() ?? '';
                            if (name.isEmpty) return 'Enter your name';
                            if (name.length > 100) {
                              return 'Keep your name under 100 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSizes.md),
                        NeoTextField(
                          label: 'Phone (optional)',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                        ),
                        const SizedBox(height: AppSizes.md),
                        NeoTextField(
                          label: 'College roll number (optional)',
                          controller: _rollController,
                          prefixIcon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: AppSizes.lg),
                        const Text(
                          'Your account access is assigned by IDEA Lab. '
                          'More profile details can be added later.',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.xl),
                        NeoButton(
                          onPressed: _isLoading ||
                                  !userAsync.hasValue ||
                                  userAsync.valueOrNull == null
                              ? null
                              : _completeProfile,
                          label: _isLoading
                              ? AppStrings.saving
                              : AppStrings.completeSetup,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
