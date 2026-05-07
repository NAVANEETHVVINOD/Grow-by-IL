import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_logger.dart';

/// Translates Supabase exceptions into user-friendly messages.
///
/// Use in catch blocks to provide clean error text for SnackBars.
String handleSupabaseError(Object error) {
  if (error is AuthException) {
    AppLogger.warn(LogCategory.AUTH, 'AuthException: ${error.message}');
    switch (error.message) {
      case 'Invalid login credentials':
        return 'Wrong email or password.';
      case 'User already registered':
        return 'An account with this email already exists.';
      case 'Email not confirmed':
        return 'Please verify your email first.';
      default:
        return 'Authentication error. Please try again.';
    }
  }
  if (error is PostgrestException) {
    AppLogger.warn(
        LogCategory.NETWORK, 'PostgrestException code=${error.code}: ${error.message}');
    switch (error.code) {
      case '23505':
        return 'This username is already taken.';
      case '23503':
        return 'Related record not found.';
      case '42501':
        return 'You do not have permission for this action.';
      default:
        return 'Database error. Please try again.';
    }
  }
  AppLogger.error(
      LogCategory.SYSTEM, 'Unhandled error type: ${error.runtimeType}', error: error);
  return 'Something went wrong. Please try again.';
}
