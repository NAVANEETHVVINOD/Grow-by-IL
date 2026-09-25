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

/// Starts a security-safe password-recovery request.
///
/// The success copy is deliberately identical for every accepted request so
/// this screen does not disclose whether an email address has an account.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  var _isLoading = false;
  var _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendRecoveryEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).requestPasswordRecovery(
            email: _emailController.text.trim(),
          );
      if (mounted) setState(() => _sent = true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(handleSupabaseError(error)),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final content = Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: _sent
                  ? _RecoveryEmailSent(onSignIn: () => context.go('/login'))
                  : _RecoveryForm(
                      formKey: _formKey,
                      emailController: _emailController,
                      isLoading: _isLoading,
                      onSend: _sendRecoveryEmail,
                    ),
            );
            return constraints.maxHeight < 600
                ? SingleChildScrollView(child: content)
                : content;
          },
        ),
      ),
    );
  }
}

class _RecoveryForm extends StatelessWidget {
  const _RecoveryForm({
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    required this.onSend,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NeoCard(
          color: AppColors.cobalt,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_reset_rounded, size: 30),
              const SizedBox(height: AppSizes.md),
              Text(
                'Reset your password.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                'We will send a secure recovery link to your email address.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.xl),
        NeoCard(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                NeoTextField(
                  label: 'Email address',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: AppValidators.email,
                ),
                const SizedBox(height: AppSizes.xl),
                NeoButton(
                  label: 'Send recovery email',
                  icon: Icons.send_outlined,
                  isLoading: isLoading,
                  onPressed: onSend,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RecoveryEmailSent extends StatelessWidget {
  const _RecoveryEmailSent({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      color: AppColors.yellow,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.mark_email_read_outlined, size: 36),
          const SizedBox(height: AppSizes.md),
          Text(
            'Check your inbox.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'If an account can be recovered with this email, you will receive a secure link. Open the newest link to set a new password.',
            style:
                Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
          const SizedBox(height: AppSizes.xl),
          NeoButton(
            label: 'Back to sign in',
            icon: Icons.login_rounded,
            color: AppColors.navy,
            textColor: Colors.white,
            onPressed: onSignIn,
          ),
        ],
      ),
    );
  }
}
