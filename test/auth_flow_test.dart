import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

void main() {
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
        completes,
      );
    });
  });
}
