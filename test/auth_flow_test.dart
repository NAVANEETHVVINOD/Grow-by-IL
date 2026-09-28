import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:grow/core/constants/auth_redirects.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/auth/data/google_auth_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder<T> extends Mock
    implements PostgrestFilterBuilder<T> {}

class MockPostgrestTransformBuilder<T> extends Mock
    implements PostgrestTransformBuilder<T> {}

class MockGoogleAuthService extends Mock implements GoogleAuthService {}

class MockUserResponse extends Mock implements UserResponse {}

void main() {
  setUpAll(() {
    registerFallbackValue(UserAttributes());
  });

  group('AuthFlow Unit & Integration Tests', () {
    late MockSupabaseClient mockSupabase;
    late MockGoTrueClient mockAuth;
    late MockGoogleAuthService mockGoogleAuth;
    late MockSupabaseQueryBuilder mockQueryBuilder;
    late MockPostgrestFilterBuilder<List<Map<String, dynamic>>>
        mockFilterBuilder;
    late MockPostgrestTransformBuilder<Map<String, dynamic>?>
        mockTransformBuilder;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      mockGoogleAuth = MockGoogleAuthService();
      mockQueryBuilder = MockSupabaseQueryBuilder();
      mockFilterBuilder =
          MockPostgrestFilterBuilder<List<Map<String, dynamic>>>();
      mockTransformBuilder =
          MockPostgrestTransformBuilder<Map<String, dynamic>?>();

      // Register fallback values for mocktail
      registerFallbackValue(const Duration(seconds: 10));

      when(() => mockSupabase.auth).thenReturn(mockAuth);
      when(() => mockSupabase.from(any())).thenAnswer((_) => mockQueryBuilder);
    });

    test('Sign-in flow executes successfully', () async {
      final fakeUser = User(
        id: 'user-123',
        appMetadata: {},
        userMetadata: {'full_name': 'Alice Test'},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'alice@test.com',
      );

      final fakeResponse = AuthResponse(
        session: Session(
          accessToken: 'token-abc',
          tokenType: 'bearer',
          user: fakeUser,
          refreshToken: 'refresh-token',
          expiresIn: 3600,
        ),
        user: fakeUser,
      );

      when(() => mockAuth.signInWithPassword(
            email: 'alice@test.com',
            password: 'password123',
          )).thenAnswer((_) async => fakeResponse);

      when(() => mockQueryBuilder.select('id'))
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', 'user-123'))
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.maybeSingle())
          .thenAnswer((_) => mockTransformBuilder);

      // Stub the timeout call on the transform builder to return the map
      when(() => mockTransformBuilder.timeout(any()))
          .thenAnswer((_) async => {'id': 'user-123'});

      final authRepo = AuthRepository(mockSupabase, mockGoogleAuth);

      await expectLater(
        authRepo.signIn(email: 'alice@test.com', password: 'password123'),
        completes,
      );
    });

    test('Sign-in failure throws error properly', () async {
      when(() => mockAuth.signInWithPassword(
            email: 'alice@test.com',
            password: 'password123',
          )).thenThrow(const AuthException('Invalid login credentials'));

      final authRepo = AuthRepository(mockSupabase, mockGoogleAuth);

      await expectLater(
        authRepo.signIn(email: 'alice@test.com', password: 'password123'),
        throwsA(isA<AuthException>()),
      );
    });

    test('Sign-up flow creates auth user and public database entry', () async {
      final fakeUser = User(
        id: 'new-user-123',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'new@test.com',
        emailConfirmedAt: DateTime.now().toIso8601String(),
      );

      final fakeResponse = AuthResponse(
        session: Session(
          accessToken: 'token-xyz',
          tokenType: 'bearer',
          user: fakeUser,
          refreshToken: 'refresh-token',
          expiresIn: 3600,
        ),
        user: fakeUser,
      );

      when(() => mockAuth.signUp(
            email: 'new@test.com',
            password: 'securepassword',
            emailRedirectTo: AppAuthRedirects.emailConfirmationLanding,
            data: any(named: 'data'),
          )).thenAnswer((_) async => fakeResponse);

      final mockInsertFilterBuilder =
          MockPostgrestFilterBuilder<List<Map<String, dynamic>>>();
      when(() => mockQueryBuilder.insert(any()))
          .thenAnswer((_) => mockInsertFilterBuilder);

      // Stub the timeout call on the filter builder to return the list
      when(() => mockInsertFilterBuilder.timeout(any()))
          .thenAnswer((_) async => <Map<String, dynamic>>[]);

      final authRepo = AuthRepository(mockSupabase, mockGoogleAuth);

      await expectLater(
        authRepo.signUp(
          name: 'Bob Builder',
          email: 'new@test.com',
          password: 'securepassword',
          collegeRoll: '12345',
          phone: '9876543210',
        ),
        completion(isTrue),
      );

      verify(() => mockAuth.signUp(
            email: 'new@test.com',
            password: 'securepassword',
            emailRedirectTo: AppAuthRedirects.emailConfirmationLanding,
            data: {
              'name': 'Bob Builder',
              'phone': '9876543210',
              'college_roll': '12345',
            },
          )).called(1);
    });

    test('Sign-up defers profile creation until confirmed users sign in',
        () async {
      final pendingConfirmationUser = User(
        id: 'pending-user-123',
        appMetadata: const {},
        userMetadata: const {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'pending@example.com',
      );

      when(() => mockAuth.signUp(
            email: 'pending@example.com',
            password: 'securepassword',
            emailRedirectTo: AppAuthRedirects.emailConfirmationLanding,
            data: any(named: 'data'),
          )).thenAnswer(
        (_) async => AuthResponse(user: pendingConfirmationUser),
      );

      final authRepo = AuthRepository(mockSupabase, mockGoogleAuth);

      await expectLater(
        authRepo.signUp(
          name: 'Pending User',
          email: 'pending@example.com',
          password: 'securepassword',
          collegeRoll: '12345',
          phone: '9876543210',
        ),
        completion(isFalse),
      );

      verifyNever(() => mockQueryBuilder.insert(any()));
    });

    test('obfuscated existing-email signup response creates no profile row',
        () async {
      // Supabase may return an obfuscated user with no identities for an
      // address already registered. Grow must not create another public
      // profile or treat that response as an authenticated account.
      final obfuscatedUser = User(
        id: 'existing-user-123',
        appMetadata: const {},
        userMetadata: const {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'existing@example.com',
        identities: const <UserIdentity>[],
      );

      when(() => mockAuth.signUp(
            email: 'existing@example.com',
            password: 'securepassword',
            emailRedirectTo: AppAuthRedirects.emailConfirmationLanding,
            data: any(named: 'data'),
          )).thenAnswer((_) async => AuthResponse(user: obfuscatedUser));

      final authRepo = AuthRepository(mockSupabase, mockGoogleAuth);

      await expectLater(
        authRepo.signUp(
          name: 'Existing User',
          email: 'existing@example.com',
          password: 'securepassword',
        ),
        completion(isFalse),
      );

      verifyNever(() => mockQueryBuilder.insert(any()));
    });

    test('Sign-up does not treat a temporary session as email verification',
        () async {
      final pendingConfirmationUser = User(
        id: 'session-pending-user-123',
        appMetadata: const {},
        userMetadata: const {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'session-pending@example.com',
      );

      when(() => mockAuth.signUp(
            email: 'session-pending@example.com',
            password: 'securepassword',
            emailRedirectTo: AppAuthRedirects.emailConfirmationLanding,
            data: any(named: 'data'),
          )).thenAnswer(
        (_) async => AuthResponse(
          user: pendingConfirmationUser,
          session: Session(
            accessToken: 'temporary-token',
            tokenType: 'bearer',
            user: pendingConfirmationUser,
            refreshToken: 'temporary-refresh-token',
            expiresIn: 3600,
          ),
        ),
      );
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      final authRepo = AuthRepository(mockSupabase, mockGoogleAuth);

      await expectLater(
        authRepo.signUp(
          name: 'Pending User',
          email: 'session-pending@example.com',
          password: 'securepassword',
        ),
        completion(isFalse),
      );

      verify(() => mockAuth.signOut()).called(1);
      verifyNever(() => mockQueryBuilder.insert(any()));
    });

    test('Resend keeps the mobile confirmation redirect', () async {
      when(() => mockAuth.resend(
            type: OtpType.signup,
            email: 'pending@example.com',
            emailRedirectTo: AppAuthRedirects.emailConfirmationLanding,
          )).thenAnswer((_) async => ResendResponse());

      final authRepo = AuthRepository(mockSupabase, mockGoogleAuth);

      await expectLater(
        authRepo.resendSignupConfirmation(email: 'pending@example.com'),
        completes,
      );

      verify(() => mockAuth.resend(
            type: OtpType.signup,
            email: 'pending@example.com',
            emailRedirectTo: AppAuthRedirects.emailConfirmationLanding,
          )).called(1);
    });

    test('profile repository rejects role updates before a database call',
        () async {
      final authRepo = AuthRepository(mockSupabase, mockGoogleAuth);

      await expectLater(
        authRepo.updateProfile('user-123', {'role': 'super_admin'}),
        throwsArgumentError,
      );

      verifyNever(() => mockSupabase.from(any()));
    });

    test('Password recovery request keeps the approved mobile callback',
        () async {
      when(() => mockAuth.resetPasswordForEmail(
            'member@example.com',
            redirectTo: AppAuthRedirects.passwordRecoveryLanding,
          )).thenAnswer((_) async {});

      final authRepo = AuthRepository(mockSupabase, mockGoogleAuth);

      await expectLater(
        authRepo.requestPasswordRecovery(email: 'member@example.com'),
        completes,
      );

      verify(() => mockAuth.resetPasswordForEmail(
            'member@example.com',
            redirectTo: AppAuthRedirects.passwordRecoveryLanding,
          )).called(1);
    });

    test(
        'Password recovery updates the password then ends the recovery session',
        () async {
      final recoveryUser = User(
        id: 'recovery-user-123',
        appMetadata: const {},
        userMetadata: const {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'member@example.com',
      );
      final recoverySession = Session(
        accessToken: 'recovery-access-token',
        tokenType: 'bearer',
        user: recoveryUser,
        refreshToken: 'recovery-refresh-token',
        expiresIn: 3600,
      );
      when(() => mockAuth.currentSession).thenReturn(recoverySession);
      when(() => mockAuth.updateUser(any()))
          .thenAnswer((_) async => MockUserResponse());
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      final authRepo = AuthRepository(mockSupabase, mockGoogleAuth);

      await expectLater(
        authRepo.completePasswordRecovery(password: 'newpassword'),
        completes,
      );

      verify(() => mockAuth.updateUser(any(
            that: isA<UserAttributes>().having(
              (attributes) => attributes.password,
              'password',
              'newpassword',
            ),
          ))).called(1);
      verify(() => mockAuth.signOut()).called(1);
    });

    test('Password recovery rejects a missing recovery session', () async {
      when(() => mockAuth.currentSession).thenReturn(null);
      final authRepo = AuthRepository(mockSupabase, mockGoogleAuth);

      await expectLater(
        authRepo.completePasswordRecovery(password: 'newpassword'),
        throwsA(isA<AuthSessionMissingException>()),
      );
      verifyNever(() => mockAuth.updateUser(any()));
    });

    test('Sign-up permits deferred onboarding fields', () async {
      final fakeUser = User(
        id: 'minimal-user-123',
        appMetadata: const {},
        userMetadata: const {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'minimal@example.com',
      );

      when(() => mockAuth.signUp(
            email: 'minimal@example.com',
            password: 'securepassword',
            emailRedirectTo: AppAuthRedirects.emailConfirmationLanding,
            data: any(named: 'data'),
          )).thenAnswer(
        (_) async => AuthResponse(user: fakeUser),
      );

      final authRepo = AuthRepository(mockSupabase, mockGoogleAuth);

      await expectLater(
        authRepo.signUp(
          name: 'Minimal User',
          email: 'minimal@example.com',
          password: 'securepassword',
        ),
        completion(isFalse),
      );

      verify(() => mockAuth.signUp(
            email: 'minimal@example.com',
            password: 'securepassword',
            emailRedirectTo: AppAuthRedirects.emailConfirmationLanding,
            data: {'name': 'Minimal User'},
          )).called(1);
    });
  });
}
