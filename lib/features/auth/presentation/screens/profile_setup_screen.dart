import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/supabase_error_handler.dart';
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
  final _usernameController = TextEditingController();
  final _skillController = TextEditingController();
  final _interestController = TextEditingController();
  
  String _selectedBaseRole = 'student';
  final List<String> _skills = [];
  final List<String> _interests = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _skillController.dispose();
    _interestController.dispose();
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

      // Check if username is already taken
      final usernameCheck = await supabase
          .from('users')
          .select('id')
          .eq('username', _usernameController.text.trim())
          .maybeSingle();

      if (usernameCheck != null) {
        throw Exception('Username is already taken');
      }

      await supabase.from('users').update({
        'username': _usernameController.text.trim(),
        'base_role': _selectedBaseRole,
        'skills': _skills,
        'interests': _interests,
        'profile_completed': true,
      }).eq('id', user.id);

      // Invalidate the current user provider so it re-fetches the updated profile
      ref.invalidate(currentUserProvider);

      if (mounted) {
        context.go('/home');
      }
    } catch (e, st) {
      AppLogger.error(LogCategory.AUTH, 'Profile setup failed', error: e, stack: st);
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
                    'Complete Your Profile',
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
                    'Just a few more details to get you started.',
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
                                const Icon(Icons.person, color: AppColors.textSecondary),
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
                        NeoTextField(
                          controller: _usernameController,
                          label: 'Choose a Username',
                          prefixIcon: Icons.alternate_email,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username is required';
                            }
                            if (value.length < 3) {
                              return 'Username must be at least 3 characters';
                            }
                            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                              return 'Only letters, numbers, and underscores allowed';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSizes.lg),
                        const Text(
                          'Select your role:',
                          style: TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        DropdownButtonFormField<String>(
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
                          items: const [
                            DropdownMenuItem(
                              value: 'student',
                              child: Text('Student', style: TextStyle(fontFamily: 'DM Sans')),
                            ),
                            DropdownMenuItem(
                              value: 'faculty',
                              child: Text('Faculty', style: TextStyle(fontFamily: 'DM Sans')),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedBaseRole = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: AppSizes.lg),
                        const Text(
                          'Skills (Optional):',
                          style: TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _skills.map((skill) {
                            return Chip(
                              label: Text(skill, style: const TextStyle(fontFamily: 'DM Sans')),
                              backgroundColor: AppColors.yellow,
                              deleteIconColor: AppColors.navy,
                              onDeleted: () {
                                setState(() {
                                  _skills.remove(skill);
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                                side: const BorderSide(color: AppColors.navy, width: 2),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: NeoTextField(
                                controller: _skillController,
                                label: 'Add a Skill (e.g. Flutter)',
                              ),
                            ),
                            const SizedBox(width: AppSizes.sm),
                            NeoButton(
                              label: 'Add',
                              width: 80,
                              onPressed: () {
                                if (_skillController.text.trim().isNotEmpty) {
                                  setState(() {
                                    if (!_skills.contains(_skillController.text.trim())) {
                                      _skills.add(_skillController.text.trim());
                                    }
                                    _skillController.clear();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.lg),
                        const Text(
                          'Interests (Optional):',
                          style: TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _interests.map((interest) {
                            return Chip(
                              label: Text(interest, style: const TextStyle(fontFamily: 'DM Sans')),
                              backgroundColor: AppColors.cobalt.withValues(alpha: 0.2),
                              deleteIconColor: AppColors.navy,
                              onDeleted: () {
                                setState(() {
                                  _interests.remove(interest);
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                                side: const BorderSide(color: AppColors.navy, width: 2),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: NeoTextField(
                                controller: _interestController,
                                label: 'Add an Interest (e.g. AI)',
                              ),
                            ),
                            const SizedBox(width: AppSizes.sm),
                            NeoButton(
                              label: 'Add',
                              width: 80,
                              onPressed: () {
                                if (_interestController.text.trim().isNotEmpty) {
                                  setState(() {
                                    if (!_interests.contains(_interestController.text.trim())) {
                                      _interests.add(_interestController.text.trim());
                                    }
                                    _interestController.clear();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.xl),
                        NeoButton(
                          onPressed: _isLoading ? () {} : _completeProfile,
                          label: _isLoading ? 'Saving...' : 'Complete Setup',
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
