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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _awaitingConfirmation = false;
  bool _isResendingConfirmation = false;
  bool _resendFeedbackIsError = false;
  String? _resendFeedback;
  String? _pendingConfirmationEmail;

  @override
  void dispose() {
    _nameController.dispose();
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
                email: _emailController.text.trim(),
                password: _passwordController.text,
              );
      if (!mounted) return;

      if (emailAlreadyVerified) {
        context.go('/profile-setup');
      } else {
        // The password field can still own focus when registration completes.
        // Close the keyboard before showing the fixed-height confirmation
        // state so the resend result and both actions remain visible.
        FocusManager.instance.primaryFocus?.unfocus();
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

  Future<void> _resendConfirmation() async {
    final email = _pendingConfirmationEmail;
    if (email == null || _isResendingConfirmation) return;

    setState(() {
      _isResendingConfirmation = true;
      _resendFeedback = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .resendSignupConfirmation(email: email);
      if (!mounted) return;
      setState(() {
        _resendFeedback =
            'If this address needs confirmation, a fresh email was requested. Check your spam folder too.';
        _resendFeedbackIsError = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _resendFeedback = handleSupabaseError(e);
        _resendFeedbackIsError = true;
      });
    } finally {
      if (mounted) setState(() => _isResendingConfirmation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardIsVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    return PopScope(
      canPop: false, // prevents back to onboarding/splash
      child: Scaffold(
        appBar: keyboardIsVisible
            ? null
            : AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/login'),
                ),
              ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Use the compact form on portrait phones after system bars;
              // the spacious form overflows on the I2301's 824 dp safe area.
              final compact = constraints.maxHeight < 900 || keyboardIsVisible;
              final needsScroll =
                  keyboardIsVisible || constraints.maxHeight < 560;
              final content = _RegisterContent(
                compact: compact || _awaitingConfirmation,
                keyboardVisible: keyboardIsVisible,
                awaitingConfirmation: _awaitingConfirmation,
                formKey: _formKey,
                nameController: _nameController,
                emailController: _emailController,
                passwordController: _passwordController,
                isLoading: _isLoading,
                isResending: _isResendingConfirmation,
                feedbackMessage: _resendFeedback,
                feedbackIsError: _resendFeedbackIsError,
                onRegister: _register,
                onResend: _resendConfirmation,
                onSignIn: () => context.go('/login'),
              );

              if (needsScroll) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: content,
                );
              }

              return Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: content,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RegisterContent extends StatelessWidget {
  const _RegisterContent({
    required this.compact,
    required this.keyboardVisible,
    required this.awaitingConfirmation,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.isResending,
    required this.feedbackMessage,
    required this.feedbackIsError,
    required this.onRegister,
    required this.onResend,
    required this.onSignIn,
  });

  final bool compact;
  final bool keyboardVisible;
  final bool awaitingConfirmation;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final bool isResending;
  final String? feedbackMessage;
  final bool feedbackIsError;
  final VoidCallback onRegister;
  final VoidCallback onResend;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final gap = compact ? AppSizes.md : AppSizes.xl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!awaitingConfirmation && !keyboardVisible) ...[
          _RegisterIntro(compact: compact),
          SizedBox(height: gap),
        ],
        if (awaitingConfirmation)
          _ConfirmationSentCard(
            onSignIn: onSignIn,
            onResend: onResend,
            isResending: isResending,
            feedbackMessage: feedbackMessage,
            feedbackIsError: feedbackIsError,
          )
        else
          NeoCard(
            padding: EdgeInsets.all(compact ? AppSizes.md : AppSizes.lg),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  NeoTextField(
                    label: 'Full name',
                    controller: nameController,
                    prefixIcon: Icons.person_outline,
                    validator: (value) => AppValidators.required(value, 'Name'),
                  ),
                  SizedBox(height: compact ? AppSizes.md : AppSizes.lg),
                  NeoTextField(
                    label: 'Email address',
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: AppValidators.email,
                  ),
                  SizedBox(height: compact ? AppSizes.md : AppSizes.lg),
                  NeoTextField(
                    label: 'Password',
                    controller: passwordController,
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    validator: AppValidators.password,
                  ),
                  SizedBox(height: compact ? AppSizes.lg : AppSizes.xl),
                  NeoButton(
                    label: 'Create account',
                    icon: Icons.arrow_forward_rounded,
                    isLoading: isLoading,
                    onPressed: onRegister,
                  ),
                ],
              ),
            ),
          ),
        if (!awaitingConfirmation && !keyboardVisible) ...[
          SizedBox(height: compact ? AppSizes.md : AppSizes.xl),
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
                onPressed: onSignIn,
                child: Text(
                  'Sign in',
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
      ],
    );
  }
}

class _RegisterIntro extends StatelessWidget {
  const _RegisterIntro({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      color: AppColors.green,
      borderRadius: 18,
      padding: EdgeInsets.all(compact ? AppSizes.md : AppSizes.lg),
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
              Icon(Icons.person_add_alt_1_outlined, size: compact ? 22 : 28),
              SizedBox(height: compact ? AppSizes.xs : AppSizes.md),
              Text('Start making.',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      )),
              if (!compact) ...[
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Create your verified Grow~ account. It works across IDEA Lab and Fab Lab.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
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
    required this.feedbackMessage,
    required this.feedbackIsError,
  });

  final VoidCallback onSignIn;
  final VoidCallback onResend;
  final bool isResending;
  final String? feedbackMessage;
  final bool feedbackIsError;

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
          if (feedbackMessage == null)
            Text(
              'Check your inbox and spam for a confirmation link. If you already have a Grow account, sign in or reset your password.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.35),
            )
          else
            _ConfirmationFeedback(
              message: feedbackMessage!,
              isError: feedbackIsError,
            ),
          const SizedBox(height: AppSizes.md),
          NeoButton(
            label: 'Resend email',
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
          const SizedBox(height: AppSizes.sm),
          Text(
            'No email? Check spam or ask the Grow administrator to check delivery settings. Old or used links cannot sign you in.',
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

class _ConfirmationFeedback extends StatelessWidget {
  const _ConfirmationFeedback({
    required this.message,
    required this.isError,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.red : AppColors.green;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .2),
          border: Border.all(color: AppColors.navy, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              size: 20,
              color: AppColors.navy,
            ),
            const SizedBox(width: AppSizes.xs),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.navy,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
