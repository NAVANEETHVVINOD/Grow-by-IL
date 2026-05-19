import 'package:flutter_test/flutter_test.dart';
import 'package:grow/shared/models/booking_model.dart';

void main() {
  group('BookingModel Serialization Tests', () {
    test('fromJson parses complete json correctly', () {
      final json = {
        'id': 'booking-123',
        'tool_id': 'tool-456',
        'user_id': 'user-789',
        'project_id': 'proj-001',
        'slot_start': '2026-06-01T09:00:00.000Z',
        'slot_end': '2026-06-01T11:00:00.000Z',
        'status': 'approved',
        'approved_by': 'admin-001',
        'approved_at': '2026-05-30T14:00:00.000Z',
        'checkout_at': '2026-06-01T09:05:00.000Z',
        'returned_at': null,
        'return_reminder_sent': true,
        'notes': 'PCB milling',
        'created_at': '2026-05-28T08:00:00.000Z',
        'tools': {'name': 'CNC Router'},
        'users': {'name': 'Kannan'},
      };

      final booking = BookingModel.fromJson(json);

      expect(booking.id, 'booking-123');
      expect(booking.toolId, 'tool-456');
      expect(booking.userId, 'user-789');
      expect(booking.projectId, 'proj-001');
      expect(booking.slotStart, DateTime.utc(2026, 6, 1, 9, 0));
      expect(booking.slotEnd, DateTime.utc(2026, 6, 1, 11, 0));
      expect(booking.status, 'approved');
      expect(booking.approvedBy, 'admin-001');
      expect(booking.returnReminderSent, isTrue);
      expect(booking.notes, 'PCB milling');
      expect(booking.toolName, 'CNC Router');
      expect(booking.userName, 'Kannan');
    });

    test('fromJson parses minimal json using defaults', () {
      final json = {
        'id': 'booking-123',
        'tool_id': 'tool-456',
        'user_id': 'user-789',
        'slot_start': '2026-06-01T09:00:00.000Z',
        'slot_end': '2026-06-01T11:00:00.000Z',
      };

      final booking = BookingModel.fromJson(json);

      expect(booking.status, 'pending');
      expect(booking.returnReminderSent, isFalse);
      expect(booking.approvedBy, isNull);
      expect(booking.approvedAt, isNull);
      expect(booking.notes, isNull);
      expect(booking.toolName, isNull);
      expect(booking.userName, isNull);
    });

    test('toJson serializes correctly', () {
      final booking = BookingModel(
        id: 'booking-123',
        toolId: 'tool-456',
        userId: 'user-789',
        slotStart: DateTime.utc(2026, 6, 1, 9, 0),
        slotEnd: DateTime.utc(2026, 6, 1, 11, 0),
        status: 'approved',
      );

      final json = booking.toJson();

      expect(json['id'], 'booking-123');
      expect(json['tool_id'], 'tool-456');
      expect(json['user_id'], 'user-789');
      expect(json['slot_start'], '2026-06-01T09:00:00.000Z');
      expect(json['slot_end'], '2026-06-01T11:00:00.000Z');
      expect(json['status'], 'approved');
    });

    test('isOverdue returns true for expired active bookings', () {
      final overdueBooking = BookingModel(
        id: 'booking-123',
        toolId: 'tool-456',
        userId: 'user-789',
        slotStart: DateTime.utc(2020, 1, 1),
        slotEnd: DateTime.utc(2020, 1, 2),
        status: 'active',
      );

      expect(overdueBooking.isOverdue, isTrue);
    });

    test('isOverdue returns false for non-active bookings', () {
      final pendingBooking = BookingModel(
        id: 'booking-123',
        toolId: 'tool-456',
        userId: 'user-789',
        slotStart: DateTime.utc(2020, 1, 1),
        slotEnd: DateTime.utc(2020, 1, 2),
        status: 'pending',
      );

      expect(pendingBooking.isOverdue, isFalse);
    });

    test('copyWith copies fields correctly', () {
      final booking = BookingModel(
        id: 'booking-123',
        toolId: 'tool-456',
        userId: 'user-789',
        slotStart: DateTime.utc(2026, 6, 1, 9, 0),
        slotEnd: DateTime.utc(2026, 6, 1, 11, 0),
      );

      final updated = booking.copyWith(status: 'approved');

      expect(updated.id, 'booking-123');
      expect(updated.status, 'approved');
      expect(updated.toolId, 'tool-456');
    });
  });
}
