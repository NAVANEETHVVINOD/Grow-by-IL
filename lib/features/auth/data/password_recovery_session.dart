import 'package:shared_preferences/shared_preferences.dart';

/// Records that the current authenticated user reached Grow through a valid
/// password-recovery callback.
///
/// This is only a routing aid for app restarts. It stores an opaque user ID,
/// never a token or password, and is never treated as authorization: the reset
/// screen still requires a live Supabase session for the same user.
class PasswordRecoverySession {
  PasswordRecoverySession._();

  static const _pendingUserIdKey = 'auth.password_recovery.pending_user_id';

  static Future<void> markPendingFor(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_pendingUserIdKey, userId);
  }

  static Future<bool> isPendingFor(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_pendingUserIdKey) == userId;
  }

  static Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_pendingUserIdKey);
  }
}
