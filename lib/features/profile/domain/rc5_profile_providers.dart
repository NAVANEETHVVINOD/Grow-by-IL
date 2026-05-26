import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grow/core/constants/feature_flags.dart';
import 'package:grow/core/utils/app_logger.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/explore/domain/event_providers.dart';
import 'package:grow/features/profile/data/profile_ecosystem_repository.dart';
import 'package:grow/features/profile/data/profile_migration_service.dart';
import 'package:grow/features/profile/domain/profile_migration_coordinator.dart';
import 'package:grow/features/profile/domain/profile_migration_state.dart';
import 'package:grow/features/projects/domain/project_providers.dart';
import 'package:grow/shared/models/profile_ecosystem_models.dart';
import 'package:grow/shared/models/project_model.dart';
import 'package:grow/shared/models/user_model.dart';
import 'package:grow/shared/repositories/supabase_client.dart';

class Rc5ProfileHeaderData {
  const Rc5ProfileHeaderData({
    required this.user,
    required this.username,
    required this.departmentOrRole,
    required this.bio,
    required this.interests,
    required this.skills,
  });

  final UserModel user;
  final String username;
  final String departmentOrRole;
  final String bio;
  final List<String> interests;
  final Map<String, int> skills;
}

class Rc5ProfileStats {
  const Rc5ProfileStats({
    required this.visits,
    required this.tools,
    required this.events,
    required this.projects,
  });

  final int visits;
  final int tools;
  final int events;
  final int projects;
}

class Rc5ProfileEventItem {
  const Rc5ProfileEventItem({
    required this.eventId,
    required this.title,
    required this.venue,
    required this.status,
  });

  final String eventId;
  final String title;
  final String? venue;
  final String status;
}

final rc5ProfileHeaderProvider =
    FutureProvider<Rc5ProfileHeaderData?>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return null;

  final repo = ref.watch(profileEcosystemRepositoryProvider);
  final migrationService = ProfileMigrationService(repo);

  UserProfileModel? serverProfile;
  List<String> interestsList = const [];
  Map<String, int> skillsMap = const {};

  try {
    // 1. Try to fetch profile from Supabase
    serverProfile = await repo.getProfile(user.id);

    // 2. Run Safe Onboarding Migration inside global coordinator mutex if needed
    if (serverProfile == null && FeatureFlags.kEnableProfileMigration) {
      final state = await ProfileMigrationStorage.getMigrationState(user.id);
      if (state != ProfileMigrationState.migrated) {
        AppLogger.info(LogCategory.profile, '[PROFILE_MIGRATION] Profile not found in Supabase. Checking migration state...');
        
        await ProfileMigrationCoordinator.run(() async {
          await migrationService.migrate(user.id);
        });
        
        // Refetch the migrated profile
        serverProfile = await repo.getProfile(user.id);
      }
    }

    if (serverProfile != null) {
      interestsList = await repo.getInterests(user.id);
      final skillsList = await repo.getSkills(user.id);
      final tempSkills = <String, int>{};
      for (final s in skillsList) {
        tempSkills[s.name] = s.level;
      }
      skillsMap = tempSkills;
    }
  } catch (e, st) {
    AppLogger.error(LogCategory.profile, 'Error loading profile from Supabase, attempting local cache fallback...', error: e, stack: st);
    
    // Offline Cache Fallback: Try loading from local SharedPreferences cache
    final cachedData = await ProfileMigrationStorage.getCachedProfileData(user.id);
    if (cachedData != null) {
      final cachedSkillsList = (cachedData['skills'] as List).cast<String>();
      final cachedSkillsMap = <String, int>{};
      for (final s in cachedSkillsList) {
        final parts = s.split(':');
        if (parts.length == 2) {
          cachedSkillsMap[parts[0]] = int.tryParse(parts[1]) ?? 1;
        }
      }
      return Rc5ProfileHeaderData(
        user: user,
        username: cachedData['username'] as String,
        departmentOrRole: cachedData['departmentOrRole'] as String,
        bio: cachedData['bio'] as String,
        interests: (cachedData['interests'] as List).cast<String>(),
        skills: cachedSkillsMap,
      );
    }
  }

  // 3. Construct header data and cache it locally
  final username = serverProfile?.username ?? _deriveUsernameFromEmail(user.email);
  final bio = serverProfile?.bio ?? 'Builder at IDEA Lab, exploring projects and collaboration.';
  final department = serverProfile?.department ??
      (serverProfile?.userType == 'professional' ? 'Professional' : 'Student, IDEA Lab');

  final headerData = Rc5ProfileHeaderData(
    user: user,
    username: username,
    departmentOrRole: department,
    bio: bio,
    interests: interestsList,
    skills: skillsMap,
  );

  // Write to local cache asynchronously
  await ProfileMigrationStorage.cacheProfileData(
    userId: user.id,
    username: username,
    departmentOrRole: department,
    bio: bio,
    interests: interestsList,
    skills: skillsMap,
  );

  return headerData;
});

final rc5ProfileStatsProvider = FutureProvider<Rc5ProfileStats>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) {
    return const Rc5ProfileStats(visits: 0, tools: 0, events: 0, projects: 0);
  }

  // Fetch all counts in parallel
  final responses = await Future.wait([
    supabase.from('lab_sessions').select('id').eq('user_id', user.id),
    supabase
        .from('tool_bookings')
        .select('tool_id')
        .eq('user_id', user.id)
        .eq('status', 'returned'),
    supabase.from('rsvps').select('id').eq('user_id', user.id),
    supabase.from('project_members').select('id').eq('user_id', user.id),
  ]);

  final visits = (responses[0] as List).length;
  final tools = (responses[1] as List)
      .map((row) => row['tool_id'] as String)
      .toSet()
      .length;
  final events = (responses[2] as List).length;
  final projects = (responses[3] as List).length;

  return Rc5ProfileStats(
    visits: visits,
    tools: tools,
    events: events,
    projects: projects,
  );
});

final rc5ProfileProjectsProvider =
    Provider<AsyncValue<List<ProjectModel>>>((ref) {
  final projectsAsync = ref.watch(userProjectsProvider);
  return projectsAsync.whenData((projects) => projects.take(12).toList());
}, name: 'rc5ProfileProjectsProvider');

final rc5PublicProjectsProvider =
    Provider<AsyncValue<List<ProjectModel>>>((ref) {
  final projectsAsync = ref.watch(rc5ProfileProjectsProvider);
  return projectsAsync.whenData(
      (projects) => projects.where((project) => project.isPublic).toList());
}, name: 'rc5PublicProjectsProvider');

final rc5PrivateProjectsProvider =
    Provider<AsyncValue<List<ProjectModel>>>((ref) {
  final projectsAsync = ref.watch(rc5ProfileProjectsProvider);
  return projectsAsync.whenData(
      (projects) => projects.where((project) => !project.isPublic).toList());
}, name: 'rc5PrivateProjectsProvider');

final rc5ProfileEventParticipationProvider =
    Provider<AsyncValue<List<Rc5ProfileEventItem>>>((ref) {
  final itemsAsync = ref.watch(myRsvpsWithEventsProvider);
  return itemsAsync.whenData((items) {
    return items
        .take(10)
        .map(
          (entry) => Rc5ProfileEventItem(
            eventId: entry.event.id,
            title: entry.event.title,
            venue: entry.event.venue,
            status: entry.rsvp.status,
          ),
        )
        .toList();
  });
}, name: 'rc5ProfileEventParticipationProvider');

final rc5ProfileInterestsProvider = Provider<AsyncValue<List<String>>>((ref) {
  final headerAsync = ref.watch(rc5ProfileHeaderProvider);
  return headerAsync
      .whenData((header) => header?.interests ?? const <String>[]);
}, name: 'rc5ProfileInterestsProvider');

final rc5ProfileSkillsProvider = Provider<AsyncValue<Map<String, int>>>((ref) {
  final headerAsync = ref.watch(rc5ProfileHeaderProvider);
  return headerAsync
      .whenData((header) => header?.skills ?? const <String, int>{});
});

String _deriveUsernameFromEmail(String email) {
  final local = email.split('@').first.toLowerCase();
  final normalized = local
      .replaceAll(RegExp(r'[^a-z0-9_]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  return normalized.isEmpty ? 'grow_user' : normalized;
}
