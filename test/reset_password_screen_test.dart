import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:grow/features/auth/presentation/screens/reset_password_screen.dart';

void main() {
  testWidgets('invalid recovery sessions offer a safe next action',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ResetPasswordScreen(
            hasRecoverySession: _noRecoverySession,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Recovery link unavailable.'), findsOneWidget);
    expect(find.text('Request a new link'), findsOneWidget);
  });

  testWidgets('mismatched passwords cannot be submitted', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ResetPasswordScreen(
            hasRecoverySession: _validRecoverySession,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'newpassword');
    await tester.enterText(
        find.byType(TextFormField).at(1), 'differentpassword');
    await tester.tap(find.text('Update password'));
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('valid recovery updates password then returns to sign in',
      (tester) async {
    var updatedPassword = '';
    var recoveryStateCleared = false;
    final router = GoRouter(
      initialLocation: '/reset-password',
      routes: [
        GoRoute(
          path: '/reset-password',
          builder: (context, state) => ResetPasswordScreen(
            hasRecoverySession: _validRecoverySession,
            completeRecovery: (password) async {
              updatedPassword = password;
            },
            clearRecoveryState: () async {
              recoveryStateCleared = true;
            },
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Sign in')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'newpassword');
    await tester.enterText(find.byType(TextFormField).at(1), 'newpassword');
    await tester.tap(find.text('Update password'));
    await tester.pumpAndSettle();

    expect(updatedPassword, 'newpassword');
    expect(recoveryStateCleared, isTrue);
    expect(find.text('Sign in'), findsOneWidget);
  });
}

Future<bool> _validRecoverySession() async => true;

Future<bool> _noRecoverySession() async => false;
