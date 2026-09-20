import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/auth_redirects.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/query_helper.dart';
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
  return repository.getCurrentUser();
});

class AuthRepository {
  AuthRepository(this._client, this._googleAuth);

  final SupabaseClient _client;
  final GoogleAuthService _googleAuth;

  /// Returns whether the account's email is already verified.
  ///
  /// A Supabase response can carry a session while a signup flow is in
  /// progress, so a session is not proof that the new email was verified.
  /// Grow deliberately treats email confirmation and application sign-in as
  /// separate steps: a newly created, unverified account always returns
  /// `false`, clears any temporary session, and waits for a normal sign-in
  /// after the recipient confirms the email.
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    String? collegeRoll,
    String? phone,
  }) async {
    AppLogger.action(LogCategory.auth, 'SIGN_UP_STARTED');

    try {
      // 1. Create auth user
      final response = await guardedSupabaseCall(
        _client.auth.signUp(
          email: email,
          password: password,
          emailRedirectTo: AppAuthRedirects.emailConfirmationLanding,
          // This is non-authoritative onboarding data only. Authorization
          // roles and other privileged fields never come from user metadata.
          data: {
            'name': name,
            if (phone != null) 'phone': phone,
            if (collegeRoll != null) 'college_roll': collegeRoll,
          },
        ),
      );

      if (response.user == null) {
        throw Exception('Failed to create account');
      }

      final authUser = response.user!;
      if (authUser.emailConfirmedAt == null) {
        // Never leave a temporary/stale session behind after account creation.
        // This prevents registration from being mistaken for verified sign-in.
        if (response.session != null || _client.auth.currentSession != null) {
          await guardedSupabaseCall(_client.auth.signOut());
        }
        AppLogger.info(LogCategory.auth, 'SIGN_UP_PENDING_EMAIL_CONFIRMATION');
        return false;
      }

      final userId = authUser.id;

      if (response.session == null) {
        throw StateError(
          'A verified account was created without a sign-in session.',
        );
      }

      // 2. An active session exists, so the authenticated client may create
      // its own safe profile columns. Confirmation-based flows use
      // ensureUserProfileExists after the first successful sign-in instead.
      await guardedSupabaseCall(
        _client.from('users').insert(
              AppDefaults.buildNewUserRow(
                userId: userId,
                name: name,
                email: email,
                phone: phone,
                collegeRoll: collegeRoll,
              ),
            ),
      );

      AppLogger.info(LogCategory.auth, 'SIGN_UP_COMPLETED_WITH_SESSION');
      return true;
    } catch (e, st) {
      AppLogger.error(LogCategory.auth, 'Sign-up failed', error: e, stack: st);
      rethrow;
    }
  }

  /// Resends the verification email for an account that is waiting to be
  /// confirmed. This never signs a user in.
  Future<void> resendSignupConfirmation({required String email}) async {
    AppLogger.action(LogCategory.auth, 'SIGN_UP_CONFIRMATION_RESEND_STARTED');

    try {
      await guardedSupabaseCall(
        _client.auth.resend(
          type: OtpType.signup,
          email: email,
          emailRedirectTo: AppAuthRedirects.emailConfirmationLanding,
        ),
      );
      AppLogger.info(LogCategory.auth, 'SIGN_UP_CONFIRMATION_RESEND_SENT');
    } catch (e, st) {
      AppLogger.error(
        LogCategory.auth,
        'Sign-up confirmation resend failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  /// Sends a password-recovery email without revealing whether the address
  /// belongs to a Grow account. Supabase owns rate limiting and delivery.
  Future<void> requestPasswordRecovery({required String email}) async {
    AppLogger.action(LogCategory.auth, 'PASSWORD_RECOVERY_REQUESTED');

    try {
      await guardedSupabaseCall(
        _client.auth.resetPasswordForEmail(
          email,
          redirectTo: AppAuthRedirects.passwordRecoveryLanding,
        ),
      );
      AppLogger.info(LogCategory.auth, 'PASSWORD_RECOVERY_EMAIL_REQUESTED');
    } catch (e, st) {
      AppLogger.error(
        LogCategory.auth,
        'Password recovery request failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  /// Updates a password using the short-lived session established by a valid
  /// recovery link, then ends that session so the member signs in normally.
  Future<void> completePasswordRecovery({required String password}) async {
    AppLogger.action(LogCategory.auth, 'PASSWORD_RECOVERY_UPDATE_STARTED');

    try {
      if (_client.auth.currentSession == null) {
        throw AuthSessionMissingException();
      }

      await guardedSupabaseCall(
        _client.auth.updateUser(UserAttributes(password: password)),
      );
      await guardedSupabaseCall(_client.auth.signOut());
      AppLogger.info(LogCategory.auth, 'PASSWORD_RECOVERY_UPDATE_COMPLETED');
    } catch (e, st) {
      AppLogger.error(
        LogCategory.auth,
        'Password recovery update failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  /// Sign in an existing user
  Future<void> signIn({required String email, required String password}) async {
    AppLogger.action(LogCategory.auth, 'SIGN_IN_STARTED');

    try {
      final response = await guardedSupabaseCall(
        _client.auth.signInWithPassword(
          email: email,
          password: password,
        ),
      );

      // Auto-sync profile for email users too
      if (response.user != null) {
        await ensureUserProfileExists(response.user!);
      }

      AppLogger.info(LogCategory.auth, 'SIGN_IN_SUCCESS');
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
      final existing = await guardedSupabaseCall(
        _client.from('users').select('id').eq('id', authUser.id).maybeSingle(),
      );

      if (existing == null) {
        AppLogger.info(LogCategory.auth, 'SYNC_PROFILE_CREATING_MISSING_ROW');
        await guardedSupabaseCall(
          _client.from('users').insert(
                AppDefaults.buildNewUserRow(
                  userId: authUser.id,
                  name: _profileNameFromMetadata(authUser),
                  email: authUser.email ?? '',
                  phone: _optionalProfileMetadata(authUser, 'phone'),
                  collegeRoll: _optionalProfileMetadata(
                    authUser,
                    'college_roll',
                  ),
                ),
              ),
        );
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
      await guardedSupabaseCall(_client.auth.signOut());
      AppLogger.info(LogCategory.auth, 'Sign-out successful');
    } catch (e, st) {
      AppLogger.error(LogCategory.auth, 'Sign-out failed', error: e, stack: st);
      rethrow;
    }
  }

  /// Fetch user profile from `public.users`
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final data = await guardedSupabaseCall(
        _client.from('users').select().eq('id', userId).maybeSingle(),
      );

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

      AppLogger.action(LogCategory.auth, 'GET_CURRENT_USER');

      final data = await guardedSupabaseCall(
        _client.from('users').select().eq('id', authUser.id).maybeSingle(),
      );

      if (data == null) {
        AppLogger.warn(LogCategory.auth, 'USER_PROFILE_MISSING');

        // Auto-create the missing row so the user is not stuck
        AppLogger.info(LogCategory.auth, 'AUTO_CREATING_PROFILE_ROW');
        await guardedSupabaseCall(
          _client.from('users').insert(
                AppDefaults.buildNewUserRow(
                  userId: authUser.id,
                  name: _profileNameFromMetadata(authUser),
                  email: authUser.email ?? '',
                  phone: _optionalProfileMetadata(authUser, 'phone'),
                  collegeRoll: _optionalProfileMetadata(
                    authUser,
                    'college_roll',
                  ),
                ),
              ),
        );

        // Fetch the newly created row
        final newData = await guardedSupabaseCall(
          _client.from('users').select().eq('id', authUser.id).single(),
        );

        AppLogger.info(LogCategory.auth, 'PROFILE_ROW_CREATED_AND_FETCHED');
        final userModel = UserModel.fromJson(newData);
        AppLogger.info(LogCategory.auth, 'USER_MODEL_LOADED');
        return userModel;
      }

      AppLogger.info(LogCategory.auth, 'GET_CURRENT_USER_SUCCESS');
      final userModel = UserModel.fromJson(data);
      AppLogger.info(LogCategory.auth, 'USER_MODEL_LOADED');
      return userModel;
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

  String _profileNameFromMetadata(User authUser) {
    return _optionalProfileMetadata(authUser, 'name') ??
        _optionalProfileMetadata(authUser, 'full_name') ??
        authUser.email?.split('@').first ??
        '';
  }

  String? _optionalProfileMetadata(User authUser, String key) {
    final value = authUser.userMetadata?[key];
    return value is String && value.trim().isNotEmpty ? value.trim() : null;
  }

  /// Update user profile in `public.users`
  Future<void> updateProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    AppLogger.action(LogCategory.auth, 'UPDATE_PROFILE_STARTED');
    try {
      await guardedSupabaseCall(
        _client.from('users').update(updates).eq('id', userId),
      );
      AppLogger.info(LogCategory.auth, 'UPDATE_PROFILE_SUCCESS');
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
