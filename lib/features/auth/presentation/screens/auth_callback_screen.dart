import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/password_recovery_session.dart';

/// The terminal outcome of a Supabase mobile callback.
enum AuthCallbackResult {
  confirmation,
  recovery,
  expiredOrUsed,
  invalid,
  networkFailure,
  timeout,
}

/// Handles verified Supabase callbacks without trusting URL parameters alone.
///
/// Confirmation creates no durable Grow login: its temporary session is
/// cleared and the member signs in normally. Recovery keeps the validated
/// short-lived session only long enough to update the password.
class AuthCallbackScreen extends StatefulWidget {
  const AuthCallbackScreen({
    super.key,
    this.callbackUri,
    this.clearSession,
    this.isConfirmationSession,
    this.resolveCallback,
    this.recoveryUserId,
    this.markRecoveryPending,
    this.autoRedirectDelay = const Duration(seconds: 3),
    this.recoveryRedirectDelay = const Duration(milliseconds: 350),
  });

  final Uri? callbackUri;

  @visibleForTesting
  final Future<void> Function()? clearSession;

  /// Compatibility seam for the existing confirmation test.
  @visibleForTesting
  final Future<bool> Function()? isConfirmationSession;

  @visibleForTesting
  final Future<AuthCallbackResult> Function()? resolveCallback;

  @visibleForTesting
  final Future<String?> Function()? recoveryUserId;

  @visibleForTesting
  final Future<void> Function(String userId)? markRecoveryPending;

  @visibleForTesting
  final Duration autoRedirectDelay;

  @visibleForTesting
  final Duration recoveryRedirectDelay;

  @override
  State<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends State<AuthCallbackScreen> {
  var _state = _CallbackState.processing;

  @override
  void initState() {
    super.initState();
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    final result = await (widget.resolveCallback?.call() ?? _resolveCallback());
    if (!mounted) return;

    switch (result) {
      case AuthCallbackResult.confirmation:
        await _completeConfirmation();
        return;
      case AuthCallbackResult.recovery:
        await _beginRecovery();
        return;
      case AuthCallbackResult.expiredOrUsed:
        setState(() => _state = _CallbackState.expiredOrUsed);
        return;
      case AuthCallbackResult.invalid:
        setState(() => _state = _CallbackState.invalid);
        return;
      case AuthCallbackResult.networkFailure:
        setState(() => _state = _CallbackState.networkFailure);
        return;
      case AuthCallbackResult.timeout:
        setState(() => _state = _CallbackState.timeout);
        return;
    }
  }

  Future<void> _completeConfirmation() async {
    try {
      await (widget.clearSession?.call() ??
          Supabase.instance.client.auth.signOut());
      if (!mounted) return;
      setState(() => _state = _CallbackState.confirmed);
      await Future<void>.delayed(widget.autoRedirectDelay);
      if (mounted) context.go('/login');
    } catch (_) {
      if (mounted) setState(() => _state = _CallbackState.networkFailure);
    }
  }

  Future<void> _beginRecovery() async {
    final userId = await (widget.recoveryUserId?.call() ??
        Future.value(Supabase.instance.client.auth.currentUser?.id));
    if (userId == null) {
      setState(() => _state = _CallbackState.invalid);
      return;
    }

    try {
      await (widget.markRecoveryPending?.call(userId) ??
          PasswordRecoverySession.markPendingFor(userId));
      if (!mounted) return;
      setState(() => _state = _CallbackState.recoveryReady);
      await Future<void>.delayed(widget.recoveryRedirectDelay);
      if (mounted) context.go('/reset-password');
    } catch (_) {
      if (mounted) setState(() => _state = _CallbackState.networkFailure);
    }
  }

  Future<AuthCallbackResult> _resolveCallback() async {
    if (widget.isConfirmationSession != null) {
      return await widget.isConfirmationSession!()
          ? AuthCallbackResult.confirmation
          : AuthCallbackResult.expiredOrUsed;
    }

    final client = Supabase.instance.client;
    if (_hasAuthError(widget.callbackUri)) return AuthCallbackResult.invalid;

    // The SDK can process an app link before this widget is mounted. A session
    // alone proves neither type, so use it only after checking the recovery
    // type supplied by Supabase or as a confirmation session fallback.
    if (client.auth.currentSession != null) {
      return _isRecoveryUri(widget.callbackUri)
          ? AuthCallbackResult.recovery
          : AuthCallbackResult.confirmation;
    }

    try {
      return await client.auth.onAuthStateChange
          .where(
            (event) =>
                event.event == AuthChangeEvent.passwordRecovery ||
                event.event == AuthChangeEvent.signedIn,
          )
          .map(
            (event) => event.event == AuthChangeEvent.passwordRecovery
                ? AuthCallbackResult.recovery
                : event.session == null
                    ? AuthCallbackResult.invalid
                    : AuthCallbackResult.confirmation,
          )
          .first
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => AuthCallbackResult.timeout,
          );
    } on AuthException {
      return AuthCallbackResult.expiredOrUsed;
    } catch (_) {
      return AuthCallbackResult.networkFailure;
    }
  }

  bool _hasAuthError(Uri? uri) {
    if (uri == null) return false;
    return uri.queryParameters.containsKey('error') ||
        _fragmentParameters(uri).containsKey('error');
  }

  bool _isRecoveryUri(Uri? uri) {
    if (uri == null) return false;
    final type =
        uri.queryParameters['type'] ?? _fragmentParameters(uri)['type'];
    return type == 'recovery';
  }

  Map<String, String> _fragmentParameters(Uri uri) {
    if (uri.fragment.isEmpty) return const {};
    try {
      return Uri.splitQueryString(uri.fragment);
    } catch (_) {
      return const {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _CallbackContent.forState(_state);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: Column(
                key: ValueKey(_state),
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CallbackMark(state: _state),
                  const SizedBox(height: 24),
                  Text(
                    content.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(content.description, textAlign: TextAlign.center),
                  if (content.actionLabel != null) ...[
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => context.go(content.actionRoute!),
                      child: Text(content.actionLabel!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CallbackContent {
  const _CallbackContent({
    required this.title,
    required this.description,
    this.actionLabel,
    this.actionRoute,
  });

  final String title;
  final String description;
  final String? actionLabel;
  final String? actionRoute;

  factory _CallbackContent.forState(_CallbackState state) {
    return switch (state) {
      _CallbackState.processing => const _CallbackContent(
          title: 'Checking your secure link…',
          description: 'Please wait while Grow verifies this request.',
        ),
      _CallbackState.confirmed => const _CallbackContent(
          title: 'Email confirmed',
          description: 'You are verified. Taking you to sign in…',
        ),
      _CallbackState.recoveryReady => const _CallbackContent(
          title: 'Recovery link verified',
          description: 'You can now choose a new password.',
        ),
      _CallbackState.expiredOrUsed => const _CallbackContent(
          title: 'Link unavailable',
          description:
              'This link is expired or already used. Request a fresh link to continue.',
          actionLabel: 'Request a new link',
          actionRoute: '/forgot-password',
        ),
      _CallbackState.invalid => const _CallbackContent(
          title: 'Link unavailable',
          description:
              'This link is invalid. Sign in or request a new recovery email.',
          actionLabel: 'Go to sign in',
          actionRoute: '/login',
        ),
      _CallbackState.networkFailure => const _CallbackContent(
          title: 'We could not verify this link',
          description:
              'Check your connection, then open the newest email link again.',
          actionLabel: 'Go to sign in',
          actionRoute: '/login',
        ),
      _CallbackState.timeout => const _CallbackContent(
          title: 'Link check timed out',
          description:
              'The connection took too long. Try the newest email link again or request another one.',
          actionLabel: 'Request a new link',
          actionRoute: '/forgot-password',
        ),
    };
  }
}

class _CallbackMark extends StatelessWidget {
  const _CallbackMark({required this.state});

  final _CallbackState state;

  @override
  Widget build(BuildContext context) {
    final isSuccess = state == _CallbackState.confirmed ||
        state == _CallbackState.recoveryReady;
    final isProblem = state != _CallbackState.processing && !isSuccess;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: isSuccess
            ? const Color(0xFFC9F3D1)
            : isProblem
                ? const Color(0xFFFFD5D5)
                : const Color(0xFFFFF3AD),
        border: Border.all(color: const Color(0xFF111111), width: 2),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0xFF111111), offset: Offset(4, 4)),
        ],
      ),
      child: Icon(
        isSuccess
            ? Icons.check_rounded
            : isProblem
                ? Icons.link_off_rounded
                : Icons.shield_outlined,
        size: 40,
      ),
    );
  }
}

enum _CallbackState {
  processing,
  confirmed,
  recoveryReady,
  expiredOrUsed,
  invalid,
  networkFailure,
  timeout,
}
