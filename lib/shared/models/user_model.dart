import 'package:grow/core/utils/app_logger.dart';

/// Represents a Grow~ user profile (maps to public.users table).
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.collegeRoll,
    this.role = 'student',
    this.profileCompleted = false,
    this.clubId,
    this.clubTitle,
    this.xp = 0,
    this.level = 1,
    this.reputationScore = 100,
    this.qrCodeData,
    this.fcmToken,
    this.isActive = true,
    this.banReason,
    this.bannedAt,
    this.createdAt,
    this.updatedAt,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? collegeRoll;
  final String role;
  final bool profileCompleted;
  final String? clubId;
  final String? clubTitle;
  final int xp;
  final int level;
  final int reputationScore;
  final String? qrCodeData;
  final String? fcmToken;
  final bool isActive;
  final String? banReason;
  final DateTime? bannedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? avatarUrl;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final model = UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      collegeRoll: json['college_roll'] as String?,
      role: json['role'] as String? ?? 'student',
      profileCompleted: json['profile_completed'] as bool? ?? false,
      clubId: json['club_id'] as String?,
      clubTitle: json['club_title'] as String?,
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      reputationScore: json['reputation_score'] as int? ?? 100,
      qrCodeData: json['qr_code_data'] as String?,
      fcmToken: json['fcm_token'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      banReason: json['ban_reason'] as String?,
      bannedAt: json['banned_at'] != null
          ? DateTime.parse(json['banned_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      avatarUrl: json['avatar_url'] as String?,
    );
    AppLogger.info(LogCategory.auth,
        'USER_MODEL_PARSED | role=${model.role} | rawRole=${json["role"]}');
    return model;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'college_roll': collegeRoll,
      'role': role,
      'profile_completed': profileCompleted,
      'club_id': clubId,
      'club_title': clubTitle,
      'xp': xp,
      'level': level,
      'reputation_score': reputationScore,
      'qr_code_data': qrCodeData,
      'fcm_token': fcmToken,
      'is_active': isActive,
      'avatar_url': avatarUrl,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? collegeRoll,
    String? role,
    bool? profileCompleted,
    String? clubId,
    String? clubTitle,
    int? xp,
    int? level,
    int? reputationScore,
    String? qrCodeData,
    String? fcmToken,
    bool? isActive,
    String? banReason,
    DateTime? bannedAt,
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
      role: role ?? this.role,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      clubId: clubId ?? this.clubId,
      clubTitle: clubTitle ?? this.clubTitle,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      reputationScore: reputationScore ?? this.reputationScore,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      fcmToken: fcmToken ?? this.fcmToken,
      isActive: isActive ?? this.isActive,
      banReason: banReason ?? this.banReason,
      bannedAt: bannedAt ?? this.bannedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
