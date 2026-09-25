import 'package:flutter/foundation.dart';
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
import '../../data/google_auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authRepositoryProvider).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (!mounted) return;

      final user = await ref.read(authRepositoryProvider).getCurrentUser();
      if (!mounted) return;

      // A verified account is not the same as a completed Grow profile.
      // New users always complete mandatory onboarding before Home.
      context.go(user?.profileCompleted == true ? '/home' : '/profile-setup');
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

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      final response =
          await ref.read(authRepositoryProvider).signInWithGoogle();
      if (response == null) return; // user cancelled
      if (!mounted) return;

      // Check profile completion
      final user = await ref.read(authRepositoryProvider).getCurrentUser();
      if (!mounted) return;

      context.go(user?.profileCompleted == true ? '/home' : '/profile-setup');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(handleSupabaseError(e)),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final googleAvailable = GoogleAuthService.isConfigured;
    final keyboardIsVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    return PopScope(
      canPop: false, // prevents back to onboarding/splash
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Keep the resting portrait screen fully visible. Scrolling is
              // reserved for the keyboard and genuinely short viewports.
              final needsScroll =
                  keyboardIsVisible || constraints.maxHeight < 600;
              final content = _LoginContent(
                // Most tall Android phones still have under 900 logical pixels
                // after system bars. The spacious variant overflows there.
                compact: constraints.maxHeight < 900 || keyboardIsVisible,
                googleAvailable: googleAvailable,
                isLoading: _isLoading,
                isGoogleLoading: _isGoogleLoading,
                formKey: _formKey,
                emailController: _emailController,
                passwordController: _passwordController,
                onLogin: _login,
                onGoogleLogin: _handleGoogleSignIn,
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

class _LoginContent extends StatelessWidget {
  const _LoginContent({
    required this.compact,
    required this.googleAvailable,
    required this.isLoading,
    required this.isGoogleLoading,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    required this.onGoogleLogin,
  });

  final bool compact;
  final bool googleAvailable;
  final bool isLoading;
  final bool isGoogleLoading;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;
  final VoidCallback onGoogleLogin;

  @override
  Widget build(BuildContext context) {
    final sectionGap = compact ? AppSizes.md : AppSizes.lg;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _LoginIntro(compact: compact),
        SizedBox(height: sectionGap),
        NeoCard(
          padding: EdgeInsets.all(compact ? AppSizes.md : AppSizes.lg),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                NeoTextField(
                  label: 'Email Address',
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go('/forgot-password'),
                    child: const Text('Forgot password?'),
                  ),
                ),
                SizedBox(height: compact ? AppSizes.sm : AppSizes.md),
                NeoButton(
                  label: 'Sign In',
                  isLoading: isLoading,
                  onPressed: onLogin,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        if (!compact) const _EmailVerificationHint(),
        if (!kIsWeb) ...[
          SizedBox(height: compact ? AppSizes.md : AppSizes.lg),
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.textSecondary)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
              const Expanded(child: Divider(color: AppColors.textSecondary)),
            ],
          ),
          SizedBox(height: compact ? AppSizes.md : AppSizes.lg),
          if (googleAvailable)
            NeoButton(
              label: 'Continue with Google',
              color: Colors.white,
              textColor: AppColors.navy,
              icon: Icons.account_circle_outlined,
              isLoading: isGoogleLoading,
              onPressed: onGoogleLogin,
            )
          else
            const _GoogleSetupNotice(compact: true),
        ],
        SizedBox(height: compact ? AppSizes.md : AppSizes.lg),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            Text(
              'Don\'t have an account?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            TextButton(
              onPressed: () => context.go('/register'),
              child: Text(
                'Create Account',
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
    );
  }
}

class _LoginIntro extends StatelessWidget {
  const _LoginIntro({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      color: AppColors.cobalt,
      borderRadius: 18,
      padding: EdgeInsets.all(compact ? AppSizes.md : AppSizes.lg),
      child: Stack(
        children: [
          Positioned(
            right: -4,
            top: -14,
            child: Text(
              '///',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy.withValues(alpha: .12),
                  ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.login_rounded, size: compact ? 22 : 28),
              SizedBox(height: compact ? AppSizes.xs : AppSizes.md),
              Text('Welcome back.',
                  style: (compact
                          ? Theme.of(context).textTheme.titleLarge
                          : Theme.of(context).textTheme.headlineMedium)
                      ?.copyWith(
                    fontWeight: FontWeight.w800,
                  )),
              if (!compact) ...[
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Sign in to pick up your projects, lab sessions, and plans.',
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

class _EmailVerificationHint extends StatelessWidget {
  const _EmailVerificationHint();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.mark_email_read_outlined,
            size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Text(
            'New here? Confirm your email first, then return here and sign in.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.35,
                  color: AppColors.textSecondary,
                ),
          ),
        ),
      ],
    );
  }
}

class _GoogleSetupNotice extends StatelessWidget {
  const _GoogleSetupNotice({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      color: Colors.white,
      padding: EdgeInsets.all(compact ? AppSizes.sm : AppSizes.md),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.textSecondary),
          SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              'Google sign-in is being configured. Use your verified email and password for now.',
            ),
          ),
        ],
      ),
    );
  }
}
