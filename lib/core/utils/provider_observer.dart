import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app_logger.dart';

/// Riverpod Provider Observer to report errors to Firebase Crashlytics.
class AppProviderObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    AppLogger.error(
      LogCategory.system,
      'Provider ${provider.name ?? provider.runtimeType} failed',
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
