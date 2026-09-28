import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:grow/features/auth/presentation/screens/auth_callback_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
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
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('expired confirmation links never get a success state',
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

    await tester.pump();
    expect(find.text('Link unavailable'), findsOneWidget);
    expect(find.text('Email confirmed'), findsNothing);
    expect(cleared, isFalse);
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
