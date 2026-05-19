import 'package:flutter_test/flutter_test.dart';
import 'package:grow/shared/models/notification_model.dart';

void main() {
  group('NotificationModel Serialization Tests', () {
    test('fromJson parses complete json correctly', () {
      final json = {
        'id': 'notif-123',
        'user_id': 'user-001',
        'title': 'Booking Approved',
        'message': 'Your booking for 3D Printer has been approved.',
        'type': 'booking',
        'is_read': true,
        'created_at': '2026-06-01T08:00:00.000Z',
      };

      final notif = NotificationModel.fromJson(json);

      expect(notif.id, 'notif-123');
      expect(notif.userId, 'user-001');
      expect(notif.title, 'Booking Approved');
      expect(notif.message, 'Your booking for 3D Printer has been approved.');
      expect(notif.type, 'booking');
      expect(notif.isRead, isTrue);
      expect(notif.createdAt, DateTime.parse('2026-06-01T08:00:00.000Z'));
    });

    test('fromJson defaults isRead to false when missing', () {
      final json = {
        'id': 'notif-456',
        'user_id': 'user-001',
        'title': 'New Event',
        'message': 'A new event has been created.',
        'type': 'event',
        'created_at': '2026-06-01T08:00:00.000Z',
      };

      final notif = NotificationModel.fromJson(json);

      expect(notif.isRead, isFalse);
    });

    test('toJson serializes correctly', () {
      final notif = NotificationModel(
        id: 'notif-123',
        userId: 'user-001',
        title: 'Test',
        message: 'Test message',
        type: 'system',
        isRead: false,
        createdAt: DateTime.parse('2026-06-01T08:00:00.000Z'),
      );

      final json = notif.toJson();

      expect(json['user_id'], 'user-001');
      expect(json['title'], 'Test');
      expect(json['message'], 'Test message');
      expect(json['type'], 'system');
      expect(json['is_read'], false);
      // id and created_at are server-generated, not in toJson
      expect(json.containsKey('id'), isFalse);
    });

    test('copyWith preserves all fields except changed ones', () {
      final notif = NotificationModel(
        id: 'notif-123',
        userId: 'user-001',
        title: 'Test',
        message: 'Test message',
        type: 'system',
        isRead: false,
        createdAt: DateTime.parse('2026-06-01T08:00:00.000Z'),
      );

      final updated = notif.copyWith(isRead: true);

      expect(updated.id, 'notif-123');
      expect(updated.title, 'Test');
      expect(updated.isRead, isTrue);
    });
  });
}
