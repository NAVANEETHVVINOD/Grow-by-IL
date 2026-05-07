import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/app_logger.dart';
import '../../../shared/models/project_model.dart';
import '../../../shared/models/project_member_model.dart';

class ProjectRepository {
  ProjectRepository(this._client);
  final SupabaseClient _client;

  /// Fetch public projects for discovery.
  Future<List<ProjectModel>> getPublicProjects() async {
    AppLogger.action('Project', 'getPublicProjects');
    try {
      final data = await _client
          .from('projects')
          .select()
          .eq('visibility', 'public')
          .eq('status', 'active')
          .order('updated_at', ascending: false);
      return (data as List).map((row) => ProjectModel.fromJson(row)).toList();
    } catch (e, st) {
      AppLogger.error('Project', 'getPublicProjects failed', e, st);
      rethrow;
    }
  }

  /// Fetch projects the user is a member of.
  Future<List<ProjectModel>> getMyProjects(String userId) async {
    AppLogger.action('Project', 'getMyProjects', data: {'userId': userId});
    try {
      final data = await _client
          .from('projects')
          .select('*, project_members!inner(user_id)')
          .eq('project_members.user_id', userId)
          .neq('status', 'archived')
          .order('updated_at', ascending: false);
      return (data as List).map((row) => ProjectModel.fromJson(row)).toList();
    } catch (e, st) {
      AppLogger.error('Project', 'getMyProjects failed', e, st);
      rethrow;
    }
  }

  /// Fetch project details by ID.
  Future<ProjectModel> getProjectById(String id) async {
    try {
      final data = await _client.from('projects').select().eq('id', id).single();
      return ProjectModel.fromJson(data);
    } catch (e, st) {
      AppLogger.error('Project', 'getProjectById failed', e, st);
      rethrow;
    }
  }

  /// Fetch members of a project.
  Future<List<ProjectMemberModel>> getProjectMembers(String projectId) async {
    try {
      final data = await _client
          .from('project_members')
          .select('*, users(full_name, avatar_url)')
          .eq('project_id', projectId);
      return (data as List).map((row) => ProjectMemberModel.fromJson(row)).toList();
    } catch (e, st) {
      AppLogger.error('Project', 'getProjectMembers failed', e, st);
      rethrow;
    }
  }

  /// Create a new project and assign the creator as 'owner'.
  Future<ProjectModel> createProject(Map<String, dynamic> projectData) async {
    AppLogger.action('Project', 'createProject');
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

      AppLogger.info('Project', 'Project created successfully: ${project.id}');
      return project;
    } catch (e, st) {
      AppLogger.error('Project', 'createProject failed', e, st);
      rethrow;
    }
  }

  /// Join a project instantly as a 'member'.
  Future<void> joinProject(String projectId, String userId) async {
    AppLogger.action('Project', 'joinProject', data: {'projectId': projectId, 'userId': userId});
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

      AppLogger.info('Project', 'User $userId joined project $projectId');
    } catch (e, st) {
      AppLogger.error('Project', 'joinProject failed', e, st);
      rethrow;
    }
  }

  /// Leave a project.
  Future<void> leaveProject(String projectId, String userId) async {
    AppLogger.action('Project', 'leaveProject', data: {'projectId': projectId, 'userId': userId});
    try {
      await _client
          .from('project_members')
          .delete()
          .match({'project_id': projectId, 'user_id': userId});
      AppLogger.info('Project', 'User $userId left project $projectId');
    } catch (e, st) {
      AppLogger.error('Project', 'leaveProject failed', e, st);
      rethrow;
    }
  }

  /// Update project settings (Restricted to owner/admin).
  Future<void> updateProject(String projectId, Map<String, dynamic> updates) async {
    AppLogger.action('Project', 'updateProject', data: {'projectId': projectId});
    try {
      await _client.from('projects').update(updates).eq('id', projectId);
      AppLogger.info('Project', 'Project $projectId updated');
    } catch (e, st) {
      AppLogger.error('Project', 'updateProject failed', e, st);
      rethrow;
    }
  }

  /// Transfer ownership of a project.
  Future<void> transferOwnership(String projectId, String newOwnerId) async {
    AppLogger.action('Project', 'transferOwnership', data: {'projectId': projectId, 'newOwnerId': newOwnerId});
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

      AppLogger.info('Project', 'Ownership of $projectId transferred to $newOwnerId');
    } catch (e, st) {
      AppLogger.error('Project', 'transferOwnership failed', e, st);
      rethrow;
    }
  }

  /// Archive a project.
  Future<void> archiveProject(String projectId) async {
    AppLogger.action('Project', 'archiveProject', data: {'projectId': projectId});
    try {
      await _client.from('projects').update({
        'status': 'archived',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', projectId);
      AppLogger.info('Project', 'Project $projectId archived');
    } catch (e, st) {
      AppLogger.error('Project', 'archiveProject failed', e, st);
      rethrow;
    }
  }
}
