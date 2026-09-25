import 'package:flutter_test/flutter_test.dart';
import 'package:grow/features/profile/data/profile_ecosystem_repository.dart';
import 'package:grow/features/profile/data/profile_migration_service.dart';
import 'package:grow/features/profile/domain/profile_migration_state.dart';
import 'package:grow/shared/models/profile_ecosystem_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _InMemoryProfileRepository extends ProfileEcosystemRepository {
  final Map<String, UserProfileModel> profiles = {};
  final Map<String, List<UserEducationModel>> education = {};
  final Map<String, List<UserSkillModel>> skills = {};
  final Map<String, List<String>> interests = {};
  final Map<String, List<UserSocialLinkModel>> socialLinks = {};
  bool failNextSkillWrite = false;
  int profileWrites = 0;

  @override
  Future<UserProfileModel?> getProfile(String userId) async => profiles[userId];

  @override
  Future<UserProfileModel> upsertProfile(UserProfileModel profile) async {
    profileWrites++;
    profiles[profile.userId] = profile;
    return profile;
  }

  @override
  Future<List<UserEducationModel>> getEducation(String userId) async =>
      education[userId] ?? const [];

  @override
  Future<UserEducationModel> addEducation(UserEducationModel item) async {
    education.putIfAbsent(item.userId, () => []).add(item);
    return item;
  }

  @override
  Future<List<UserSkillModel>> getSkills(String userId) async =>
      skills[userId] ?? const [];

  @override
  Future<UserSkillModel> upsertSkill(UserSkillModel skill) async {
    if (failNextSkillWrite) {
      failNextSkillWrite = false;
      throw StateError('Simulated persistence failure');
    }
    final rows = skills.putIfAbsent(skill.userId, () => []);
    final index = rows.indexWhere((row) => row.name == skill.name);
    if (index == -1) {
      rows.add(skill);
    } else {
      rows[index] = skill;
    }
    return skill;
  }

  @override
  Future<List<String>> getInterests(String userId) async =>
      interests[userId] ?? const [];

  @override
  Future<void> setInterests(String userId, List<String> values) async {
    interests[userId] = List.of(values);
  }

  @override
  Future<UserSocialLinkModel> upsertSocialLink(UserSocialLinkModel link) async {
    final rows = socialLinks.putIfAbsent(link.userId, () => []);
    final index = rows.indexWhere((row) => row.platform == link.platform);
    if (index == -1) {
      rows.add(link);
    } else {
      rows[index] = link;
    }
    return link;
  }
}

void main() {
  const userId = 'test-user';
  const draftKey = 'rc5_onboarding.$userId';
  late _InMemoryProfileRepository repository;
  late ProfileMigrationService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({
      '$draftKey.username': 'maker_one',
      '$draftKey.bio': 'I build small robots.',
      '$draftKey.userType': 'student',
      '$draftKey.department': 'Mechatronics',
      '$draftKey.interests': <String>['Robotics', 'Fabrication'],
      '$draftKey.skills': <String>['CAD:2', '3D printing:3', 'Invalid:9'],
      '$draftKey.edu_college': 'Model Engineering College',
      '$draftKey.edu_department': 'B.Tech',
      '$draftKey.edu_year': '2027',
      '$draftKey.social_github': 'https://github.com/maker-one',
    });
    repository = _InMemoryProfileRepository();
    service = ProfileMigrationService(repository);
  });

  test(
    'persists onboarding data before marking the profile complete',
    () async {
      var profileMarkedComplete = false;

      await service.completeOnboarding(
        userId,
        markProfileCompleted: () async {
          expect(repository.profiles[userId]?.username, 'maker_one');
          expect(
            repository.skills[userId]?.map((skill) => skill.name),
            containsAll(['CAD', '3D printing']),
          );
          expect(repository.interests[userId], ['Robotics', 'Fabrication']);
          expect(repository.education[userId], hasLength(1));
          expect(repository.socialLinks[userId], hasLength(1));
          profileMarkedComplete = true;
        },
      );

      expect(profileMarkedComplete, isTrue);
      expect(repository.profiles[userId]?.bio, 'I build small robots.');
      expect(repository.profiles[userId]?.department, 'Mechatronics');
      expect(repository.profiles[userId]?.userType, 'student');
      expect(
        await ProfileMigrationStorage.getMigrationState(userId),
        ProfileMigrationState.migrated,
      );
      expect(await ProfileMigrationStorage.getCheckpoints(userId), isEmpty);
      expect(
        await ProfileMigrationStorage.getSchemaVersion(userId),
        ProfileMigrationStorage.currentProfileSchemaVersion,
      );
    },
  );

  test(
    'preserves existing server values while filling empty profile fields',
    () async {
      repository.profiles[userId] = const UserProfileModel(
        id: 'server-profile',
        userId: userId,
        username: 'server_name',
        bio: 'Server bio',
        userType: 'faculty',
        department: '',
        isPublic: false,
        showStats: false,
      );
      repository.skills[userId] = [
        const UserSkillModel(
          id: 'server-skill',
          userId: userId,
          name: 'CAD',
          level: 1,
        ),
      ];
      repository.interests[userId] = ['Electronics'];

      await service.migrate(userId);

      final profile = repository.profiles[userId]!;
      expect(profile.id, 'server-profile');
      expect(profile.username, 'server_name');
      expect(profile.bio, 'Server bio');
      expect(profile.userType, 'faculty');
      expect(profile.department, 'Mechatronics');
      expect(profile.isPublic, isFalse);
      expect(profile.showStats, isFalse);
      expect(repository.skills[userId], hasLength(2));
      expect(
        repository.skills[userId]!
            .singleWhere((skill) => skill.name == 'CAD')
            .level,
        2,
      );
      expect(
        repository.interests[userId],
        containsAll(['Electronics', 'Robotics', 'Fabrication']),
      );
    },
  );

  test(
    'does not mark completion after a write failure and retries safely',
    () async {
      repository.failNextSkillWrite = true;
      var completionWrites = 0;

      await expectLater(
        service.completeOnboarding(
          userId,
          markProfileCompleted: () async => completionWrites++,
        ),
        throwsA(isA<StateError>()),
      );

      expect(completionWrites, 0);
      expect(
        await ProfileMigrationStorage.getMigrationState(userId),
        ProfileMigrationState.failed,
      );
      final failedCheckpoints = await ProfileMigrationStorage.getCheckpoints(
        userId,
      );
      expect(failedCheckpoints['profile'], isTrue);
      expect(failedCheckpoints['skills'], isFalse);

      await service.completeOnboarding(
        userId,
        markProfileCompleted: () async => completionWrites++,
      );

      expect(completionWrites, 1);
      expect(repository.profileWrites, 1);
      expect(repository.skills[userId], hasLength(2));
      expect(repository.education[userId], hasLength(1));
      expect(repository.interests[userId], hasLength(2));
      expect(
        await ProfileMigrationStorage.getMigrationState(userId),
        ProfileMigrationState.migrated,
      );
    },
  );

  test(
    'retries a failed completion flag without repeating profile writes',
    () async {
      await expectLater(
        service.completeOnboarding(
          userId,
          markProfileCompleted: () async {
            throw StateError('Simulated completion update failure');
          },
        ),
        throwsA(isA<StateError>()),
      );

      expect(
        await ProfileMigrationStorage.getMigrationState(userId),
        ProfileMigrationState.migrated,
      );
      var completionWrites = 0;
      await service.completeOnboarding(
        userId,
        markProfileCompleted: () async => completionWrites++,
      );
      expect(completionWrites, 1);
      expect(repository.profileWrites, 1);
      expect(repository.education[userId], hasLength(1));
      expect(repository.skills[userId], hasLength(2));
    },
  );
}
