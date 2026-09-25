import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/auth/presentation/screens/login_screen.dart';
import 'package:grow/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:grow/features/auth/presentation/screens/profile_setup_screen.dart';
import 'package:grow/features/auth/presentation/screens/register_screen.dart';
import 'package:grow/shared/models/user_model.dart';
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
    UserModel? user,
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
          if (user != null)
            currentUserProvider.overrideWith((ref) async => user),
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

  testWidgets('login fits the I2301 portrait safe area without scrolling',
      (tester) async {
    // The physical device is 1080x2400 at 440 dpi (about 393x873 dp).
    // Allow for system bars: the app receives roughly 824 dp of height.
    tester.view.physicalSize = const Size(393, 824);
    await pumpRoute(tester, const LoginScreen());

    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.text('Create Account'), findsOneWidget);
    expect(tester.getRect(find.text('Create Account')).bottom,
        lessThanOrEqualTo(824));
    expect(tester.takeException(), isNull);
  });

  testWidgets('login action stays visible when the keyboard is open',
      (tester) async {
    await pumpRoute(tester, const LoginScreen());

    await tester.tap(find.byType(TextFormField).last);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pumpAndSettle();

    final availableHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio - 280;
    for (var index = 0;
        index < find.byType(TextFormField).evaluate().length;
        index++) {
      final fieldRect = tester.getRect(find.byType(TextFormField).at(index));
      expect(fieldRect.top, greaterThanOrEqualTo(0));
      expect(fieldRect.bottom, lessThanOrEqualTo(availableHeight));
    }
    expect(tester.getRect(find.text('Sign In')).bottom,
        lessThanOrEqualTo(availableHeight));
    expect(tester.takeException(), isNull);
    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pumpAndSettle();
  });

  testWidgets('registration and confirmation fit without scrolling',
      (tester) async {
    final repository = _MockAuthRepository();
    when(() => repository.signUp(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => false);
    when(() => repository.resendSignupConfirmation(email: any(named: 'email')))
        .thenAnswer((_) async {});
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

    await tester.tap(find.text('Resend email'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('fresh email was requested'),
      findsOneWidget,
    );
    expect(find.byType(SnackBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('confirmation resend feedback stays visible on a compact phone',
      (tester) async {
    tester.view.physicalSize = const Size(393, 824);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _MockAuthRepository();
    when(() => repository.signUp(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => false);
    when(() => repository.resendSignupConfirmation(email: any(named: 'email')))
        .thenAnswer((_) async {});
    await pumpRoute(
      tester,
      const RegisterScreen(),
      repository: repository,
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Ada Maker');
    await tester.enterText(find.byType(TextFormField).at(1), 'ada@example.org');
    await tester.enterText(find.byType(TextFormField).at(2), 'StrongPass123');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Resend email'));
    await tester.pumpAndSettle();

    final feedback = find.textContaining('fresh email was requested');
    expect(feedback, findsOneWidget);
    expect(tester.getRect(feedback).top, greaterThanOrEqualTo(0));
    expect(tester.getRect(feedback).bottom, lessThanOrEqualTo(824));
    expect(tester.getRect(find.text('Go to sign in')).bottom,
        lessThanOrEqualTo(824));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'registration fits the I2301 portrait safe area without scrolling',
      (tester) async {
    tester.view.physicalSize = const Size(393, 824);
    await pumpRoute(tester, const RegisterScreen());

    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.text('Create account'), findsOneWidget);
    expect(tester.getRect(find.text('Create account')).bottom,
        lessThanOrEqualTo(824));
    expect(tester.takeException(), isNull);
  });

  testWidgets('registration action stays visible when the keyboard is open',
      (tester) async {
    await pumpRoute(tester, const RegisterScreen());

    await tester.tap(find.byType(TextFormField).last);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pumpAndSettle();

    final availableHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio - 280;
    for (var index = 0;
        index < find.byType(TextFormField).evaluate().length;
        index++) {
      final fieldRect = tester.getRect(find.byType(TextFormField).at(index));
      expect(fieldRect.top, greaterThanOrEqualTo(0));
      expect(fieldRect.bottom, lessThanOrEqualTo(availableHeight));
    }
    expect(tester.getRect(find.text('Create account')).bottom,
        lessThanOrEqualTo(availableHeight));
    expect(tester.takeException(), isNull);
    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pumpAndSettle();
  });

  testWidgets('onboarding fits a standard portrait viewport without scrolling',
      (tester) async {
    await pumpRoute(tester, const OnboardingScreen());

    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.text('Make ideas real.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Build your maker story.'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Find your next build.'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile setup steps fit without scrolling', (tester) async {
    await pumpRoute(
      tester,
      const ProfileSetupScreen(),
      user: const UserModel(
        id: 'test-user',
        name: 'Ada Maker',
        email: 'ada@example.org',
      ),
    );

    expect(find.text('What should we call you?'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(tester.takeException(), isNull);

    Future<void> expectStepFitsAboveKeyboard(String actionLabel) async {
      await tester.tap(find.byType(TextFormField).first);
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final availableHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio - 280;
      expect(
        tester.getRect(find.text(actionLabel)).bottom,
        lessThanOrEqualTo(availableHeight),
      );
      tester.view.viewInsets = FakeViewPadding.zero;
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    }

    await expectStepFitsAboveKeyboard('Continue');

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Add a phone number'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(tester.takeException(), isNull);
    await expectStepFitsAboveKeyboard('Continue');

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('College details'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(tester.takeException(), isNull);
    await expectStepFitsAboveKeyboard('Finish');
  });
}
