import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Fail-closed marker for a one-time Auth link exchange.
///
/// GoTrue stores a session as part of exchanging a PKCE code. A process death
/// before Grow signs out a confirmation session must not turn that temporary
/// session into application login on the next launch. This stores only a flag,
/// never the link, code, token, email, or user ID.
class AuthCallbackGuard {
  AuthCallbackGuard._();

  static const _pendingKey = 'auth.callback.exchange_pending';
  static bool _active = false;
  static Future<void>? _inFlightCallback;

  static bool get isActive => _active;

  @visibleForTesting
  static void resetSerializationForTesting() {
    _inFlightCallback = null;
  }

  /// A newer link must not exchange its code before an older callback has
  /// completed and discarded any temporary session it created.
  static Future<T> runSerialized<T>(Future<T> Function() callback) async {
    while (_inFlightCallback != null) {
      await _inFlightCallback;
    }
    final done = Completer<void>();
    _inFlightCallback = done.future;
    try {
      return await callback();
    } finally {
      _inFlightCallback = null;
      done.complete();
    }
  }

  static Future<bool> restore() async {
    final preferences = await SharedPreferences.getInstance();
    _active = preferences.getBool(_pendingKey) ?? false;
    return _active;
  }

  static Future<void> begin() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_pendingKey, true);
    _active = true;
  }

  static Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_pendingKey);
    _active = false;
  }
}
