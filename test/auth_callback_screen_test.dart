import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:grow/features/auth/presentation/screens/auth_callback_screen.dart';

void main() {
  testWidgets('confirmed email clears its temporary session then signs in',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/callback',
      routes: [
        GoRoute(
          path: '/callback',
          builder: (context, state) => AuthCallbackScreen(
            clearSession: _clearedSession,
            isConfirmationSession: () async => true,
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
    await tester.pumpWidget(
      MaterialApp(
        home: AuthCallbackScreen(
          isConfirmationSession: () async => false,
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Link unavailable'), findsOneWidget);
    expect(find.text('Email confirmed'), findsNothing);
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
            resolveCallback: () async => AuthCallbackResult.recovery,
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
