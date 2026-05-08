class ProjectMemberModel {
  const ProjectMemberModel({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.role,
    this.joinedAt,
    this.userName, // Optional join for UI
    this.userAvatar, // Optional join for UI
  });

  final String id;
  final String projectId;
  final String userId;
  final String role;
  final DateTime? joinedAt;
  final String? userName;
  final String? userAvatar;

  bool get canManage => role == 'owner' || role == 'admin';

  factory ProjectMemberModel.fromJson(Map<String, dynamic> json) {
    return ProjectMemberModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String? ?? 'member',
      joinedAt: json['joined_at'] != null 
          ? DateTime.parse(json['joined_at'] as String).toUtc() 
          : null,
      userName: json['users']?['name'] as String?,
      userAvatar: json['users']?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'user_id': userId,
      'role': role,
    };
  }
}
