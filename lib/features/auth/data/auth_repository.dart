import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/app_logger.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/repositories/supabase_client.dart';

/// Provider for the AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(supabase);
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
  AuthRepository(this._client);

  final SupabaseClient _client;

  /// Sign up a new user and create their profile in `public.users`
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String collegeRoll,
    required String phone,
  }) async {
    AppLogger.action(LogCategory.AUTH, 'signUp', {'email': email});

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
        'base_role': 'student',
        'system_role': 'user',
        'profile_completed': false,
        'qr_code_data': 'GROWLAB-USER-$userId',
      });

      AppLogger.info(LogCategory.AUTH, 'Sign-up successful, userId: $userId');
    } catch (e, st) {
      AppLogger.error(LogCategory.AUTH, 'Sign-up failed', error: e, stack: st);
      rethrow;
    }
  }

  /// Sign in an existing user
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    AppLogger.action(LogCategory.AUTH, 'signIn', {'email': email});

    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      AppLogger.info(LogCategory.AUTH, 'Sign-in successful, email: $email');
    } catch (e, st) {
      AppLogger.error(LogCategory.AUTH, 'Sign-in failed', error: e, stack: st);
      rethrow;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    AppLogger.action(LogCategory.AUTH, 'signOut');
    try {
      await _client.auth.signOut();
      AppLogger.info(LogCategory.AUTH, 'Sign-out successful');
    } catch (e, st) {
      AppLogger.error(LogCategory.AUTH, 'Sign-out failed', error: e, stack: st);
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
          .single();
      return UserModel.fromJson(data);
    } catch (e, st) {
      AppLogger.error(LogCategory.AUTH, 'getUserProfile failed', error: e, stack: st);
      return null;
    }
  }
}
