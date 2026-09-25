import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/supabase_error_handler.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/repositories/supabase_client.dart';
import '../../../../shared/widgets/neo_button.dart';
import '../../../../shared/widgets/neo_card.dart';
import '../../../../shared/widgets/neo_text_field.dart';
import '../../data/auth_repository.dart';
import '../../data/password_recovery_session.dart';

/// Completes a password reset only after Supabase has established a valid
/// recovery session from the email link.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({
    super.key,
    this.hasRecoverySession,
    this.completeRecovery,
    this.clearRecoveryState,
  });

  @visibleForTesting
  final Future<bool> Function()? hasRecoverySession;

  @visibleForTesting
  final Future<void> Function(String password)? completeRecovery;

  @visibleForTesting
  final Future<void> Function()? clearRecoveryState;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  var _isCheckingSession = true;
  var _hasValidRecoverySession = false;
  var _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _checkRecoverySession();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _checkRecoverySession() async {
    try {
      final isValid = await (widget.hasRecoverySession?.call() ??
          _defaultHasRecoverySession());
      if (mounted) setState(() => _hasValidRecoverySession = isValid);
    } finally {
      if (mounted) setState(() => _isCheckingSession = false);
    }
  }

  Future<bool> _defaultHasRecoverySession() async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;
    return PasswordRecoverySession.isPendingFor(user.id);
  }

  Future<void> _completePasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final password = _passwordController.text;
      await (widget.completeRecovery?.call(password) ??
          ref
              .read(authRepositoryProvider)
              .completePasswordRecovery(password: password));
      await (widget.clearRecoveryState?.call() ??
          PasswordRecoverySession.clear());
      if (mounted) context.go('/login');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(handleSupabaseError(error)),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _cancel() async {
    await (widget.clearRecoveryState?.call() ??
        PasswordRecoverySession.clear());
    if (!mounted) return;
    await supabase.auth.signOut();
    if (mounted) context.go('/login');
  }

  String? _validateConfirmation(String? value) {
    final required = AppValidators.required(value, 'Password confirmation');
    if (required != null) return required;
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSession) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_hasValidRecoverySession) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: NeoCard(
              color: AppColors.yellow,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.link_off_rounded, size: 36),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'Recovery link unavailable.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  const Text(
                    'This link may be expired, already used, or invalid. Request a new password-recovery email to continue.',
                  ),
                  const SizedBox(height: AppSizes.xl),
                  NeoButton(
                    label: 'Request a new link',
                    icon: Icons.refresh_rounded,
                    onPressed: () => context.go('/forgot-password'),
                  ),
                  const SizedBox(height: AppSizes.md),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Back to sign in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _cancel,
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final content = Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: NeoCard(
                color: AppColors.green,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.password_rounded, size: 34),
                      const SizedBox(height: AppSizes.md),
                      Text(
                        'Choose a new password.',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      const Text(
                        'Use at least 6 characters. You will sign in normally after resetting it.',
                      ),
                      const SizedBox(height: AppSizes.xl),
                      NeoTextField(
                        label: 'New password',
                        controller: _passwordController,
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                        validator: AppValidators.password,
                      ),
                      const SizedBox(height: AppSizes.lg),
                      NeoTextField(
                        label: 'Confirm new password',
                        controller: _confirmationController,
                        obscureText: true,
                        prefixIcon: Icons.lock_reset_outlined,
                        validator: _validateConfirmation,
                      ),
                      const SizedBox(height: AppSizes.xl),
                      NeoButton(
                        label: 'Update password',
                        icon: Icons.check_rounded,
                        isLoading: _isSubmitting,
                        onPressed: _completePasswordReset,
                      ),
                    ],
                  ),
                ),
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
