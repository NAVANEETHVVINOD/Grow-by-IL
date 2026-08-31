import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:grow/features/profile/domain/pending_profile_mutation.dart';

// Import chaos harness
import 'chaos_harness_utilities.dart';

void main() {
  group('Profile Sync Queue — Happy Path', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('Queue starts empty', () async {
      final queue = await PendingProfileMutationQueue.loadQueue();
      expect(queue, isEmpty);
    });

    test('Adding a mutation persists to queue', () async {
      await PendingProfileMutationQueue.addMutation(
        table: 'user_profiles',
        rowId: 'test_user_001',
        payload: {'user_id': 'test_user_001', 'display_name': 'Test User'},
        type: 'upsert',
      );

      final queue = await PendingProfileMutationQueue.loadQueue();
      expect(queue.length, 1);
      expect(queue.first.table, 'user_profiles');
      expect(queue.first.rowId, 'test_user_001');
    });

    test('Deduplication collapses same (table, rowId)', () async {
      await PendingProfileMutationQueue.addMutation(
        table: 'user_profiles',
        rowId: 'test_user_001',
        payload: {'user_id': 'test_user_001', 'display_name': 'Version 1'},
        type: 'upsert',
      );
      await PendingProfileMutationQueue.addMutation(
        table: 'user_profiles',
        rowId: 'test_user_001',
        payload: {'user_id': 'test_user_001', 'display_name': 'Version 2'},
        type: 'upsert',
      );

      final queue = await PendingProfileMutationQueue.loadQueue();
      expect(queue.length, 1);
      expect(queue.first.payload['display_name'], 'Version 2');
    });

    test('Different rowIds create separate entries', () async {
      await PendingProfileMutationQueue.addMutation(
        table: 'user_skills',
        rowId: 'skill_001',
        payload: {'user_id': 'u1', 'name': 'Dart'},
        type: 'upsert',
      );
      await PendingProfileMutationQueue.addMutation(
        table: 'user_skills',
        rowId: 'skill_002',
        payload: {'user_id': 'u1', 'name': 'Flutter'},
        type: 'upsert',
      );

      final queue = await PendingProfileMutationQueue.loadQueue();
      expect(queue.length, 2);
    });

    test('Remove mutation clears from queue', () async {
      await PendingProfileMutationQueue.addMutation(
        table: 'user_profiles',
        rowId: 'test_rm',
        payload: {'user_id': 'test_rm'},
        type: 'upsert',
      );

      var queue = await PendingProfileMutationQueue.loadQueue();
      expect(queue.length, 1);

      await PendingProfileMutationQueue.removeMutation(queue.first.id);

      queue = await PendingProfileMutationQueue.loadQueue();
      expect(queue, isEmpty);
    });
  });

  group('Profile Sync Queue — Failure Paths', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('Retry count increments on failure report', () async {
      await PendingProfileMutationQueue.addMutation(
        table: 'user_profiles',
        rowId: 'fail_test',
        payload: {'user_id': 'fail_test'},
        type: 'upsert',
      );

      var queue = await PendingProfileMutationQueue.loadQueue();
      final id = queue.first.id;

      await PendingProfileMutationQueue.reportFailure(id);
      queue = await PendingProfileMutationQueue.loadQueue();
      expect(queue.first.retryCount, 1);
      expect(queue.first.failedPermanently, false);
    });

    test('Mutation marked permanently failed after 5 retries', () async {
      await PendingProfileMutationQueue.addMutation(
        table: 'user_profiles',
        rowId: 'perm_fail',
        payload: {'user_id': 'perm_fail'},
        type: 'upsert',
      );

      var queue = await PendingProfileMutationQueue.loadQueue();
      final id = queue.first.id;

      for (int i = 0; i < 5; i++) {
        await PendingProfileMutationQueue.reportFailure(id);
      }

      queue = await PendingProfileMutationQueue.loadQueue();
      expect(queue.first.retryCount, 5);
      expect(queue.first.failedPermanently, true);
    });

    test('Replay paused flag prevents queue processing', () {
      PendingProfileMutationQueue.isReplayPaused = true;
      expect(PendingProfileMutationQueue.isReplayPaused, true);
      PendingProfileMutationQueue.isReplayPaused = false;
    });

    test('Exponential backoff delay calculation', () {
      expect(PendingProfileMutationQueue.getRetryDelay(0), Duration.zero);
      expect(PendingProfileMutationQueue.getRetryDelay(1),
          const Duration(seconds: 2));
      expect(PendingProfileMutationQueue.getRetryDelay(2),
          const Duration(seconds: 4));
      expect(PendingProfileMutationQueue.getRetryDelay(3),
          const Duration(seconds: 8));
      expect(PendingProfileMutationQueue.getRetryDelay(10),
          const Duration(seconds: 60));
    });

    test('Clear queue removes all mutations', () async {
      for (int i = 0; i < 5; i++) {
        await PendingProfileMutationQueue.addMutation(
          table: 'user_skills',
          rowId: 'clear_test_$i',
          payload: {'user_id': 'u1', 'name': 'Skill $i'},
          type: 'upsert',
        );
      }

      var queue = await PendingProfileMutationQueue.loadQueue();
      expect(queue.length, 5);

      await PendingProfileMutationQueue.saveQueue([]);

      queue = await PendingProfileMutationQueue.loadQueue();
      expect(queue, isEmpty);
    });
  });

  group('Chaos Harness — Connectivity Flapping', () {
    test('FakeConnectivityFlapper emits correct number of flaps', () async {
      final flapper =
          FakeConnectivityFlapper(totalFlaps: 5, minFlapMs: 50, maxFlapMs: 100);
      final states = <bool>[];

      flapper.connectivityStream.listen(states.add);
      flapper.start();

      await Future.delayed(const Duration(seconds: 2));

      expect(states.length, 5);
      flapper.dispose();
    });
  });

  group('Chaos Harness — Session Expiry', () {
    test('FakeExpiredSession expires after threshold', () {
      final session = FakeExpiredSession(expireAfterCalls: 3);

      expect(session.checkSession(), true);
      expect(session.checkSession(), true);
      expect(session.checkSession(), true);
      expect(session.checkSession(), false);
      expect(session.isExpired, true);
    });

    test('FakeExpiredSession resets correctly', () {
      final session = FakeExpiredSession(expireAfterCalls: 1);
      session.checkSession();
      session.checkSession();
      expect(session.isExpired, true);

      session.reset();
      expect(session.isExpired, false);
      expect(session.callCount, 0);
      expect(session.checkSession(), true);
    });
  });

  group('Chaos Harness — Replay Interruption', () {
    test('FakeReplayInterruption throws after index', () {
      final interruptor = FakeReplayInterruption(interruptAfterIndex: 2);

      interruptor.beforeMutationReplay();
      interruptor.beforeMutationReplay();

      expect(
        () => interruptor.beforeMutationReplay(),
        throwsA(isA<ReplayInterruptedException>()),
      );
      expect(interruptor.wasInterrupted, true);
      expect(interruptor.processedCount, 2);
    });

    test('FakeReplayInterruption resets correctly', () {
      final interruptor = FakeReplayInterruption(interruptAfterIndex: 1);
      interruptor.beforeMutationReplay();
      try {
        interruptor.beforeMutationReplay();
      } catch (_) {}

      interruptor.reset();
      expect(interruptor.wasInterrupted, false);
      expect(interruptor.processedCount, 0);
    });
  });

  group('Chaos Harness — Queue Corruption', () {
    test('FakeQueueCorruptor generates valid corrupted payloads', () {
      final corruptor = FakeQueueCorruptor();

      final corrupted = corruptor.corruptedPayload();
      expect(corrupted['table'], '__nonexistent_table__');
      expect(corrupted.containsKey('payload'), true);
      expect(corrupted['type'], 'upsert');

      final rlsPayload = corruptor.rlsViolationPayload('fake_user_999');
      expect(rlsPayload['table'], 'user_profiles');
      expect(rlsPayload['payload']['user_id'], 'fake_user_999');

      final mismatch = corruptor.typeMismatchPayload();
      expect(mismatch['payload']['user_id'], isA<int>());
      expect(mismatch['payload']['name'], isA<bool>());
    });
  });

  group('Chaos Harness — Migration Timeout', () {
    test('FakeMigrationTimeout acquires lock with timeout', () async {
      final timeout = FakeMigrationTimeout(timeoutMs: 100);
      final result = await timeout.acquireLockWithTimeout();

      expect(result, false);
      expect(timeout.timedOut, true);
      expect(timeout.lockAcquired, false);
    });

    test('FakeMigrationTimeout resets correctly', () {
      final timeout = FakeMigrationTimeout();
      timeout.reset();
      expect(timeout.lockAcquired, false);
      expect(timeout.timedOut, false);
    });
  });
}
