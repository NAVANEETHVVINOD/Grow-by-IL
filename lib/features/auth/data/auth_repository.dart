import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/app_logger.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/repositories/supabase_client.dart';
import 'google_auth_service.dart';

/// Provider for the AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(supabase, GoogleAuthService());
});

/// Provider for the current Auth State stream
final authStateProvider = StreamProvider<AuthState>((ref) {
  return supabase.auth.onAuthStateChange;
});

/// Provider for the current logged-in user profile
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final session = supabase.auth.currentSession;
  if (session == null) return null;

  final repository = ref.watch(authRepositoryProvider);
  return repository.getUserProfile(session.user.id);
});

class AuthRepository {
  AuthRepository(this._client, this._googleAuth);

  final SupabaseClient _client;
  final GoogleAuthService _googleAuth;

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String collegeRoll,
    required String phone,
  }) async {
    AppLogger.action(LogCategory.auth, 'signUp', {'email': email});

    try {
      // 1. Create auth user
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Failed to create account');
      }

      final userId = response.user!.id;

      // 2. Insert into public.users
      await _client.from('users').insert({
        'id': userId,
        'name': name,
        'email': email,
        'phone': phone,
        'college_roll': collegeRoll,
        'role': 'student',
        'system_role': 'user',
        'profile_completed': false,
        'qr_code_data': 'GROWLAB-USER-$userId',
      });

      AppLogger.info(LogCategory.auth, 'Sign-up successful, userId: $userId');
    } catch (e, st) {
      AppLogger.error(LogCategory.auth, 'Sign-up failed', error: e, stack: st);
      rethrow;
    }
  }

  /// Sign in an existing user
  Future<void> signIn({required String email, required String password}) async {
    AppLogger.action(LogCategory.auth, 'signIn', {'email': email});

    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Auto-sync profile for email users too
      if (response.user != null) {
        await ensureUserProfileExists(response.user!);
      }

      AppLogger.info(LogCategory.auth, 'Sign-in successful, email: $email');
    } catch (e, st) {
      AppLogger.error(LogCategory.auth, 'Sign-in failed', error: e, stack: st);
      rethrow;
    }
  }

  /// Sign in with Google
  Future<AuthResponse?> signInWithGoogle() async {
    final response = await _googleAuth.signInWithGoogle();
    if (response?.user != null) {
      await ensureUserProfileExists(response!.user!);
    }
    return response;
  }

  /// Ensures a public.users row exists for the given auth user.
  /// (Called during Google Login or Splash redirect)
  Future<void> ensureUserProfileExists(User authUser) async {
    try {
      final existing = await _client
          .from('users')
          .select('id')
          .eq('id', authUser.id)
          .maybeSingle();

      if (existing == null) {
        AppLogger.info(
          LogCategory.auth,
          'SYNC_PROFILE | Creating missing row for ${authUser.id}',
        );
        await _client.from('users').insert({
          'id': authUser.id,
          'name': authUser.userMetadata?['full_name'] ?? 'Maker',
          'email': authUser.email,
          'role': 'student',
          'profile_completed': false,
          'qr_code_data': 'GROWLAB-USER-${authUser.id}',
        });
      }
    } catch (e, st) {
      AppLogger.error(
        LogCategory.auth,
        'SYNC_PROFILE_FAILED',
        error: e,
        stack: st,
      );
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    AppLogger.action(LogCategory.auth, 'signOut');
    try {
      await _googleAuth.signOut();
      await _client.auth.signOut();
      AppLogger.info(LogCategory.auth, 'Sign-out successful');
    } catch (e, st) {
      AppLogger.error(LogCategory.auth, 'Sign-out failed', error: e, stack: st);
      rethrow;
    }
  }

  /// Fetch user profile from `public.users`
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final data = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle(); // Use maybeSingle to avoid PGRST116 crash

      if (data == null) return null;
      return UserModel.fromJson(data);
    } catch (e, st) {
      AppLogger.error(
        LogCategory.auth,
        'getUserProfile failed',
        error: e,
        stack: st,
      );
      return null;
    }
  }

  /// Get the currently logged-in user's profile
  Future<UserModel?> getCurrentUser() async {
    try {
      final authUser = _client.auth.currentUser;
      if (authUser == null) {
        AppLogger.info(LogCategory.auth, 'GET_CURRENT_USER | no auth session');
        return null;
      }

      AppLogger.action(LogCategory.auth, 'GET_CURRENT_USER', {
        'userId': authUser.id,
      });

      final data = await _client
          .from('users')
          .select()
          .eq('id', authUser.id)
          .maybeSingle(); // was .single(), caused PGRST116 crash

      if (data == null) {
        AppLogger.warn(
          LogCategory.auth,
          'USER_PROFILE_MISSING | userId=${authUser.id} | auth row exists but no public.users row',
        );

        // Auto-create the missing row so the user is not stuck
        AppLogger.info(LogCategory.auth, 'AUTO_CREATING_PROFILE_ROW');
        await _client.from('users').insert({
          'id': authUser.id,
          'name':
              authUser.userMetadata?['full_name'] ??
              authUser.email?.split('@').first ??
              'Maker',
          'email': authUser.email ?? '',
          'role': 'student',
          'system_role': 'user',
          'profile_completed': false,
          'xp': 0,
          'level': 1,
          'reputation_score': 100,
          'qr_code_data': 'GROWLAB-USER-${authUser.id}',
        });

        // Fetch the newly created row
        final newData = await _client
            .from('users')
            .select()
            .eq('id', authUser.id)
            .single();

        AppLogger.info(LogCategory.auth, 'PROFILE_ROW_CREATED_AND_FETCHED');
        return UserModel.fromJson(newData);
      }

      AppLogger.info(
        LogCategory.auth,
        'GET_CURRENT_USER_SUCCESS | userId=${authUser.id}',
      );
      return UserModel.fromJson(data);
    } catch (e, st) {
      AppLogger.error(
        LogCategory.auth,
        'GET_CURRENT_USER_FAILED',
        error: e,
        stack: st,
      );
      return null;
    }
  }

  /// Update user profile in `public.users`
  Future<void> updateProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    AppLogger.action(LogCategory.auth, 'updateProfile', {
      'userId': userId,
      'fields': updates.keys.toList(),
    });
    try {
      await _client.from('users').update(updates).eq('id', userId);
      AppLogger.info(
        LogCategory.auth,
        'Profile updated successfully for $userId',
      );
    } catch (e, st) {
      AppLogger.error(
        LogCategory.auth,
        'updateProfile failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }
}
