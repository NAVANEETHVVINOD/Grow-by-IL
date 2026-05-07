import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/project_model.dart';
import '../../../shared/models/project_member_model.dart';
import '../../../shared/models/project_update_model.dart';
import '../../../shared/repositories/supabase_client.dart';
import '../../auth/data/auth_repository.dart';
import '../data/project_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(supabase);
});

final publicProjectsProvider = FutureProvider<List<ProjectModel>>((ref) async {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.getPublicProjects();
});

final userProjectsProvider = FutureProvider<List<ProjectModel>>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return [];
  
  final repo = ref.watch(projectRepositoryProvider);
  return repo.getMyProjects(user.id);
});

final projectDetailProvider = FutureProvider.family<ProjectModel, String>((ref, id) async {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.getProjectById(id);
});

final projectMembersProvider = FutureProvider.family<List<ProjectMemberModel>, String>((ref, id) async {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.getProjectMembers(id);
});

final projectUpdatesProvider = FutureProvider.family<List<ProjectUpdateModel>, String>((ref, id) async {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.getProjectUpdates(id);
});

final userMembershipProvider = FutureProvider.family<ProjectMemberModel?, String>((ref, projectId) async {
  final members = await ref.watch(projectMembersProvider(projectId).future);
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return null;
  
  return members.where((m) => m.userId == user.id).firstOrNull;
});
