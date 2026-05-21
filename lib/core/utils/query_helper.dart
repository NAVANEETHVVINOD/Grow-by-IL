import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_logger.dart';

/// Centralized utility wrapper for executing Supabase queries safely with a timeout and consistent error logging.
Future<T> guardedSupabaseCall<T>(
  Future<T> future, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  try {
    return await future.timeout(timeout);
  } on TimeoutException catch (e, stack) {
    AppLogger.error(
      LogCategory.network,
      'Supabase query timed out after ${timeout.inSeconds} seconds',
      error: e,
      stack: stack,
    );
    throw Exception('Connection timed out. Please check your internet connection and try again.');
  } on PostgrestException catch (e, stack) {
    AppLogger.error(
      LogCategory.network,
      'Supabase database operation failed: [${e.code}] ${e.message}',
      error: e,
      stack: stack,
    );
    rethrow;
  } on AuthException catch (e, stack) {
    AppLogger.error(
      LogCategory.auth,
      'Supabase auth operation failed: ${e.message}',
      error: e,
      stack: stack,
    );
    rethrow;
  } catch (e, stack) {
    AppLogger.error(
      LogCategory.network,
      'Unexpected network error occurred',
      error: e,
      stack: stack,
    );
    rethrow;
  }
}
