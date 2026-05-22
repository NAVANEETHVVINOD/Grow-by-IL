import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app_logger.dart';

/// Riverpod Provider Observer to report errors and track performance.
class AppProviderObserver extends ProviderObserver {
  static final Map<String, int> providerRebuilds = {};
  static final Map<String, int> activeStreams = {};
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    final name = provider.name ?? provider.runtimeType.toString();
    if (name.contains('StreamProvider')) {
      activeStreams[name] = (activeStreams[name] ?? 0) + 1;
    }
    AppLogger.info(
      LogCategory.system,
      'PROVIDER ADDED | $name | Active Streams: ${activeStreams[name] ?? 0}',
    );
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    final name = provider.name ?? provider.runtimeType.toString();
    providerRebuilds[name] = (providerRebuilds[name] ?? 0) + 1;

    // Only log high-frequency rebuilds or specific ones if needed, but for now log all updates
    AppLogger.info(
      LogCategory.system,
      'PROVIDER REBUILT | $name | Rebuild Count: ${providerRebuilds[name]}',
    );
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    final name = provider.name ?? provider.runtimeType.toString();
    if (name.contains('StreamProvider')) {
      activeStreams[name] = (activeStreams[name] ?? 1) - 1;
    }
    AppLogger.info(
      LogCategory.system,
      'PROVIDER DISPOSED | $name | Active Streams: ${activeStreams[name] ?? 0}',
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
