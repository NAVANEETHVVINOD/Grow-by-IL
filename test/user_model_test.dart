import 'package:flutter_test/flutter_test.dart';
import 'package:grow/shared/models/user_model.dart';

void main() {
  group('UserModel Serialization Tests', () {
    test('fromJson parses complete json correctly', () {
      final json = {
        'id': 'user-123',
        'name': 'Kannan',
        'email': 'kannan@gmail.com',
        'phone': '1234567890',
        'college_roll': '2021CSE001',
        'role': 'lab_admin',
        'profile_completed': true,
        'club_id': 'club-456',
        'club_title': 'Robotics Club',
        'xp': 150,
        'level': 2,
        'reputation_score': 95,
        'qr_code_data': 'qr-data',
        'fcm_token': 'fcm-123',
        'is_active': true,
        'ban_reason': 'violating rules',
        'banned_at': '2026-05-17T12:00:00.000Z',
        'created_at': '2026-05-01T08:00:00.000Z',
        'updated_at': '2026-05-17T10:00:00.000Z',
        'avatar_url': 'https://avatar.url',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'user-123');
      expect(user.name, 'Kannan');
      expect(user.email, 'kannan@gmail.com');
      expect(user.phone, '1234567890');
      expect(user.collegeRoll, '2021CSE001');
      expect(user.role, 'lab_admin');
      expect(user.profileCompleted, true);
      expect(user.clubId, 'club-456');
      expect(user.clubTitle, 'Robotics Club');
      expect(user.xp, 150);
      expect(user.level, 2);
      expect(user.reputationScore, 95);
      expect(user.qrCodeData, 'qr-data');
      expect(user.fcmToken, 'fcm-123');
      expect(user.isActive, true);
      expect(user.banReason, 'violating rules');
      expect(user.bannedAt, DateTime.parse('2026-05-17T12:00:00.000Z'));
      expect(user.createdAt, DateTime.parse('2026-05-01T08:00:00.000Z'));
      expect(user.updatedAt, DateTime.parse('2026-05-17T10:00:00.000Z'));
      expect(user.avatarUrl, 'https://avatar.url');
    });

    test('fromJson parses minimal json using defaults', () {
      final json = {
        'id': 'user-123',
        'name': 'Kannan',
        'email': 'kannan@gmail.com',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'user-123');
      expect(user.name, 'Kannan');
      expect(user.email, 'kannan@gmail.com');
      expect(user.phone, isNull);
      expect(user.collegeRoll, isNull);
      expect(user.role, 'student');
      expect(user.profileCompleted, false);
      expect(user.clubId, isNull);
      expect(user.clubTitle, isNull);
      expect(user.xp, 0);
      expect(user.level, 1);
      expect(user.reputationScore, 100);
      expect(user.qrCodeData, isNull);
      expect(user.fcmToken, isNull);
      expect(user.isActive, true);
      expect(user.banReason, isNull);
      expect(user.bannedAt, isNull);
      expect(user.createdAt, isNull);
      expect(user.updatedAt, isNull);
      expect(user.avatarUrl, isNull);
    });

    test('toJson serializes correctly', () {
      final user = UserModel(
        id: 'user-123',
        name: 'Kannan',
        email: 'kannan@gmail.com',
        phone: '1234567890',
        collegeRoll: '2021CSE001',
        role: 'lab_admin',
        profileCompleted: true,
        clubId: 'club-456',
        clubTitle: 'Robotics Club',
        xp: 150,
        level: 2,
        reputationScore: 95,
        qrCodeData: 'qr-data',
        fcmToken: 'fcm-123',
        isActive: true,
        avatarUrl: 'https://avatar.url',
      );

      final json = user.toJson();

      expect(json['id'], 'user-123');
      expect(json['name'], 'Kannan');
      expect(json['email'], 'kannan@gmail.com');
      expect(json['phone'], '1234567890');
      expect(json['college_roll'], '2021CSE001');
      expect(json['role'], 'lab_admin');
      expect(json['profile_completed'], true);
      expect(json['club_id'], 'club-456');
      expect(json['club_title'], 'Robotics Club');
      expect(json['xp'], 150);
      expect(json['level'], 2);
      expect(json['reputation_score'], 95);
      expect(json['qr_code_data'], 'qr-data');
      expect(json['fcm_token'], 'fcm-123');
      expect(json['is_active'], true);
      expect(json['avatar_url'], 'https://avatar.url');
    });

    test('copyWith copies fields correctly', () {
      final user = UserModel(
        id: 'user-123',
        name: 'Kannan',
        email: 'kannan@gmail.com',
      );

      final updated = user.copyWith(
        name: 'New Name',
        role: 'lab_admin',
      );

      expect(updated.id, 'user-123');
      expect(updated.name, 'New Name');
      expect(updated.email, 'kannan@gmail.com');
      expect(updated.role, 'lab_admin');
    });
  });
}
