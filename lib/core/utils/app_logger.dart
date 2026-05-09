import 'package:flutter/foundation.dart';

enum LogCategory {
  auth,
  lab,
  tools,
  events,
  projects,
  inventory,
  admin,
  network,
  search,
  notifications,
  router,
  system,
}

class AppLogger {
  AppLogger._();
  static const _tag = 'Grow~';

  static void printStartupBanner() {
    debugPrint('\n${'=' * 50}');
    debugPrint('   🌱 GROW~ RELEASE CANDIDATE (RC1)');
    debugPrint('   Build: 2024.12.RC1 | Version: 1.0.0');
    debugPrint('   Status: PRODUCTION_HARDENED');
    debugPrint('=' * 50 + '\n');
  }

  static void info(
    LogCategory category,
    String msg, [
    Map<String, dynamic>? data,
  ]) {
    _log(category, 'INFO', msg, data);
  }

  static void warn(
    LogCategory category,
    String msg, [
    Map<String, dynamic>? data,
  ]) {
    _log(category, 'WARN', msg, data);
  }

  static void success(
    LogCategory category,
    String msg, [
    Map<String, dynamic>? data,
  ]) {
    _log(category, 'SUCCESS', msg, data);
  }

  static void action(
    LogCategory category,
    String act, [
    Map<String, dynamic>? data,
  ]) {
    _log(category, 'ACTION', act, data);
  }

  static void error(
    LogCategory category,
    String msg, {
    Object? error,
    StackTrace? stack,
    Map<String, dynamic>? data,
  }) {
    final extra = _formatData(data);
    debugPrint('[$_tag][${category.name.toUpperCase()}] ❌ ERROR: $msg$extra');
    if (error != null) debugPrint('   └─ Cause: $error');
    if (stack != null) debugPrint('   └─ Stack: $stack');
  }

  static void _log(
    LogCategory cat,
    String level,
    String msg,
    Map<String, dynamic>? data,
  ) {
    final extra = _formatData(data);
    debugPrint('[$_tag][${cat.name.toUpperCase()}] $level: $msg$extra');
  }

  static String _formatData(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return '';
    return ' | data={${data.entries.map((e) => '${e.key}: ${e.value}').join(', ')}}';
  }
}
