import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:grow/features/auth/presentation/screens/auth_callback_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grow/features/auth/data/auth_callback_guard.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AuthCallbackGuard.resetSerializationForTesting();
    await AuthCallbackGuard.restore();
  });

  test('interrupted callback guard survives a process-style restore', () async {
    await AuthCallbackGuard.begin();
    expect(AuthCallbackGuard.isActive, isTrue);
    expect(await AuthCallbackGuard.restore(), isTrue);

    await AuthCallbackGuard.clear();
    expect(await AuthCallbackGuard.restore(), isFalse);
  });

  testWidgets('confirmed email clears its temporary session then signs in',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/callback',
      routes: [
        GoRoute(
          path: '/callback',
          builder: (context, state) => AuthCallbackScreen(
            callbackUri: Uri.parse('/callback?code=fresh-code'),
            clearSession: _clearedSession,
            exchangeCallback: (uri) async => null,
            autoRedirectDelay: Duration.zero,
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Sign in')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.text('Checking your secure link…'), findsOneWidget);
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('expired confirmation links do not create a success state',
      (tester) async {
    var cleared = false;
    await tester.pumpWidget(
      MaterialApp(
        home: AuthCallbackScreen(
          callbackUri: Uri.parse('/callback?code=used-code'),
          exchangeCallback: (uri) async => throw const AuthException(
            'Code already used',
          ),
          clearSession: () async => cleared = true,
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Link unavailable'), findsOneWidget);
    expect(find.text('Email confirmed'), findsNothing);
    expect(cleared, isFalse);
    expect(AuthCallbackGuard.isActive, isFalse);
  });

  testWidgets('a used link does not sign out an existing account',
      (tester) async {
    var cleared = false;
    await tester.pumpWidget(MaterialApp(
      home: AuthCallbackScreen(
        callbackUri: Uri.parse('/callback?code=used-code'),
        currentSessionToken: () => 'already-signed-in',
        exchangeCallback: (_) async => throw const AuthException('Used code'),
        clearSession: () async => cleared = true,
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Link unavailable'), findsOneWidget);
    expect(cleared, isFalse);
    expect(AuthCallbackGuard.isActive, isFalse);
  });

  testWidgets('a new link waits until the previous callback is discarded',
      (tester) async {
    final first = Completer<String?>();
    final second = Completer<String?>();
    var firstCleared = false;
    var secondStarted = false;
    var currentToken = <String, String?>{'value': null};
    final router = GoRouter(
      initialLocation: '/callback?code=first',
      routes: [
        GoRoute(
          path: '/callback',
          builder: (context, state) {
            final code = state.uri.queryParameters['code'];
            return AuthCallbackScreen(
              key: ValueKey(state.uri.toString()),
              callbackUri: state.uri,
              currentSessionToken: () => currentToken['value'],
              exchangeCallback: (_) {
                if (code == 'first') return first.future;
                secondStarted = true;
                return second.future;
              },
              clearSession: () async {
                if (code == 'first') firstCleared = true;
                currentToken['value'] = null;
              },
              autoRedirectDelay: Duration.zero,
            );
          },
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Sign in')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();
    expect(AuthCallbackGuard.isActive, isTrue);
    router.go('/callback?code=second');
    await tester.pump();
    expect(secondStarted, isFalse);

    currentToken['value'] = 'temporary-first-session';
    first.complete();
    await tester.pumpAndSettle();
    expect(firstCleared, isTrue);
    expect(secondStarted, isTrue);

    currentToken['value'] = 'temporary-second-session';
    second.complete();
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
    expect(AuthCallbackGuard.isActive, isFalse);
  });

  testWidgets('slow exchange cannot time out into a late login',
      (tester) async {
    final pendingExchange = Completer<String?>();
    var cleared = false;
    final router = GoRouter(
      initialLocation: '/callback',
      routes: [
        GoRoute(
          path: '/callback',
          builder: (context, state) => AuthCallbackScreen(
            callbackUri: Uri.parse('/callback?code=slow-code'),
            exchangeCallback: (_) => pendingExchange.future,
            clearSession: () async => cleared = true,
            autoRedirectDelay: Duration.zero,
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Sign in')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();
    expect(AuthCallbackGuard.isActive, isTrue);
    await tester.pump(const Duration(seconds: 13));
    expect(find.text('Still checking your link…'), findsOneWidget);
    expect(find.text('Sign in'), findsNothing);
    expect(cleared, isFalse);

    pendingExchange.complete();
    await tester.pumpAndSettle();
    expect(cleared, isTrue);
    expect(AuthCallbackGuard.isActive, isFalse);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('bare callback cannot confirm or sign out an existing session',
      (tester) async {
    var exchanged = false;
    var cleared = false;
    await tester.pumpWidget(
      MaterialApp(
        home: AuthCallbackScreen(
          callbackUri: Uri.parse('/callback'),
          exchangeCallback: (uri) async {
            exchanged = true;
            return null;
          },
          clearSession: () async => cleared = true,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Link unavailable'), findsOneWidget);
    expect(exchanged, isFalse);
    expect(cleared, isFalse);
  });

  testWidgets('a caller-supplied recovery type cannot skip code exchange',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthCallbackScreen(
          callbackUri: Uri.parse('/callback?type=recovery'),
          exchangeCallback: (uri) async => 'passwordRecovery',
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Link unavailable'), findsOneWidget);
    expect(find.text('Recovery link verified'), findsNothing);
  });

  testWidgets('a foreign callback host cannot exchange a code', (tester) async {
    var exchanged = false;
    await tester.pumpWidget(
      MaterialApp(
        home: AuthCallbackScreen(
          callbackUri: Uri.parse('https://example.invalid/callback?code=code'),
          exchangeCallback: (uri) async {
            exchanged = true;
            return null;
          },
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Link unavailable'), findsOneWidget);
    expect(exchanged, isFalse);
  });

  testWidgets('valid recovery callbacks only enter the reset-password route',
      (tester) async {
    var pendingRecoveryUserId = '';
    final router = GoRouter(
      initialLocation: '/callback',
      routes: [
        GoRoute(
          path: '/callback',
          builder: (context, state) => AuthCallbackScreen(
            callbackUri: Uri.parse('/callback?code=recovery-code'),
            exchangeCallback: (uri) async => 'passwordRecovery',
            recoveryUserId: () async => 'recovery-user-123',
            markRecoveryPending: (userId) async {
              pendingRecoveryUserId = userId;
            },
            recoveryRedirectDelay: Duration.zero,
          ),
        ),
        GoRoute(
          path: '/reset-password',
          builder: (context, state) => const Scaffold(
            body: Text('Reset password'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(pendingRecoveryUserId, 'recovery-user-123');
    expect(find.text('Reset password'), findsOneWidget);
  });

  testWidgets('invalid callbacks never receive a success state',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthCallbackScreen(
          resolveCallback: () async => AuthCallbackResult.invalid,
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Link unavailable'), findsOneWidget);
    expect(find.text('Email confirmed'), findsNothing);
  });

  testWidgets('callback timeout gives a recovery action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthCallbackScreen(
          resolveCallback: () async => AuthCallbackResult.timeout,
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Link check timed out'), findsOneWidget);
    expect(find.text('Request a new link'), findsOneWidget);
  });
}

Future<void> _clearedSession() async {}
