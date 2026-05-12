/// Matches EXACT production schema:
/// id, title, description, club_id, status, created_by,
/// visibility, showcase_url, created_at, updated_at
class ProjectModel {
  const ProjectModel({
    required this.id,
    required this.title,
    this.description,
    this.status = 'active',
    this.visibility = 'public',
    required this.createdBy,
    this.clubId,
    this.showcaseUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String? description;
  final String status;
  final String visibility;
  final String createdBy;
  final String? clubId;
  final String? showcaseUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isActive => status == 'active';
  bool get isPublic => visibility == 'public';

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'active',
      visibility: json['visibility'] as String? ?? 'public',
      createdBy: json['created_by'] as String,
      clubId: json['club_id'] as String?,
      showcaseUrl: json['showcase_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toUtc()
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String).toUtc()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'visibility': visibility,
      'created_by': createdBy,
      'club_id': clubId,
      'showcase_url': showcaseUrl,
    };
  }

  ProjectModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? visibility,
    String? createdBy,
    String? clubId,
    String? showcaseUrl,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      createdBy: createdBy ?? this.createdBy,
      clubId: clubId ?? this.clubId,
      showcaseUrl: showcaseUrl ?? this.showcaseUrl,
    );
  }
}
