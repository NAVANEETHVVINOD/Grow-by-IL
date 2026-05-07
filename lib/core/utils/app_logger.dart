import 'package:flutter/foundation.dart';

/// Lightweight structured logger for Grow~.
///
/// Four levels — info, warn, error, action.
/// Console-only via debugPrint.
class AppLogger {
  AppLogger._();

  static const _tag = 'Grow~';

  static void info(String feature, String message) {
    debugPrint('[$_tag][$feature] INFO: $message');
  }

  static void warn(String feature, String message) {
    debugPrint('[$_tag][$feature] WARN: $message');
  }

  static void error(String feature, String message,
      [Object? error, StackTrace? stack]) {
    debugPrint('[$_tag][$feature] ERROR: $message');
    if (error != null) debugPrint('  └─ $error');
    if (stack != null) debugPrint('  └─ $stack');
  }

  static void action(String feature, String action,
      {Map<String, dynamic>? data}) {
    final extra = data != null
        ? ' | ${data.entries.map((e) => '${e.key}=${e.value}').join(', ')}'
        : '';
    debugPrint('[$_tag][$feature] ACTION: $action$extra');
  }
}
