import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/explore/domain/event_providers.dart';

import 'package:grow/features/projects/domain/project_providers.dart';
import 'package:grow/shared/models/project_model.dart';
import 'package:grow/shared/models/user_model.dart';
import 'package:grow/shared/repositories/supabase_client.dart';
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
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) {
    return const Rc5ProfileStats(visits: 0, tools: 0, events: 0, projects: 0);
  }

  // Fetch all counts in parallel
  final responses = await Future.wait([
    supabase.from('lab_sessions').select('id').eq('user_id', user.id),
    supabase.from('tool_bookings').select('tool_id').eq('user_id', user.id).eq('status', 'returned'),
    supabase.from('rsvps').select('id').eq('user_id', user.id),
    supabase.from('project_members').select('id').eq('user_id', user.id),
  ]);

  final visits = (responses[0] as List).length;
  final tools = (responses[1] as List).map((row) => row['tool_id'] as String).toSet().length;
  final events = (responses[2] as List).length;
  final projects = (responses[3] as List).length;

  return Rc5ProfileStats(
    visits: visits,
    tools: tools,
    events: events,
    projects: projects,
  );
});

final rc5ProfileProjectsProvider = Provider<AsyncValue<List<ProjectModel>>>((ref) {
  final projectsAsync = ref.watch(userProjectsProvider);
  return projectsAsync.whenData((projects) => projects.take(12).toList());
}, name: 'rc5ProfileProjectsProvider');

final rc5PublicProjectsProvider = Provider<AsyncValue<List<ProjectModel>>>((ref) {
  final projectsAsync = ref.watch(rc5ProfileProjectsProvider);
  return projectsAsync.whenData(
      (projects) => projects.where((project) => project.isPublic).toList());
}, name: 'rc5PublicProjectsProvider');

final rc5PrivateProjectsProvider = Provider<AsyncValue<List<ProjectModel>>>((ref) {
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
  return headerAsync.whenData((header) => header?.interests ?? const <String>[]);
}, name: 'rc5ProfileInterestsProvider');

final rc5ProfileSkillsProvider = Provider<AsyncValue<Map<String, int>>>((ref) {
  final headerAsync = ref.watch(rc5ProfileHeaderProvider);
  return headerAsync.whenData((header) => header?.skills ?? const <String, int>{});
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
