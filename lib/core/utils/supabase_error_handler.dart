import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_logger.dart';

/// Translates Supabase exceptions into user-friendly messages.
///
/// Use in catch blocks to provide clean error text for SnackBars.
String handleSupabaseError(Object error) {
  if (error is AuthException) {
    AppLogger.warn(LogCategory.auth, 'AuthException: ${error.message}');
    final message = error.message.toLowerCase();
    if (error.code == 'provider_disabled' ||
        message.contains('provider_disabled') ||
        (message.contains('provider') && message.contains('not enabled'))) {
      return 'Google sign-in is not configured yet. Use email and password for now.';
    }
    if (message.contains('rate limit') ||
        message.contains('over_email_send_rate_limit')) {
      return 'Please wait a few minutes before requesting another confirmation email.';
    }
    if (error is AuthSessionMissingException) {
      return 'This recovery link is expired or unavailable. Request a new one.';
    }
    if (error is AuthWeakPasswordException ||
        message.contains('weak password')) {
      return 'Choose a stronger password and try again.';
    }
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
      LogCategory.network,
      'PostgrestException code=${error.code}: ${error.message}',
    );
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
    LogCategory.system,
    'Unhandled error type: ${error.runtimeType}',
    error: error,
  );
  return 'Something went wrong. Please try again.';
}
