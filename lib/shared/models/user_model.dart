/// Represents a Grow~ user profile (maps to public.users table).
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.collegeRoll,
    this.username,
    this.role = 'student',
    this.systemRole = 'user',
    this.skills = const [],
    this.interests = const [],
    this.profileCompleted = false,
    this.clubId,
    this.xp = 0,
    this.level = 1,
    this.reputationScore = 100,
    this.qrCodeData,
    this.fcmToken,
    this.isBlocked = false,
    this.createdAt,
    this.updatedAt,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? collegeRoll;
  final String? username;
  final String role;
  final String systemRole;
  final List<String> skills;
  final List<String> interests;
  final bool profileCompleted;
  final String? clubId;
  final int xp;
  final int level;
  final int reputationScore;
  final String? qrCodeData;
  final String? fcmToken;
  final bool isBlocked;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? avatarUrl;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      collegeRoll: json['college_roll'] as String?,
      username: json['username'] as String?,
      role: json['role'] as String? ?? 'student',
      systemRole: json['system_role'] as String? ?? 'user',
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      profileCompleted: json['profile_completed'] as bool? ?? false,
      clubId: json['club_id'] as String?,
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      reputationScore: json['reputation_score'] as int? ?? 100,
      qrCodeData: json['qr_code_data'] as String?,
      fcmToken: json['fcm_token'] as String?,
      isBlocked: json['is_blocked'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'college_roll': collegeRoll,
      'username': username,
      'role': role,
      'system_role': systemRole,
      'skills': skills,
      'interests': interests,
      'profile_completed': profileCompleted,
      'club_id': clubId,
      'xp': xp,
      'level': level,
      'reputation_score': reputationScore,
      'qr_code_data': qrCodeData,
      'fcm_token': fcmToken,
      'is_blocked': isBlocked,
      'avatar_url': avatarUrl,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? collegeRoll,
    String? username,
    String? role,
    String? systemRole,
    List<String>? skills,
    List<String>? interests,
    bool? profileCompleted,
    String? clubId,
    int? xp,
    int? level,
    int? reputationScore,
    String? qrCodeData,
    String? fcmToken,
    bool? isBlocked,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      collegeRoll: collegeRoll ?? this.collegeRoll,
      username: username ?? this.username,
      role: role ?? this.role,
      systemRole: systemRole ?? this.systemRole,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      clubId: clubId ?? this.clubId,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      reputationScore: reputationScore ?? this.reputationScore,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      fcmToken: fcmToken ?? this.fcmToken,
      isBlocked: isBlocked ?? this.isBlocked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
