// Models for the profile ecosystem tables.
//
// These map directly to the Supabase tables created in
// 003_profile_ecosystem.sql.

class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.userId,
    this.username,
    this.bio = '',
    this.userType = 'student',
    this.department = '',
    this.avatarUrl,
    this.isPublic = true,
    this.showEmail = false,
    this.showPhone = false,
    this.showStats = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String? username;
  final String bio;
  final String userType;
  final String department;
  final String? avatarUrl;
  final bool isPublic;
  final bool showEmail;
  final bool showPhone;
  final bool showStats;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      username: json['username'] as String?,
      bio: json['bio'] as String? ?? '',
      userType: json['user_type'] as String? ?? 'student',
      department: json['department'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      isPublic: json['is_public'] as bool? ?? true,
      showEmail: json['show_email'] as bool? ?? false,
      showPhone: json['show_phone'] as bool? ?? false,
      showStats: json['show_stats'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'username': username,
        'bio': bio,
        'user_type': userType,
        'department': department,
        'avatar_url': avatarUrl,
        'is_public': isPublic,
        'show_email': showEmail,
        'show_phone': showPhone,
        'show_stats': showStats,
      };

  UserProfileModel copyWith({
    String? username,
    String? bio,
    String? userType,
    String? department,
    String? avatarUrl,
    bool? isPublic,
    bool? showEmail,
    bool? showPhone,
    bool? showStats,
  }) {
    return UserProfileModel(
      id: id,
      userId: userId,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      userType: userType ?? this.userType,
      department: department ?? this.department,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPublic: isPublic ?? this.isPublic,
      showEmail: showEmail ?? this.showEmail,
      showPhone: showPhone ?? this.showPhone,
      showStats: showStats ?? this.showStats,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class UserExperienceModel {
  const UserExperienceModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.organization,
    this.description = '',
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.sortOrder = 0,
  });

  final String id;
  final String userId;
  final String title;
  final String organization;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final int sortOrder;

  factory UserExperienceModel.fromJson(Map<String, dynamic> json) {
    return UserExperienceModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      organization: json['organization'] as String,
      description: json['description'] as String? ?? '',
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      isCurrent: json['is_current'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'organization': organization,
        'description': description,
        'start_date': startDate?.toIso8601String().split('T').first,
        'end_date': endDate?.toIso8601String().split('T').first,
        'is_current': isCurrent,
        'sort_order': sortOrder,
      };

  UserExperienceModel copyWith({
    String? title,
    String? organization,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
    int? sortOrder,
  }) {
    return UserExperienceModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      organization: organization ?? this.organization,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrent: isCurrent ?? this.isCurrent,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class UserEducationModel {
  const UserEducationModel({
    required this.id,
    required this.userId,
    required this.institution,
    required this.degree,
    this.fieldOfStudy = '',
    this.startYear,
    this.endYear,
    this.isCurrent = false,
    this.sortOrder = 0,
  });

  final String id;
  final String userId;
  final String institution;
  final String degree;
  final String fieldOfStudy;
  final int? startYear;
  final int? endYear;
  final bool isCurrent;
  final int sortOrder;

  factory UserEducationModel.fromJson(Map<String, dynamic> json) {
    return UserEducationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      institution: json['institution'] as String,
      degree: json['degree'] as String,
      fieldOfStudy: json['field_of_study'] as String? ?? '',
      startYear: json['start_year'] as int?,
      endYear: json['end_year'] as int?,
      isCurrent: json['is_current'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'institution': institution,
        'degree': degree,
        'field_of_study': fieldOfStudy,
        'start_year': startYear,
        'end_year': endYear,
        'is_current': isCurrent,
        'sort_order': sortOrder,
      };

  UserEducationModel copyWith({
    String? institution,
    String? degree,
    String? fieldOfStudy,
    int? startYear,
    int? endYear,
    bool? isCurrent,
    int? sortOrder,
  }) {
    return UserEducationModel(
      id: id,
      userId: userId,
      institution: institution ?? this.institution,
      degree: degree ?? this.degree,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      isCurrent: isCurrent ?? this.isCurrent,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class UserPortfolioProjectModel {
  const UserPortfolioProjectModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    this.projectUrl,
    this.sourceUrl,
    this.bannerUrl,
    this.technologies = const [],
    this.isFeatured = false,
    this.sortOrder = 0,
  });

  final String id;
  final String userId;
  final String title;
  final String description;
  final String? projectUrl;
  final String? sourceUrl;
  final String? bannerUrl;
  final List<String> technologies;
  final bool isFeatured;
  final int sortOrder;

  factory UserPortfolioProjectModel.fromJson(Map<String, dynamic> json) {
    return UserPortfolioProjectModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      projectUrl: json['project_url'] as String?,
      sourceUrl: json['source_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      technologies:
          (json['technologies'] as List<dynamic>?)?.cast<String>() ?? const [],
      isFeatured: json['is_featured'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'description': description,
        'project_url': projectUrl,
        'source_url': sourceUrl,
        'banner_url': bannerUrl,
        'technologies': technologies,
        'is_featured': isFeatured,
        'sort_order': sortOrder,
      };

  UserPortfolioProjectModel copyWith({
    String? title,
    String? description,
    String? projectUrl,
    String? sourceUrl,
    String? bannerUrl,
    List<String>? technologies,
    bool? isFeatured,
    int? sortOrder,
  }) {
    return UserPortfolioProjectModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      projectUrl: projectUrl ?? this.projectUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      technologies: technologies ?? this.technologies,
      isFeatured: isFeatured ?? this.isFeatured,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class UserVolunteeringModel {
  const UserVolunteeringModel({
    required this.id,
    required this.userId,
    required this.role,
    required this.organization,
    this.description = '',
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.sortOrder = 0,
  });

  final String id;
  final String userId;
  final String role;
  final String organization;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final int sortOrder;

  factory UserVolunteeringModel.fromJson(Map<String, dynamic> json) {
    return UserVolunteeringModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String,
      organization: json['organization'] as String,
      description: json['description'] as String? ?? '',
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      isCurrent: json['is_current'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'role': role,
        'organization': organization,
        'description': description,
        'start_date': startDate?.toIso8601String().split('T').first,
        'end_date': endDate?.toIso8601String().split('T').first,
        'is_current': isCurrent,
        'sort_order': sortOrder,
      };

  UserVolunteeringModel copyWith({
    String? role,
    String? organization,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
    int? sortOrder,
  }) {
    return UserVolunteeringModel(
      id: id,
      userId: userId,
      role: role ?? this.role,
      organization: organization ?? this.organization,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrent: isCurrent ?? this.isCurrent,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class UserSocialLinkModel {
  const UserSocialLinkModel({
    required this.id,
    required this.userId,
    required this.platform,
    required this.url,
    this.label,
    this.sortOrder = 0,
  });

  final String id;
  final String userId;
  final String platform;
  final String url;
  final String? label;
  final int sortOrder;

  factory UserSocialLinkModel.fromJson(Map<String, dynamic> json) {
    return UserSocialLinkModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      platform: json['platform'] as String,
      url: json['url'] as String,
      label: json['label'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'platform': platform,
        'url': url,
        'label': label,
        'sort_order': sortOrder,
      };

  UserSocialLinkModel copyWith({
    String? platform,
    String? url,
    String? label,
    int? sortOrder,
  }) {
    return UserSocialLinkModel(
      id: id,
      userId: userId,
      platform: platform ?? this.platform,
      url: url ?? this.url,
      label: label ?? this.label,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class UserSkillModel {
  const UserSkillModel({
    required this.id,
    required this.userId,
    required this.name,
    this.level = 1,
    this.sortOrder = 0,
  });

  final String id;
  final String userId;
  final String name;
  final int level;
  final int sortOrder;

  factory UserSkillModel.fromJson(Map<String, dynamic> json) {
    return UserSkillModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      level: json['level'] as int? ?? 1,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'level': level,
        'sort_order': sortOrder,
      };

  UserSkillModel copyWith({
    String? name,
    int? level,
    int? sortOrder,
  }) {
    return UserSkillModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      level: level ?? this.level,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
