import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/explore/domain/event_providers.dart';
import 'package:grow/features/profile/domain/profile_providers.dart';
import 'package:grow/features/projects/domain/project_providers.dart';
import 'package:grow/shared/models/project_model.dart';
import 'package:grow/shared/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final draft = await _loadOnboardingDraft(user.id);
  final username = draft.username.isNotEmpty
      ? draft.username
      : _deriveUsernameFromEmail(user.email);
  final bio = draft.bio.isNotEmpty
      ? draft.bio
      : 'Builder at IDEA Lab, exploring projects and collaboration.';
  final department = draft.departmentOrRole.isNotEmpty
      ? draft.departmentOrRole
      : (draft.userType == 'professional'
          ? 'Professional'
          : 'Student, IDEA Lab');

  return Rc5ProfileHeaderData(
    user: user,
    username: username,
    departmentOrRole: department,
    bio: bio,
    interests: draft.interests,
    skills: draft.skills,
  );
});

final rc5ProfileStatsProvider = FutureProvider<Rc5ProfileStats>((ref) async {
  final visits = await ref.watch(userLabVisitsCountProvider.future);
  final tools = await ref.watch(userToolsUsedCountProvider.future);
  final events = await ref.watch(userEventsCountProvider.future);
  final projects = await ref.watch(userProjectsCountProvider.future);

  return Rc5ProfileStats(
    visits: visits,
    tools: tools,
    events: events,
    projects: projects,
  );
});

final rc5ProfileProjectsProvider =
    FutureProvider<List<ProjectModel>>((ref) async {
  final projects = await ref.watch(userProjectsProvider.future);
  return projects.take(12).toList();
});

final rc5PublicProjectsProvider =
    FutureProvider<List<ProjectModel>>((ref) async {
  final projects = await ref.watch(rc5ProfileProjectsProvider.future);
  return projects.where((project) => project.isPublic).toList();
});

final rc5ProfileEventParticipationProvider =
    FutureProvider<List<Rc5ProfileEventItem>>((ref) async {
  final items = await ref.watch(myRsvpsWithEventsProvider.future);
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

final rc5ProfileInterestsProvider = FutureProvider<List<String>>((ref) async {
  final header = await ref.watch(rc5ProfileHeaderProvider.future);
  return header?.interests ?? const <String>[];
});

final rc5ProfileSkillsProvider = FutureProvider<Map<String, int>>((ref) async {
  final header = await ref.watch(rc5ProfileHeaderProvider.future);
  return header?.skills ?? const <String, int>{};
});

class _DraftData {
  const _DraftData({
    required this.username,
    required this.bio,
    required this.userType,
    required this.departmentOrRole,
    required this.interests,
    required this.skills,
  });

  final String username;
  final String bio;
  final String userType;
  final String departmentOrRole;
  final List<String> interests;
  final Map<String, int> skills;
}

Future<_DraftData> _loadOnboardingDraft(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'rc5_onboarding.$userId';

  final interests = prefs.getStringList('$key.interests') ?? const [];
  final skillEntries = prefs.getStringList('$key.skills') ?? const [];
  final skills = <String, int>{};

  for (final entry in skillEntries) {
    final parts = entry.split(':');
    if (parts.length != 2) continue;
    final level = int.tryParse(parts.last);
    if (level == null || level < 1 || level > 3) continue;
    skills[parts.first] = level;
  }

  return _DraftData(
    username: prefs.getString('$key.username') ?? '',
    bio: prefs.getString('$key.bio') ?? '',
    userType: prefs.getString('$key.userType') ?? 'student',
    departmentOrRole: prefs.getString('$key.department') ?? '',
    interests: interests.take(5).toList(),
    skills: skills,
  );
}

String _deriveUsernameFromEmail(String email) {
  final local = email.split('@').first.toLowerCase();
  final normalized = local
      .replaceAll(RegExp(r'[^a-z0-9_]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  return normalized.isEmpty ? 'grow_user' : normalized;
}
