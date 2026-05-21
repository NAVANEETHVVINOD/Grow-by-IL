import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:grow/features/lab/data/tool_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder<T> extends Mock
    implements PostgrestFilterBuilder<T> {}

class MockPostgrestTransformBuilder<T> extends Mock
    implements PostgrestTransformBuilder<T> {}

void main() {
  group('BookingFlow Unit & Integration Tests', () {
    late MockSupabaseClient mockSupabase;
    late MockSupabaseQueryBuilder mockBookingsQueryBuilder;
    late MockSupabaseQueryBuilder mockToolsQueryBuilder;
    late MockSupabaseQueryBuilder mockNotifQueryBuilder;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockBookingsQueryBuilder = MockSupabaseQueryBuilder();
      mockToolsQueryBuilder = MockSupabaseQueryBuilder();
      mockNotifQueryBuilder = MockSupabaseQueryBuilder();

      registerFallbackValue(const Duration(seconds: 10));

      when(() => mockSupabase.from('tool_bookings'))
          .thenAnswer((_) => mockBookingsQueryBuilder);
      when(() => mockSupabase.from('tools'))
          .thenAnswer((_) => mockToolsQueryBuilder);
      when(() => mockSupabase.from('notifications'))
          .thenAnswer((_) => mockNotifQueryBuilder);
    });

    test('Successful booking creation', () async {
      final startTime = DateTime.now().add(const Duration(hours: 1));
      final endTime = startTime.add(const Duration(hours: 2));

      // Overlap check stubs
      final mockOverlapFilter =
          MockPostgrestFilterBuilder<List<Map<String, dynamic>>>();
      when(() => mockBookingsQueryBuilder.select())
          .thenAnswer((_) => mockOverlapFilter);
      when(() => mockOverlapFilter.eq('tool_id', 'tool-1'))
          .thenAnswer((_) => mockOverlapFilter);
      when(() => mockOverlapFilter.inFilter('status', ['approved', 'active']))
          .thenAnswer((_) => mockOverlapFilter);
      when(() => mockOverlapFilter.filter('slot_start', 'lt', any()))
          .thenAnswer((_) => mockOverlapFilter);
      when(() => mockOverlapFilter.filter('slot_end', 'gt', any()))
          .thenAnswer((_) => mockOverlapFilter);
      when(() => mockOverlapFilter.timeout(any()))
          .thenAnswer((_) async => <Map<String, dynamic>>[]); // No overlaps

      // getToolById stubs
      final mockToolFilter =
          MockPostgrestFilterBuilder<List<Map<String, dynamic>>>();
      final mockToolTransform =
          MockPostgrestTransformBuilder<Map<String, dynamic>>();
      when(() => mockToolsQueryBuilder.select())
          .thenAnswer((_) => mockToolFilter);
      when(() => mockToolFilter.eq('id', 'tool-1'))
          .thenAnswer((_) => mockToolFilter);
      when(() => mockToolFilter.single()).thenAnswer((_) => mockToolTransform);
      when(() => mockToolTransform.timeout(any())).thenAnswer((_) async => {
            'id': 'tool-1',
            'name': '3D Printer',
            'category': '3d_printer',
            'health_status': 'available',
          });

      // Insert booking stubs
      final mockInsertFilter =
          MockPostgrestFilterBuilder<List<Map<String, dynamic>>>();
      final mockInsertTransform =
          MockPostgrestTransformBuilder<Map<String, dynamic>>();
      when(() => mockBookingsQueryBuilder.insert(any()))
          .thenAnswer((_) => mockInsertFilter);
      when(() => mockInsertFilter.select()).thenAnswer((_) => mockInsertFilter);
      when(() => mockInsertFilter.single())
          .thenAnswer((_) => mockInsertTransform);
      when(() => mockInsertTransform.timeout(any())).thenAnswer((_) async => {
            'id': 'booking-123',
            'tool_id': 'tool-1',
            'user_id': 'user-1',
            'slot_start': startTime.toIso8601String(),
            'slot_end': endTime.toIso8601String(),
            'status': 'pending',
          });

      // Notification insert stubs
      final mockNotifFilter =
          MockPostgrestFilterBuilder<List<Map<String, dynamic>>>();
      when(() => mockNotifQueryBuilder.insert(any()))
          .thenAnswer((_) => mockNotifFilter);
      when(() => mockNotifFilter.timeout(any()))
          .thenAnswer((_) async => <Map<String, dynamic>>[]);

      final toolRepo = ToolRepository(mockSupabase);

      final booking = await toolRepo.createBooking(
        toolId: 'tool-1',
        userId: 'user-1',
        slotStart: startTime,
        slotEnd: endTime,
      );

      expect(booking.id, 'booking-123');
      expect(booking.status, 'pending');
    });

    test('Booking fails due to overlapping slot', () async {
      final startTime = DateTime.now().add(const Duration(hours: 1));
      final endTime = startTime.add(const Duration(hours: 2));

      // Overlap check stubs returning existing bookings
      final mockOverlapFilter =
          MockPostgrestFilterBuilder<List<Map<String, dynamic>>>();
      when(() => mockBookingsQueryBuilder.select())
          .thenAnswer((_) => mockOverlapFilter);
      when(() => mockOverlapFilter.eq('tool_id', 'tool-1'))
          .thenAnswer((_) => mockOverlapFilter);
      when(() => mockOverlapFilter.inFilter('status', ['approved', 'active']))
          .thenAnswer((_) => mockOverlapFilter);
      when(() => mockOverlapFilter.filter('slot_start', 'lt', any()))
          .thenAnswer((_) => mockOverlapFilter);
      when(() => mockOverlapFilter.filter('slot_end', 'gt', any()))
          .thenAnswer((_) => mockOverlapFilter);
      when(() => mockOverlapFilter.timeout(any()))
          .thenAnswer((_) async => <Map<String, dynamic>>[
                {
                  'id': 'existing-booking',
                  'tool_id': 'tool-1',
                  'slot_start': startTime.toIso8601String(),
                  'slot_end': endTime.toIso8601String(),
                  'status': 'approved',
                }
              ]);

      final toolRepo = ToolRepository(mockSupabase);

      expect(
        () => toolRepo.createBooking(
          toolId: 'tool-1',
          userId: 'user-1',
          slotStart: startTime,
          slotEnd: endTime,
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('overlaps with an existing booking'),
        )),
      );
    });
  });
}
