import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app_logger.dart';

/// Riverpod Provider Observer to report errors to Firebase Crashlytics.
class AppProviderObserver extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    AppLogger.info(
      LogCategory.system,
      'PROVIDER ADDED | ${provider.name ?? provider.runtimeType}',
    );
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    AppLogger.info(
      LogCategory.system,
      'PROVIDER DISPOSED | ${provider.name ?? provider.runtimeType}',
    );
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    AppLogger.error(
      LogCategory.system,
      'PROVIDER FAILED | ${provider.name ?? provider.runtimeType}',
      error: error,
      stack: stackTrace,
    );

    // If Firebase is initialized, record to Crashlytics
    if (Firebase.apps.isNotEmpty) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Provider ${provider.name ?? provider.runtimeType} failed',
      );
    }
  }
}
