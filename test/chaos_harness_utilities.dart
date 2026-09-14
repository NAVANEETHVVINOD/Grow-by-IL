import 'dart:async';
import 'dart:math';

/// Chaos Harness Utilities for RC5 Sync System Testing
///
/// These utilities simulate real-world failure scenarios to validate
/// the resilience of the offline-first synchronization architecture.
/// They are NOT production code — they exist solely for testing.

// ─── FakeConnectivityFlapper ─────────────────────────────────────────────────

/// Simulates unstable network by toggling connectivity at random intervals.
/// Use this to verify:
///   - Queue accumulation during offline periods
///   - Replay resumption on reconnect
///   - No duplicate replays on rapid flaps
class FakeConnectivityFlapper {
  FakeConnectivityFlapper({
    this.minFlapMs = 200,
    this.maxFlapMs = 2000,
    this.totalFlaps = 10,
  });

  final int minFlapMs;
  final int maxFlapMs;
  final int totalFlaps;
  final _random = Random();
  final _controller = StreamController<bool>.broadcast();
  bool _isOnline = true;
  int _flapCount = 0;
  Timer? _timer;

  Stream<bool> get connectivityStream => _controller.stream;
  bool get isOnline => _isOnline;
  int get flapCount => _flapCount;

  void start() {
    _scheduleNextFlap();
  }

  void _scheduleNextFlap() {
    if (_flapCount >= totalFlaps) {
      _controller.close();
      return;
    }
    final delay = minFlapMs + _random.nextInt(maxFlapMs - minFlapMs);
    _timer = Timer(Duration(milliseconds: delay), () {
      _isOnline = !_isOnline;
      _flapCount++;
      _controller.add(_isOnline);
      _scheduleNextFlap();
    });
  }

  void dispose() {
    _timer?.cancel();
    if (!_controller.isClosed) _controller.close();
  }
}

// ─── FakeExpiredSession ──────────────────────────────────────────────────────

/// Simulates an expired or null authentication session.
/// Use this to verify:
///   - Replay suspends gracefully on null session
///   - Queue is preserved (not lost) when auth fails
///   - No data corruption on auth boundary
class FakeExpiredSession {
  FakeExpiredSession({this.expireAfterCalls = 3});

  final int expireAfterCalls;
  int _callCount = 0;
  bool _isExpired = false;

  bool get isExpired => _isExpired;
  int get callCount => _callCount;

  /// Simulates a session check. Returns true if session is valid.
  /// After [expireAfterCalls] invocations, returns false.
  bool checkSession() {
    _callCount++;
    if (_callCount > expireAfterCalls) {
      _isExpired = true;
      return false;
    }
    return true;
  }

  void reset() {
    _callCount = 0;
    _isExpired = false;
  }
}

// ─── FakeReplayInterruption ──────────────────────────────────────────────────

/// Simulates a replay being interrupted mid-flight (e.g., app killed,
/// process crash, or OS-level suspension).
/// Use this to verify:
///   - Partially replayed queues do not lose remaining mutations
///   - Lock state is properly released on crash recovery
///   - Idempotency of already-replayed mutations
class FakeReplayInterruption {
  FakeReplayInterruption({this.interruptAfterIndex = 2});

  final int interruptAfterIndex;
  int _currentIndex = 0;
  bool _interrupted = false;

  bool get wasInterrupted => _interrupted;
  int get processedCount => _currentIndex;

  /// Call before processing each mutation. Throws if interruption threshold reached.
  void beforeMutationReplay() {
    if (_currentIndex >= interruptAfterIndex) {
      _interrupted = true;
      throw ReplayInterruptedException(
        'Simulated crash at mutation index $_currentIndex',
      );
    }
    _currentIndex++;
  }

  void reset() {
    _currentIndex = 0;
    _interrupted = false;
  }
}

/// Exception thrown when a simulated replay interruption occurs.
class ReplayInterruptedException implements Exception {
  const ReplayInterruptedException(this.message);
  final String message;
  @override
  String toString() => 'ReplayInterruptedException: $message';
}

// ─── FakeQueueCorruptor ──────────────────────────────────────────────────────

/// Injects corrupted or malformed payloads into the mutation queue.
/// Use this to verify:
///   - Retry cap logic marks corrupted entries as permanently failed
///   - Queue processing does not halt on a single bad entry
///   - Error logging captures corruption details
class FakeQueueCorruptor {
  FakeQueueCorruptor();

  /// Generates a corrupted mutation payload map.
  /// The payload is syntactically valid JSON but semantically invalid
  /// for any known table schema.
  Map<String, dynamic> corruptedPayload() {
    return {
      'id': 'corrupted_${DateTime.now().millisecondsSinceEpoch}',
      'table': '__nonexistent_table__',
      'rowId': 'corrupt_row_000',
      'payload': {
        'broken_field': null,
        'invalid_number': 'not_a_number',
        'nested_corruption': {
          'deep': {'invalid': true}
        },
      },
      'type': 'upsert',
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'retryCount': 0,
      'failedPermanently': false,
    };
  }

  /// Generates a mutation with a valid structure but targeting
  /// a table that will fail RLS checks.
  Map<String, dynamic> rlsViolationPayload(String fakeUserId) {
    return {
      'id': 'rls_violation_${DateTime.now().millisecondsSinceEpoch}',
      'table': 'user_profiles',
      'rowId': fakeUserId,
      'payload': {
        'user_id': fakeUserId,
        'display_name': 'Unauthorized Write',
        'bio': 'This should be rejected by RLS',
      },
      'type': 'upsert',
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'retryCount': 0,
      'failedPermanently': false,
    };
  }

  /// Generates a mutation that will cause a type mismatch
  /// on a known column.
  Map<String, dynamic> typeMismatchPayload() {
    return {
      'id': 'type_mismatch_${DateTime.now().millisecondsSinceEpoch}',
      'table': 'user_skills',
      'rowId': 'mismatch_row',
      'payload': {
        'user_id': 12345, // Should be String
        'name': true, // Should be String
        'sort_order': 'not_an_int', // Should be int
      },
      'type': 'upsert',
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'retryCount': 0,
      'failedPermanently': false,
    };
  }
}

// ─── FakeMigrationTimeout ────────────────────────────────────────────────────

/// Simulates a migration coordinator lock timeout scenario.
/// Use this to verify:
///   - Migration does not proceed under stale lock
///   - Lock release happens cleanly on timeout
///   - Retry logic respects lock boundaries
class FakeMigrationTimeout {
  FakeMigrationTimeout({this.timeoutMs = 5000});

  final int timeoutMs;
  bool _lockAcquired = false;
  bool _timedOut = false;

  bool get lockAcquired => _lockAcquired;
  bool get timedOut => _timedOut;

  /// Simulates acquiring a migration lock with a timeout.
  Future<bool> acquireLock() async {
    _lockAcquired = true;
    // Simulate a lock that never completes (timeout scenario)
    try {
      await Future.delayed(Duration(milliseconds: timeoutMs + 1000));
      return true;
    } catch (_) {
      _timedOut = true;
      _lockAcquired = false;
      return false;
    }
  }

  /// Simulates lock acquisition with a proper timeout.
  Future<bool> acquireLockWithTimeout() async {
    _lockAcquired = true;
    final completer = Completer<bool>();
    Timer(Duration(milliseconds: timeoutMs), () {
      if (!completer.isCompleted) {
        _timedOut = true;
        _lockAcquired = false;
        completer.complete(false);
      }
    });
    return completer.future;
  }

  void reset() {
    _lockAcquired = false;
    _timedOut = false;
  }
}
