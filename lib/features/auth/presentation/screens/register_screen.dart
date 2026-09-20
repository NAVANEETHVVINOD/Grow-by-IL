import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/supabase_error_handler.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/neo_button.dart';
import '../../../../shared/widgets/neo_card.dart';
import '../../../../shared/widgets/neo_text_field.dart';
import '../../data/auth_repository.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rollController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _awaitingConfirmation = false;
  bool _isResendingConfirmation = false;
  String? _pendingConfirmationEmail;

  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final emailAlreadyVerified =
          await ref.read(authRepositoryProvider).signUp(
                name: _nameController.text.trim(),
                collegeRoll: _optionalValue(_rollController.text),
                phone: _optionalValue(_phoneController.text),
                email: _emailController.text.trim(),
                password: _passwordController.text,
              );
      if (!mounted) return;

      if (emailAlreadyVerified) {
        context.go('/profile-setup');
      } else {
        setState(() {
          _pendingConfirmationEmail = _emailController.text.trim();
          _awaitingConfirmation = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(handleSupabaseError(e)),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _optionalValue(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _resendConfirmation() async {
    final email = _pendingConfirmationEmail;
    if (email == null || _isResendingConfirmation) return;

    setState(() => _isResendingConfirmation = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .resendSignupConfirmation(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A fresh confirmation email has been sent.'),
          backgroundColor: AppColors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(handleSupabaseError(e)),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isResendingConfirmation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // prevents back to onboarding/splash
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/login'),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _RegisterIntro(),
                const SizedBox(height: AppSizes.xl),
                if (_awaitingConfirmation)
                  _ConfirmationSentCard(
                    onSignIn: () => context.go('/login'),
                    onResend: _resendConfirmation,
                    isResending: _isResendingConfirmation,
                  )
                else
                  NeoCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          NeoTextField(
                            label: 'Full Name',
                            controller: _nameController,
                            prefixIcon: Icons.person_outline,
                            validator: (v) => AppValidators.required(v, 'Name'),
                          ),
                          const SizedBox(height: AppSizes.lg),
                          NeoTextField(
                            label: 'College Roll Number (optional)',
                            controller: _rollController,
                            prefixIcon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: AppSizes.lg),
                          NeoTextField(
                            label: 'Phone Number (optional)',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_outlined,
                          ),
                          const SizedBox(height: AppSizes.lg),
                          NeoTextField(
                            label: 'Email Address',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            validator: AppValidators.email,
                          ),
                          const SizedBox(height: AppSizes.lg),
                          NeoTextField(
                            label: 'Password',
                            controller: _passwordController,
                            obscureText: true,
                            prefixIcon: Icons.lock_outline,
                            validator: AppValidators.password,
                          ),
                          const SizedBox(height: AppSizes.xl),
                          NeoButton(
                            label: 'Create account',
                            icon: Icons.arrow_forward_rounded,
                            isLoading: _isLoading,
                            onPressed: _register,
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: AppSizes.xl),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    Text(
                      'Already have an account?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'Sign In',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterIntro extends StatelessWidget {
  const _RegisterIntro();

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      color: AppColors.green,
      borderRadius: 18,
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Stack(
        children: [
          Positioned(
            right: -6,
            bottom: -20,
            child: Icon(
              Icons.architecture_outlined,
              size: 108,
              color: AppColors.navy.withValues(alpha: .12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.person_add_alt_1_outlined, size: 28),
              const SizedBox(height: AppSizes.md),
              Text('Start making.',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      )),
              const SizedBox(height: AppSizes.xs),
              Text(
                'Create your verified Grow~ account. It works across IDEA Lab and Fab Lab.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfirmationSentCard extends StatelessWidget {
  const _ConfirmationSentCard({
    required this.onSignIn,
    required this.onResend,
    required this.isResending,
  });

  final VoidCallback onSignIn;
  final VoidCallback onResend;
  final bool isResending;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      color: AppColors.yellow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.mark_email_read_outlined, size: 34),
          const SizedBox(height: AppSizes.md),
          Text('Verify your email.',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  )),
          const SizedBox(height: AppSizes.sm),
          Text(
            'We sent a confirmation link to your inbox. Open the newest email, confirm your address, then return to Grow~ and sign in with the same email and password.',
            style:
                Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
          const SizedBox(height: AppSizes.lg),
          NeoButton(
            label: 'Resend confirmation email',
            icon: Icons.refresh_rounded,
            color: Colors.white,
            isLoading: isResending,
            onPressed: isResending ? null : onResend,
          ),
          const SizedBox(height: AppSizes.md),
          NeoButton(
            label: 'Go to sign in',
            icon: Icons.login_rounded,
            color: AppColors.navy,
            textColor: Colors.white,
            onPressed: onSignIn,
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            'Use the newest confirmation email. Old or already-used links cannot sign you in.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }
}
