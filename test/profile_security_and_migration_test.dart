import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:grow/features/profile/domain/profile_migration_state.dart';
import 'package:grow/features/profile/domain/profile_migration_coordinator.dart';
import 'package:grow/features/profile/domain/pending_profile_mutation.dart';
import 'package:grow/features/profile/data/profile_ecosystem_repository.dart';
import 'package:grow/shared/models/profile_ecosystem_models.dart';

class MockProfileEcosystemRepository extends ProfileEcosystemRepository {
  final Map<String, UserProfileModel> profiles = {};
  final Map<String, List<UserSkillModel>> skills = {};
  final Map<String, List<String>> interests = {};
  final Map<String, List<UserEducationModel>> education = {};
  final Map<String, List<UserSocialLinkModel>> socialLinks = {};

  int getProfileCalls = 0;
  int upsertProfileCalls = 0;
  int getSkillsCalls = 0;
  int upsertSkillCalls = 0;
  int getInterestsCalls = 0;
  int setInterestsCalls = 0;
  int getEducationCalls = 0;
  int addEducationCalls = 0;
  int upsertSocialLinkCalls = 0;

  @override
  Future<UserProfileModel?> getProfile(String userId) async {
    getProfileCalls++;
    return profiles[userId];
  }

  @override
  Future<UserProfileModel> upsertProfile(UserProfileModel profile) async {
    upsertProfileCalls++;
    profiles[profile.userId] = profile;
    return profile;
  }

  @override
  Future<List<UserSkillModel>> getSkills(String userId) async {
    getSkillsCalls++;
    return skills[userId] ?? [];
  }

  @override
  Future<UserSkillModel> upsertSkill(UserSkillModel skill) async {
    upsertSkillCalls++;
    final list = skills[skill.userId] ?? [];
    list.removeWhere((s) => s.name == skill.name);
    list.add(skill);
    skills[skill.userId] = list;
    return skill;
  }

  @override
  Future<List<String>> getInterests(String userId) async {
    getInterestsCalls++;
    return interests[userId] ?? [];
  }

  @override
  Future<void> setInterests(String userId, List<String> interestList) async {
    setInterestsCalls++;
    interests[userId] = interestList;
  }

  @override
  Future<List<UserEducationModel>> getEducation(String userId) async {
    getEducationCalls++;
    return education[userId] ?? [];
  }

  @override
  Future<UserEducationModel> addEducation(UserEducationModel item) async {
    addEducationCalls++;
    final list = education[item.userId] ?? [];
    list.add(item);
    education[item.userId] = list;
    return item;
  }

  @override
  Future<UserSocialLinkModel> upsertSocialLink(UserSocialLinkModel link) async {
    upsertSocialLinkCalls++;
    final list = socialLinks[link.userId] ?? [];
    list.removeWhere((s) => s.platform == link.platform);
    list.add(link);
    socialLinks[link.userId] = list;
    return link;
  }
}

void main() {
  const userId = 'user_123';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ProfileMigrationStorage Tests', () {
    test('Default states and storage updates', () async {
      var state = await ProfileMigrationStorage.getMigrationState(userId);
      expect(state, ProfileMigrationState.localOnly);

      await ProfileMigrationStorage.setMigrationState(
          userId, ProfileMigrationState.migrating);
      state = await ProfileMigrationStorage.getMigrationState(userId);
      expect(state, ProfileMigrationState.migrating);

      var version = await ProfileMigrationStorage.getSchemaVersion(userId);
      expect(version, 0);

      await ProfileMigrationStorage.setSchemaVersion(userId, 2);
      version = await ProfileMigrationStorage.getSchemaVersion(userId);
      expect(version, 2);
    });

    test('Checkpoint management', () async {
      var checkpoints = await ProfileMigrationStorage.getCheckpoints(userId);
      expect(checkpoints.isEmpty, true);

      final initial = {'profile': true, 'skills': false};
      await ProfileMigrationStorage.setCheckpoints(userId, initial);

      checkpoints = await ProfileMigrationStorage.getCheckpoints(userId);
      expect(checkpoints['profile'], true);
      expect(checkpoints['skills'], false);

      await ProfileMigrationStorage.clearCheckpoints(userId);
      checkpoints = await ProfileMigrationStorage.getCheckpoints(userId);
      expect(checkpoints.isEmpty, true);
    });

    test('Local cache data persistence', () async {
      var cache = await ProfileMigrationStorage.getCachedProfileData(userId);
      expect(cache, null);

      await ProfileMigrationStorage.cacheProfileData(
        userId: userId,
        username: 'test_user',
        departmentOrRole: 'Engineer',
        bio: 'Hello world',
        interests: ['flutter', 'supabase'],
        skills: {'Dart': 3},
      );

      cache = await ProfileMigrationStorage.getCachedProfileData(userId);
      expect(cache, isNotNull);
      expect(cache!['username'], 'test_user');
      expect(cache['bio'], 'Hello world');
      expect(cache['interests'], ['flutter', 'supabase']);
      expect(cache['skills'], ['Dart:3']);
    });
  });

  group('ProfileMigrationCoordinator Mutex Tests', () {
    test('Ensures mutual exclusion and duplicate start prevention', () async {
      final list = <int>[];

      final f1 = ProfileMigrationCoordinator.run(() async {
        list.add(1);
        await Future.delayed(const Duration(milliseconds: 100));
        list.add(2);
      });

      final f2 = ProfileMigrationCoordinator.run(() async {
        list.add(3);
      });

      await Future.wait([f1, f2]);

      // Because f2 is requested while f1 is active, f2 immediately awaits f1's completer.
      // Therefore, the callback for f2 is NOT executed again, it just resolves f1's future.
      expect(list, [1, 2]);
    });
  });

  group('Offline Queue Tests (PendingProfileMutationQueue)', () {
    test('Deduplication collapses rapid writes on the same rowId', () async {
      await PendingProfileMutationQueue.addMutation(
        table: 'user_profiles',
        rowId: userId,
        payload: {'bio': 'First bio'},
      );

      await PendingProfileMutationQueue.addMutation(
        table: 'user_profiles',
        rowId: userId,
        payload: {'bio': 'Second bio'},
      );

      final queue = await PendingProfileMutationQueue.loadQueue();
      expect(queue.length, 1);
      expect(queue.first.payload['bio'], 'Second bio');
    });

    test('Exponential backoff delay calculation', () async {
      expect(PendingProfileMutationQueue.getRetryDelay(0), Duration.zero);
      expect(PendingProfileMutationQueue.getRetryDelay(1),
          const Duration(seconds: 2));
      expect(PendingProfileMutationQueue.getRetryDelay(2),
          const Duration(seconds: 4));
      expect(PendingProfileMutationQueue.getRetryDelay(3),
          const Duration(seconds: 8));
      expect(PendingProfileMutationQueue.getRetryDelay(5),
          const Duration(seconds: 32));
      expect(PendingProfileMutationQueue.getRetryDelay(6),
          const Duration(seconds: 60)); // capped at 60s
    });

    test('Stale write detection field propagation', () async {
      final now = DateTime.now().toUtc();
      await PendingProfileMutationQueue.addMutation(
        table: 'user_profiles',
        rowId: userId,
        payload: {'bio': 'New bio'},
        lastKnownServerUpdatedAt: now,
      );

      final queue = await PendingProfileMutationQueue.loadQueue();
      expect(queue.first.lastKnownServerUpdatedAt, isNotNull);
      expect(queue.first.lastKnownServerUpdatedAt!.toIso8601String(),
          now.toIso8601String());
    });

    test('Partial queue replay preservation and failure increment', () async {
      await PendingProfileMutationQueue.addMutation(
        table: 'user_profiles',
        rowId: 'row1',
        payload: {'username': 'u1'},
      );
      await PendingProfileMutationQueue.addMutation(
        table: 'user_profiles',
        rowId: 'row2',
        payload: {'username': 'u2'},
      );

      var queue = await PendingProfileMutationQueue.loadQueue();
      expect(queue.length, 2);

      // Report failure on row1
      final row1Id = queue.firstWhere((e) => e.rowId == 'row1').id;
      await PendingProfileMutationQueue.reportFailure(row1Id);

      queue = await PendingProfileMutationQueue.loadQueue();
      final failedItem = queue.firstWhere((e) => e.rowId == 'row1');
      expect(failedItem.retryCount, 1);
      expect(failedItem.failedPermanently, false);

      // Successfully process and remove row2
      final row2Id = queue.firstWhere((e) => e.rowId == 'row2').id;
      await PendingProfileMutationQueue.removeMutation(row2Id);

      queue = await PendingProfileMutationQueue.loadQueue();
      expect(queue.length, 1);
      expect(queue.first.rowId, 'row1');
    });

    test('Retry cap marks permanently failed after 5 retries', () async {
      await PendingProfileMutationQueue.addMutation(
        table: 'user_profiles',
        rowId: 'row1',
        payload: {'bio': 'trial'},
      );

      var queue = await PendingProfileMutationQueue.loadQueue();
      final mutId = queue.first.id;

      for (var i = 0; i < 5; i++) {
        await PendingProfileMutationQueue.reportFailure(mutId);
      }

      queue = await PendingProfileMutationQueue.loadQueue();
      expect(queue.first.failedPermanently, true);
    });
  });

  group('Ecosystem Repository Replay Tests', () {
    late MockSupabaseClient mockSupabase;
    late MockGoTrueClient mockAuth;
    late MockSupabaseQueryBuilder mockQuery;
    late ProfileEcosystemRepository repo;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      mockQuery = MockSupabaseQueryBuilder();

      when(() => mockSupabase.auth).thenReturn(mockAuth);
      when(() => mockSupabase.from(any())).thenAnswer((_) => mockQuery);

      repo = ProfileEcosystemRepository(mockSupabase);
    });

    test(
        'Replay suspends sync when auth is expired / null session, keeping queue intact',
        () async {
      when(() => mockAuth.currentSession).thenReturn(null);

      // Queue a mutation
      await PendingProfileMutationQueue.addMutation(
        table: 'user_profiles',
        rowId: 'row-abc',
        payload: {'bio': 'Sync suspension test'},
      );

      var queue = await PendingProfileMutationQueue.loadQueue();
      expect(queue.length, 1);

      // Trigger replay
      await repo.replayQueue();

      // Verify queue is still intact and not replayed
      queue = await PendingProfileMutationQueue.loadQueue();
      expect(queue.length, 1);
      expect(queue.first.rowId, 'row-abc');
      verifyNever(() => mockSupabase.from(any()));
    });

    test('Stale write detection discards stale updates when remote is newer',
        () async {
      final now = DateTime.now().toUtc();
      final baseTime = now.subtract(const Duration(minutes: 10));
      final serverTime = now.subtract(const Duration(minutes: 2));

      final fakeUser = User(
        id: 'user-123',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'test@grow.com',
      );

      final fakeSession = Session(
        accessToken: 'token-abc',
        tokenType: 'bearer',
        user: fakeUser,
        refreshToken: 'refresh-token',
        expiresIn: 3600,
      );

      when(() => mockAuth.currentSession).thenReturn(fakeSession);

      // Setup server check mock return: updated_at is serverTime (newer than baseTime)
      final fakeFilter = FakePostgrestFilterBuilder<List<Map<String, dynamic>>>(
          {'updated_at': serverTime.toIso8601String()});
      when(() => mockQuery.select('updated_at')).thenAnswer((_) => fakeFilter);

      // Queue a mutation with baseTime
      await PendingProfileMutationQueue.addMutation(
        table: 'user_profiles',
        rowId: 'row-stale',
        payload: {'bio': 'Stale write'},
        lastKnownServerUpdatedAt: baseTime,
      );

      var queue = await PendingProfileMutationQueue.loadQueue();
      expect(queue.length, 1);

      // Trigger replay
      await repo.replayQueue();

      // Verify mutation is discarded (removed from queue)
      queue = await PendingProfileMutationQueue.loadQueue();
      expect(queue.isEmpty, true);

      // Verify that upsert was NEVER called because it was stale
      verifyNever(() => mockQuery.upsert(any()));
    });

    test(
        'Successful replay of delete_by_name and delete_by_platform removes them from queue',
        () async {
      final fakeUser = User(
        id: 'user-123',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'test@grow.com',
      );

      final fakeSession = Session(
        accessToken: 'token-abc',
        tokenType: 'bearer',
        user: fakeUser,
        refreshToken: 'refresh-token',
        expiresIn: 3600,
      );

      when(() => mockAuth.currentSession).thenReturn(fakeSession);
      when(() => mockQuery.delete()).thenAnswer((_) =>
          FakePostgrestFilterBuilder<List<Map<String, dynamic>>>(
              <Map<String, dynamic>>[]));

      // 1. Queue a delete_by_name
      await PendingProfileMutationQueue.addMutation(
        table: 'user_skills',
        rowId: 'skill_user-123_Dart',
        payload: {'user_id': 'user-123', 'name': 'Dart'},
        type: 'delete_by_name',
      );

      // 2. Queue a delete_by_platform
      await PendingProfileMutationQueue.addMutation(
        table: 'user_social_links',
        rowId: 'social_user-123_github',
        payload: {'user_id': 'user-123', 'platform': 'github'},
        type: 'delete_by_platform',
      );

      var queue = await PendingProfileMutationQueue.loadQueue();
      expect(queue.length, 2);

      // Trigger replay
      await repo.replayQueue();

      // Verify they are completed and removed from queue
      queue = await PendingProfileMutationQueue.loadQueue();
      expect(queue.isEmpty, true);

      verify(() => mockSupabase.from('user_skills')).called(2);
      verify(() => mockSupabase.from('user_social_links')).called(2);
      verify(() => mockQuery.delete()).called(2);
    });
  });
}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class FakePostgrestTransformBuilder<T> extends Fake
    implements PostgrestTransformBuilder<T> {
  FakePostgrestTransformBuilder(this._value);
  final T _value;

  @override
  Future<R> then<R>(FutureOr<R> Function(T) onValue, {Function? onError}) {
    return Future.value(onValue(_value));
  }
}

class FakePostgrestFilterBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {
  FakePostgrestFilterBuilder(this._value);
  final Object? _value;

  @override
  PostgrestFilterBuilder<T> eq(String column, Object value) => this;

  @override
  PostgrestTransformBuilder<Map<String, dynamic>?> maybeSingle() {
    return FakePostgrestTransformBuilder<Map<String, dynamic>?>(
        _value as Map<String, dynamic>?);
  }

  @override
  Future<R> then<R>(FutureOr<R> Function(T) onValue, {Function? onError}) {
    return Future.value(onValue(_value as T));
  }
}
