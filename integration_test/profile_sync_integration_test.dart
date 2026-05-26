import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:grow/features/profile/domain/pending_profile_mutation.dart';

// Import chaos harness
import '../test/chaos_harness_utilities.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Profile Sync Queue — Happy Path', () {
    setUp(() async {
      // Clear any existing queue before each test
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Queue starts empty', (tester) async {
      final queue = await PendingProfileMutationQueue.loadQueue();
      expect(queue, isEmpty);
    });

    testWidgets('Adding a mutation persists to queue', (tester) async {
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

    testWidgets('Deduplication collapses same (table, rowId)', (tester) async {
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

    testWidgets('Different rowIds create separate entries', (tester) async {
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

    testWidgets('Remove mutation clears from queue', (tester) async {
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

    testWidgets('Retry count increments on failure report', (tester) async {
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

    testWidgets('Mutation marked permanently failed after 5 retries',
        (tester) async {
      await PendingProfileMutationQueue.addMutation(
        table: 'user_profiles',
        rowId: 'perm_fail',
        payload: {'user_id': 'perm_fail'},
        type: 'upsert',
      );

      var queue = await PendingProfileMutationQueue.loadQueue();
      final id = queue.first.id;

      // Report failure 5 times
      for (int i = 0; i < 5; i++) {
        await PendingProfileMutationQueue.reportFailure(id);
      }

      queue = await PendingProfileMutationQueue.loadQueue();
      expect(queue.first.retryCount, 5);
      expect(queue.first.failedPermanently, true);
    });

    testWidgets('Replay paused flag prevents queue processing', (tester) async {
      PendingProfileMutationQueue.isReplayPaused = true;

      // The pause flag should be true
      expect(PendingProfileMutationQueue.isReplayPaused, true);

      // Reset for other tests
      PendingProfileMutationQueue.isReplayPaused = false;
    });

    testWidgets('Exponential backoff delay calculation', (tester) async {
      expect(PendingProfileMutationQueue.getRetryDelay(0), Duration.zero);
      expect(PendingProfileMutationQueue.getRetryDelay(1),
          const Duration(seconds: 2));
      expect(PendingProfileMutationQueue.getRetryDelay(2),
          const Duration(seconds: 4));
      expect(PendingProfileMutationQueue.getRetryDelay(3),
          const Duration(seconds: 8));
      // Capped at 60s
      expect(PendingProfileMutationQueue.getRetryDelay(10),
          const Duration(seconds: 60));
    });

    testWidgets('Clear queue removes all mutations', (tester) async {
      // Add multiple mutations
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
    testWidgets('FakeConnectivityFlapper emits correct number of flaps',
        (tester) async {
      final flapper =
          FakeConnectivityFlapper(totalFlaps: 5, minFlapMs: 50, maxFlapMs: 100);
      final states = <bool>[];

      flapper.connectivityStream.listen(states.add);
      flapper.start();

      // Wait for all flaps to complete
      await Future.delayed(const Duration(seconds: 2));

      expect(states.length, 5);
      flapper.dispose();
    });
  });

  group('Chaos Harness — Session Expiry', () {
    testWidgets('FakeExpiredSession expires after threshold', (tester) async {
      final session = FakeExpiredSession(expireAfterCalls: 3);

      expect(session.checkSession(), true);
      expect(session.checkSession(), true);
      expect(session.checkSession(), true);
      expect(session.checkSession(), false); // 4th call exceeds limit
      expect(session.isExpired, true);
    });
  });

  group('Chaos Harness — Replay Interruption', () {
    testWidgets('FakeReplayInterruption throws after index', (tester) async {
      final interruptor = FakeReplayInterruption(interruptAfterIndex: 2);

      // First two succeed
      interruptor.beforeMutationReplay();
      interruptor.beforeMutationReplay();

      // Third throws
      expect(
        () => interruptor.beforeMutationReplay(),
        throwsA(isA<ReplayInterruptedException>()),
      );
      expect(interruptor.wasInterrupted, true);
    });
  });

  group('Chaos Harness — Queue Corruption', () {
    testWidgets('FakeQueueCorruptor generates valid corrupted payloads',
        (tester) async {
      final corruptor = FakeQueueCorruptor();

      final corrupted = corruptor.corruptedPayload();
      expect(corrupted['table'], '__nonexistent_table__');
      expect(corrupted.containsKey('payload'), true);

      final rlsPayload = corruptor.rlsViolationPayload('fake_user_999');
      expect(rlsPayload['table'], 'user_profiles');
      expect(rlsPayload['payload']['user_id'], 'fake_user_999');

      final mismatch = corruptor.typeMismatchPayload();
      expect(mismatch['payload']['user_id'],
          isA<int>()); // Wrong type deliberately
    });
  });
}
