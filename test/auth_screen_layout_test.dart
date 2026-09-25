import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/auth/presentation/screens/login_screen.dart';
import 'package:grow/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:grow/features/auth/presentation/screens/register_screen.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first
        .physicalSize = const Size(360, 752);
    TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first
        .devicePixelRatio = 1;
  });

  tearDown(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first
        .resetPhysicalSize();
    TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first
        .resetDevicePixelRatio();
  });

  Future<void> pumpRoute(
    WidgetTester tester,
    Widget screen, {
    AuthRepository? repository,
  }) async {
    final router = GoRouter(
      initialLocation: '/test',
      routes: [
        GoRoute(path: '/test', builder: (_, __) => screen),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            repository ?? _MockAuthRepository(),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('login fits a standard portrait viewport without scrolling',
      (tester) async {
    await pumpRoute(tester, const LoginScreen());

    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('registration and confirmation fit without scrolling',
      (tester) async {
    final repository = _MockAuthRepository();
    when(() => repository.signUp(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => false);
    await pumpRoute(
      tester,
      const RegisterScreen(),
      repository: repository,
    );

    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.enterText(find.byType(TextFormField).at(0), 'Ada Maker');
    await tester.enterText(find.byType(TextFormField).at(1), 'ada@example.org');
    await tester.enterText(find.byType(TextFormField).at(2), 'StrongPass123');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Verify your email.'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('onboarding fits a standard portrait viewport without scrolling',
      (tester) async {
    await pumpRoute(tester, const OnboardingScreen());

    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
