import 'package:flutter/foundation.dart';

/// Structured logging categories for Grow~.
enum LogCategory {
  AUTH,
  LAB,
  TOOLS,
  EVENTS,
  PROJECTS,
  INVENTORY,
  ADMIN,
  NETWORK,
  SEARCH,
  NOTIFICATIONS,
  ROUTER,
  SYSTEM,
}

/// Structured observability system for Grow~.
class AppLogger {
  AppLogger._();

  static const _tag = 'Grow~';

  /// Log a successful operation or state change
  static void success(LogCategory category, String message, [Map<String, dynamic>? data]) {
    _log(category, 'SUCCESS', message, data);
  }

  /// Log general information
  static void info(LogCategory category, String message, [Map<String, dynamic>? data]) {
    _log(category, 'INFO', message, data);
  }

  /// Log a warning or potential issue
  static void warn(LogCategory category, String message, [Map<String, dynamic>? data]) {
    _log(category, 'WARN', message, data);
  }

  /// Log a critical failure or exception
  static void error(
    LogCategory category, 
    String message, {
    Object? error, 
    StackTrace? stack, 
    Map<String, dynamic>? data,
  }) {
    final extra = _formatData(data);
    debugPrint('[$_tag][${category.name}] ERROR: $message$extra');
    if (error != null) debugPrint('  └─ ERROR: $error');
    if (stack != null) debugPrint('  └─ STACK: $stack');
  }

  /// Log a user action or lifecycle event
  static void action(LogCategory category, String action, [Map<String, dynamic>? data]) {
    _log(category, 'ACTION', action, data);
  }

  static void _log(LogCategory category, String level, String message, Map<String, dynamic>? data) {
    final extra = _formatData(data);
    debugPrint('[$_tag][${category.name}] $level: $message$extra');
  }

  static String _formatData(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return '';
    return '\n  ' + data.entries.map((e) => '${e.key}=${e.value}').join('\n  ');
  }
}
