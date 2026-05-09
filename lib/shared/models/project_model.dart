class ProjectModel {
  const ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.status = 'active',
    this.visibility = 'public',
    required this.createdBy,
    this.clubId,
    this.externalLink,
    this.coverImageUrl,
    this.showcaseUrl,
    this.memberLimit,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String? description;
  final String type;
  final String status;
  final String visibility;
  final String createdBy;
  final String? clubId;
  final String? externalLink;
  final String? coverImageUrl;
  final String? showcaseUrl;
  final int? memberLimit;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isActive => status == 'active';
  bool get isPublic => visibility == 'public';

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: json['project_type'] as String? ?? 'team',
      status: json['status'] as String? ?? 'active',
      visibility: json['visibility'] as String? ?? 'public',
      createdBy: json['created_by'] as String,
      clubId: json['club_id'] as String?,
      externalLink: json['external_link'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      showcaseUrl: json['showcase_url'] as String?,
      memberLimit: json['member_limit'] as int?,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String).toUtc()
          : null,
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
      'project_type': type,
      'status': status,
      'visibility': visibility,
      'created_by': createdBy,
      'club_id': clubId,
      'external_link': externalLink,
      'cover_image_url': coverImageUrl,
      'showcase_url': showcaseUrl,
      'member_limit': memberLimit,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  ProjectModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? status,
    String? visibility,
    String? createdBy,
    String? clubId,
    String? externalLink,
    String? coverImageUrl,
    String? showcaseUrl,
    int? memberLimit,
    DateTime? completedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      createdBy: createdBy ?? this.createdBy,
      clubId: clubId ?? this.clubId,
      externalLink: externalLink ?? this.externalLink,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      showcaseUrl: showcaseUrl ?? this.showcaseUrl,
      memberLimit: memberLimit ?? this.memberLimit,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
