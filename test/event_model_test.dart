import 'package:flutter_test/flutter_test.dart';
import 'package:grow/shared/models/event_model.dart';

void main() {
  group('EventModel Serialization Tests', () {
    test('fromJson parses complete json correctly', () {
      final json = {
        'id': 'event-123',
        'title': 'PCB Workshop',
        'description': 'Learn PCB design',
        'event_type': 'workshop',
        'club_id': 'club-001',
        'event_date': '2026-06-15T10:00:00.000Z',
        'end_date': '2026-06-15T16:00:00.000Z',
        'venue': 'IdeaLab Main Hall',
        'capacity': 30,
        'rsvp_count': 15,
        'image_url': 'https://example.com/image.jpg',
        'created_by': 'user-001',
        'status': 'upcoming',
        'created_at': '2026-06-01T08:00:00.000Z',
      };

      final event = EventModel.fromJson(json);

      expect(event.id, 'event-123');
      expect(event.title, 'PCB Workshop');
      expect(event.description, 'Learn PCB design');
      expect(event.type, 'workshop');
      expect(event.clubId, 'club-001');
      expect(event.eventDate, DateTime.utc(2026, 6, 15, 10, 0));
      expect(event.endDate, DateTime.utc(2026, 6, 15, 16, 0));
      expect(event.venue, 'IdeaLab Main Hall');
      expect(event.capacity, 30);
      expect(event.rsvpCount, 15);
      expect(event.imageUrl, 'https://example.com/image.jpg');
      expect(event.createdBy, 'user-001');
      expect(event.status, 'upcoming');
    });

    test('fromJson uses defaults for missing fields', () {
      final json = {
        'id': 'event-123',
        'title': 'Test Event',
        'event_date': '2026-06-15T10:00:00.000Z',
        'created_by': 'user-001',
      };

      final event = EventModel.fromJson(json);

      expect(event.type, 'workshop');
      expect(event.rsvpCount, 0);
      expect(event.status, 'upcoming');
      expect(event.description, isNull);
      expect(event.venue, isNull);
      expect(event.capacity, isNull);
    });

    test('toJson serializes correctly', () {
      final event = EventModel(
        id: 'event-123',
        title: 'PCB Workshop',
        description: 'Learn PCB design',
        type: 'workshop',
        eventDate: DateTime.utc(2026, 6, 15, 10, 0),
        createdBy: 'user-001',
      );

      final json = event.toJson();

      expect(json['id'], 'event-123');
      expect(json['title'], 'PCB Workshop');
      expect(json['event_type'], 'workshop');
      expect(json['event_date'], '2026-06-15T10:00:00.000Z');
      expect(json['created_by'], 'user-001');
    });

    test('isFull returns true when capacity reached', () {
      final event = EventModel(
        id: 'event-123',
        title: 'Full Event',
        type: 'workshop',
        eventDate: DateTime.utc(2026, 6, 15),
        createdBy: 'user-001',
        capacity: 10,
        rsvpCount: 10,
      );

      expect(event.isFull, isTrue);
    });

    test('isFull returns false when no capacity limit', () {
      final event = EventModel(
        id: 'event-123',
        title: 'Open Event',
        type: 'workshop',
        eventDate: DateTime.utc(2026, 6, 15),
        createdBy: 'user-001',
        rsvpCount: 100,
      );

      expect(event.isFull, isFalse);
    });

    test('isCancelled returns true for cancelled events', () {
      final event = EventModel(
        id: 'event-123',
        title: 'Cancelled Event',
        type: 'workshop',
        eventDate: DateTime.utc(2026, 6, 15),
        createdBy: 'user-001',
        status: 'cancelled',
      );

      expect(event.isCancelled, isTrue);
    });

    test('copyWith copies fields correctly', () {
      final event = EventModel(
        id: 'event-123',
        title: 'Original',
        type: 'workshop',
        eventDate: DateTime.utc(2026, 6, 15),
        createdBy: 'user-001',
      );

      final updated = event.copyWith(title: 'Updated', rsvpCount: 5);

      expect(updated.id, 'event-123');
      expect(updated.title, 'Updated');
      expect(updated.rsvpCount, 5);
    });
  });
}
