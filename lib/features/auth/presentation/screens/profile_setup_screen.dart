import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_roles.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/supabase_error_handler.dart';
import '../../../../shared/repositories/supabase_client.dart';
import '../../../../shared/widgets/neo_button.dart';
import '../../../../shared/widgets/neo_card.dart';
import '../../data/auth_repository.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  AppRole _selectedBaseRole = AppRole.student;

  bool _isLoading = false;

  @override
  void dispose() {
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

      await supabase.from('users').update({
        'role': _selectedBaseRole.value,
        'profile_completed': true,
      }).eq('id', user.id);

      // Invalidate the current user provider so it re-fetches the updated profile
      ref.invalidate(currentUserProvider);

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
                          data: (user) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSizes.md),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: AppSizes.sm),
                                Text(
                                  'Welcome, ${user?.name ?? ''}!',
                                  style: const TextStyle(
                                    fontFamily: 'DM Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stack) => const SizedBox(),
                        ),
                        const SizedBox(height: AppSizes.lg),
                        const Text(
                          AppStrings.selectYourRole,
                          style: TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        DropdownButtonFormField<AppRole>(
                          initialValue: _selectedBaseRole,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: const BorderSide(
                                color: AppColors.navy,
                                width: 3,
                              ),
                            ),
                            filled: true,
                            fillColor: AppColors.surface,
                          ),
                          items: AppRole.selfAssignableRoles
                              .map((role) => DropdownMenuItem(
                                    value: role,
                                    child: Text(
                                      role.displayName,
                                      style: const TextStyle(
                                          fontFamily: 'DM Sans'),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedBaseRole = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: AppSizes.xl),
                        NeoButton(
                          onPressed: _isLoading ? () {} : _completeProfile,
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
