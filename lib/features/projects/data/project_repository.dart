import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/app_logger.dart';
import '../../../shared/models/project_model.dart';
import '../../../shared/models/project_member_model.dart';
import '../../../shared/models/project_update_model.dart';

class ProjectRepository {
  ProjectRepository(this._client);
  final SupabaseClient _client;

  /// Fetch public projects for discovery.
  Future<List<ProjectModel>> getPublicProjects() async {
    AppLogger.action(LogCategory.projects, 'getPublicProjects');
    try {
      final data = await _client
          .from('projects')
          .select()
          .eq('visibility', 'public')
          .eq('status', 'active')
          .order('updated_at', ascending: false);
      return (data as List).map((row) => ProjectModel.fromJson(row)).toList();
    } catch (e, st) {
      AppLogger.error(LogCategory.projects, 'getPublicProjects failed', error: e, stack: st);
      rethrow;
    }
  }

  /// Fetch projects the user is a member of.
  Future<List<ProjectModel>> getMyProjects(String userId) async {
    AppLogger.action(LogCategory.projects, 'getMyProjects', {'userId': userId});
    try {
      final data = await _client
          .from('projects')
          .select('*, project_members!inner(user_id)')
          .eq('project_members.user_id', userId)
          .neq('status', 'archived')
          .order('updated_at', ascending: false);
      return (data as List).map((row) => ProjectModel.fromJson(row)).toList();
    } catch (e, st) {
      AppLogger.error(LogCategory.projects, 'getMyProjects failed', error: e, stack: st);
      rethrow;
    }
  }

  /// Fetch project details by ID.
  Future<ProjectModel> getProjectById(String id) async {
    try {
      final data = await _client.from('projects').select().eq('id', id).single();
      return ProjectModel.fromJson(data);
    } catch (e, st) {
      AppLogger.error(LogCategory.projects, 'getProjectById failed', error: e, stack: st);
      rethrow;
    }
  }

  /// Fetch members of a project.
  Future<List<ProjectMemberModel>> getProjectMembers(String projectId) async {
    try {
      final data = await _client
          .from('project_members')
          .select('*, users(name, avatar_url)')
          .eq('project_id', projectId);
      return (data as List).map((row) => ProjectMemberModel.fromJson(row)).toList();
    } catch (e, st) {
      AppLogger.error(LogCategory.projects, 'getProjectMembers failed', error: e, stack: st);
      rethrow;
    }
  }

  /// Create a new project and assign the creator as 'owner'.
  Future<ProjectModel> createProject(Map<String, dynamic> projectData) async {
    AppLogger.action(LogCategory.projects, 'createProject');
    try {
      // 1. Insert Project
      final data = await _client.from('projects').insert(projectData).select().single();
      final project = ProjectModel.fromJson(data);

      // 2. Add creator as Owner
      await _client.from('project_members').insert({
        'project_id': project.id,
        'user_id': project.createdBy,
        'role': 'owner',
      });

      AppLogger.info(LogCategory.projects, 'Project created successfully: ${project.id}');
      return project;
    } catch (e, st) {
      AppLogger.error(LogCategory.projects, 'createProject failed', error: e, stack: st);
      rethrow;
    }
  }

  /// Join a project instantly as a 'member'.
  Future<void> joinProject(String projectId, String userId) async {
    AppLogger.action(LogCategory.projects, 'joinProject', {'projectId': projectId, 'userId': userId});
    try {
      await _client.from('project_members').insert({
        'project_id': projectId,
        'user_id': userId,
        'role': 'member',
      });

      // Notify Owner
      final project = await getProjectById(projectId);
      await _client.from('notifications').insert({
        'user_id': project.createdBy,
        'type': 'project_join',
        'title': 'New Team Member',
        'message': 'Someone just joined "${project.title}".',
        'related_id': projectId,
      });

      AppLogger.info(LogCategory.projects, 'User $userId joined project $projectId');
    } catch (e, st) {
      AppLogger.error(LogCategory.projects, 'joinProject failed', error: e, stack: st);
      rethrow;
    }
  }

  /// Leave a project.
  Future<void> leaveProject(String projectId, String userId) async {
    AppLogger.action(LogCategory.projects, 'leaveProject', {'projectId': projectId, 'userId': userId});
    try {
      await _client
          .from('project_members')
          .delete()
          .match({'project_id': projectId, 'user_id': userId});
      AppLogger.info(LogCategory.projects, 'User $userId left project $projectId');
    } catch (e, st) {
      AppLogger.error(LogCategory.projects, 'leaveProject failed', error: e, stack: st);
      rethrow;
    }
  }

  /// Update project settings (Restricted to owner/admin).
  Future<void> updateProject(String projectId, Map<String, dynamic> updates) async {
    AppLogger.action(LogCategory.projects, 'updateProject', {'projectId': projectId});
    try {
      await _client.from('projects').update(updates).eq('id', projectId);
      AppLogger.info(LogCategory.projects, 'Project $projectId updated');
    } catch (e, st) {
      AppLogger.error(LogCategory.projects, 'updateProject failed', error: e, stack: st);
      rethrow;
    }
  }

  /// Transfer ownership of a project.
  Future<void> transferOwnership(String projectId, String newOwnerId) async {
    AppLogger.action(LogCategory.projects, 'transferOwnership', {'projectId': projectId, 'newOwnerId': newOwnerId});
    try {
      final project = await getProjectById(projectId);
      final oldOwnerId = project.createdBy;

      // 1. Update Project Creator
      await _client.from('projects').update({'created_by': newOwnerId}).eq('id', projectId);

      // 2. Swap Roles in project_members
      await _client.from('project_members').update({'role': 'admin'}).match({'project_id': projectId, 'user_id': oldOwnerId});
      await _client.from('project_members').upsert({
        'project_id': projectId,
        'user_id': newOwnerId,
        'role': 'owner',
      }, onConflict: 'project_id, user_id');

      AppLogger.info(LogCategory.projects, 'Ownership of $projectId transferred to $newOwnerId');
    } catch (e, st) {
      AppLogger.error(LogCategory.projects, 'transferOwnership failed', error: e, stack: st);
      rethrow;
    }
  }

  /// Archive a project.
  Future<void> archiveProject(String projectId) async {
    AppLogger.action(LogCategory.projects, 'archiveProject', {'projectId': projectId});
    try {
      await _client.from('projects').update({
        'status': 'archived',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', projectId);
      AppLogger.info(LogCategory.projects, 'Project $projectId archived');
    } catch (e, st) {
      AppLogger.error(LogCategory.projects, 'archiveProject failed', error: e, stack: st);
      rethrow;
    }
  }

  /// Fetch updates for a project.
  Future<List<ProjectUpdateModel>> getProjectUpdates(String projectId) async {
    try {
      // Stubbed for RC1: project_updates table not yet in schema
      AppLogger.info(LogCategory.projects, 'getProjectUpdates | Returning empty (Table pending)');
      return [];
    } catch (e, st) {
      AppLogger.error(LogCategory.projects, 'getProjectUpdates failed', error: e, stack: st);
      return [];
    }
  }

  /// Add an update to a project.
  Future<void> addProjectUpdate(String projectId, String userId, String content) async {
    try {
      await _client.from('project_updates').insert({
        'project_id': projectId,
        'user_id': userId,
        'content': content,
      });
      AppLogger.info(LogCategory.projects, 'Project update added for $projectId');
    } catch (e, st) {
      AppLogger.error(LogCategory.projects, 'addProjectUpdate failed', error: e, stack: st);
      rethrow;
    }
  }
}
