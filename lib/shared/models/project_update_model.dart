class ProjectUpdateModel {
  ProjectUpdateModel({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.userName,
    this.userAvatar,
  });

  final String id;
  final String projectId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final String? userName;
  final String? userAvatar;

  factory ProjectUpdateModel.fromJson(Map<String, dynamic> json) {
    return ProjectUpdateModel(
      id: json['id'],
      projectId: json['project_id'],
      userId: json['user_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      userName: json['users']?['full_name'],
      userAvatar: json['users']?['avatar_url'],
    );
  }
}
