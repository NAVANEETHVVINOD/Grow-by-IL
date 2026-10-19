import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/password_recovery_session.dart';
import '../../data/auth_callback_guard.dart';

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
    this.resolveCallback,
    this.exchangeCallback,
    this.currentSessionToken,
    this.recoveryUserId,
    this.markRecoveryPending,
    this.autoRedirectDelay = const Duration(seconds: 3),
    this.recoveryRedirectDelay = const Duration(milliseconds: 350),
  });

  final Uri? callbackUri;

  @visibleForTesting
  final Future<void> Function()? clearSession;

  @visibleForTesting
  final Future<AuthCallbackResult> Function()? resolveCallback;

  /// Returns the redirect type only after this exact callback was exchanged.
  @visibleForTesting
  final Future<String?> Function(Uri uri)? exchangeCallback;

  @visibleForTesting
  final String? Function()? currentSessionToken;

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
  Timer? _slowExchangeTimer;
  String? _sessionTokenBeforeExchange;

  @override
  void initState() {
    super.initState();
    unawaited(AuthCallbackGuard.runSerialized(_handleCallback));
  }

  @override
  void dispose() {
    _slowExchangeTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleCallback() async {
    if (!mounted) return;
    final result = await (widget.resolveCallback?.call() ?? _resolveCallback());
    _slowExchangeTimer?.cancel();
    if (!mounted) {
      // Exchanging a PKCE code can persist a temporary session even when its
      // screen has been replaced. Never let that session become Grow login.
      await _discardTemporarySession();
      return;
    }

    switch (result) {
      case AuthCallbackResult.confirmation:
        await _completeConfirmation();
        return;
      case AuthCallbackResult.recovery:
        await _beginRecovery();
        return;
      case AuthCallbackResult.expiredOrUsed:
        await _discardTemporarySession();
        if (mounted) setState(() => _state = _CallbackState.expiredOrUsed);
        return;
      case AuthCallbackResult.invalid:
        await _discardTemporarySession();
        if (mounted) setState(() => _state = _CallbackState.invalid);
        return;
      case AuthCallbackResult.networkFailure:
        await _discardTemporarySession();
        if (mounted) setState(() => _state = _CallbackState.networkFailure);
        return;
      case AuthCallbackResult.timeout:
        await _discardTemporarySession();
        if (mounted) setState(() => _state = _CallbackState.timeout);
        return;
    }
  }

  Future<void> _completeConfirmation() async {
    try {
      await (widget.clearSession?.call() ??
          Supabase.instance.client.auth.signOut());
      await AuthCallbackGuard.clear();
      if (!mounted) return;
      setState(() => _state = _CallbackState.confirmed);
      await Future<void>.delayed(widget.autoRedirectDelay);
      if (mounted) context.go('/login');
    } catch (_) {
      await _discardTemporarySession();
      if (mounted) setState(() => _state = _CallbackState.networkFailure);
    }
  }

  Future<void> _beginRecovery() async {
    try {
      final userId = await (widget.recoveryUserId?.call() ??
          Future.value(Supabase.instance.client.auth.currentUser?.id));
      if (userId == null) {
        await _discardTemporarySession();
        if (mounted) setState(() => _state = _CallbackState.invalid);
        return;
      }
      await (widget.markRecoveryPending?.call(userId) ??
          PasswordRecoverySession.markPendingFor(userId));
      await AuthCallbackGuard.clear();
      if (!mounted) return;
      setState(() => _state = _CallbackState.recoveryReady);
      await Future<void>.delayed(widget.recoveryRedirectDelay);
      if (mounted) context.go('/reset-password');
    } catch (_) {
      await _discardTemporarySession();
      if (mounted) setState(() => _state = _CallbackState.networkFailure);
    }
  }

  Future<void> _discardTemporarySession() async {
    if (!AuthCallbackGuard.isActive) return;
    try {
      final currentToken = _currentSessionToken();
      if (currentToken != null && currentToken != _sessionTokenBeforeExchange) {
        await (widget.clearSession?.call() ??
            Supabase.instance.client.auth.signOut());
      }
      await AuthCallbackGuard.clear();
    } catch (_) {
      // Retain the persistent guard if local session clearance is uncertain.
      // On the next launch main.dart will discard the restored session.
    }
  }

  String? _currentSessionToken() {
    if (widget.currentSessionToken != null) {
      return widget.currentSessionToken!();
    }
    // Injected exchange tests do not initialize Supabase. Production always
    // reads the currently persisted GoTrue session.
    if (widget.exchangeCallback != null || widget.resolveCallback != null) {
      return null;
    }
    return Supabase.instance.client.auth.currentSession?.accessToken;
  }

  Future<AuthCallbackResult> _resolveCallback() async {
    final uri = widget.callbackUri;
    if (uri == null ||
        uri.path != '/callback' ||
        (uri.hasScheme &&
            (uri.scheme != 'com.idealab.mec.grow' || uri.host != 'auth'))) {
      return AuthCallbackResult.invalid;
    }
    if (_hasAuthError(uri)) return AuthCallbackResult.expiredOrUsed;
    // A previously saved session is never evidence for a new confirmation.
    // Supabase's default deep-link observer is disabled in main.dart so this
    // route is the sole owner of exchanging the single-use PKCE code.
    if (!uri.queryParameters.containsKey('code') ||
        uri.queryParameters['code']!.isEmpty) {
      return AuthCallbackResult.invalid;
    }

    try {
      _sessionTokenBeforeExchange = _currentSessionToken();
      await AuthCallbackGuard.begin();
      _slowExchangeTimer = Timer(const Duration(seconds: 12), () {
        if (mounted && _state == _CallbackState.processing) {
          setState(() => _state = _CallbackState.slow);
        }
      });
      final exchange = widget.exchangeCallback ??
          (Uri link) async =>
              (await Supabase.instance.client.auth.getSessionFromUrl(link))
                  .redirectType;
      // Do not time out the underlying exchange: Future.timeout does not
      // cancel it, so a late result could silently create a Grow session.
      final redirectType = await exchange(uri);
      // PKCE recovery type comes from the SDK's stored verifier, not an
      // untrusted `type` query parameter supplied by the caller.
      return redirectType == AuthChangeEvent.passwordRecovery.name
          ? AuthCallbackResult.recovery
          : AuthCallbackResult.confirmation;
    } on AuthException {
      return AuthCallbackResult.expiredOrUsed;
    } catch (_) {
      return AuthCallbackResult.networkFailure;
    }
  }

  bool _hasAuthError(Uri? uri) {
    if (uri == null) return false;
    final fragment = _fragmentParameters(uri);
    return uri.queryParameters.containsKey('error') ||
        uri.queryParameters.containsKey('error_description') ||
        fragment.containsKey('error') ||
        fragment.containsKey('error_description');
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
    return PopScope(
        canPop: false,
        child: Scaffold(
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
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
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
        ));
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
      _CallbackState.slow => const _CallbackContent(
          title: 'Still checking your link…',
          description:
              'Verification is taking longer than expected. Keep Grow open, or restart it to safely try again.',
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
    final isProblem = state != _CallbackState.processing &&
        state != _CallbackState.slow &&
        !isSuccess;
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
  slow,
  confirmed,
  recoveryReady,
  expiredOrUsed,
  invalid,
  networkFailure,
  timeout,
}
