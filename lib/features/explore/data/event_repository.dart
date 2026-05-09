import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:grow/core/utils/app_logger.dart';
import 'package:grow/shared/models/event_model.dart';
import 'package:grow/shared/models/rsvp_model.dart';

class EventRepository {
  EventRepository(this._client);
  final SupabaseClient _client;

  /// Fetch active events.
  Future<List<EventModel>> getEvents() async {
    AppLogger.action(LogCategory.events, 'getEvents');
    AppLogger.info(
      LogCategory.events,
      'QUERY_COLUMNS | id, title, description, event_type, start_time, end_time, status, location_name, created_by, created_at, capacity, rsvp_count',
    );

    try {
      final data = await _client
          .from('events')
          .select()
          .filter(
            'status',
            'in',
            '("active","upcoming")',
          ) // Handle both legacy and new statuses
          .order('start_time', ascending: true);
      return (data as List).map((row) => EventModel.fromJson(row)).toList();
    } catch (e, st) {
      AppLogger.error(
        LogCategory.events,
        'getEvents failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  /// Fetch single event by ID.
  Future<EventModel> getEventById(String id) async {
    try {
      final data = await _client.from('events').select().eq('id', id).single();
      return EventModel.fromJson(data);
    } catch (e, st) {
      AppLogger.error(
        LogCategory.events,
        'getEventById failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  /// RSVP to an event with a race condition guard.
  Future<RsvpModel> rsvpToEvent(String eventId, String userId) async {
    AppLogger.action(LogCategory.events, 'rsvpToEvent', {
      'eventId': eventId,
      'userId': userId,
    });
    try {
      // 1. Guard: Check if already going to prevent double counting
      final existing = await getUserRsvp(eventId, userId);
      if (existing?.status == 'going') {
        return existing!;
      }

      // 2. Race Condition Guard: Re-check capacity before insert
      final event = await getEventById(eventId);
      if (event.isFull) {
        throw Exception('Event is already full.');
      }

      // 3. Upsert RSVP (to handle re-joining after cancellation)
      final data = await _client
          .from('rsvps')
          .upsert({
            'event_id': eventId,
            'user_id': userId,
            'status': 'going',
            'qr_ticket_data': 'GROWLAB-RSVP-$eventId-$userId',
          }, onConflict: 'event_id, user_id')
          .select()
          .single();

      // 4. Increment RSVP count
      await _client.rpc('increment_rsvp_count', params: {'row_id': eventId});

      // 5. Create Notification (Only if not already notified)
      await _client.from('notifications').insert({
        'user_id': userId,
        'type': 'event_rsvp',
        'title': 'RSVP Confirmed!',
        'message': 'You are going to "${event.title}". See you there!',
        'related_id': eventId,
      });

      AppLogger.info(LogCategory.events, 'RSVP successful for event $eventId');
      return RsvpModel.fromJson(data);
    } catch (e, st) {
      AppLogger.error(
        LogCategory.events,
        'rsvpToEvent failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  /// Cancel an RSVP.
  Future<void> cancelRsvp(String eventId, String userId) async {
    AppLogger.action(LogCategory.events, 'cancelRsvp', {
      'eventId': eventId,
      'userId': userId,
    });
    try {
      // 1. Guard: Only cancel if currently going
      final existing = await getUserRsvp(eventId, userId);
      if (existing?.status != 'going') return;

      await _client.from('rsvps').update({'status': 'cancelled'}).match({
        'event_id': eventId,
        'user_id': userId,
      });

      // 2. Decrement RSVP count
      await _client.rpc('decrement_rsvp_count', params: {'row_id': eventId});

      // 3. Create Notification
      await _client.from('notifications').insert({
        'user_id': userId,
        'type': 'event_cancel',
        'title': 'RSVP Cancelled',
        'message': 'Your RSVP for this event has been cancelled.',
        'related_id': eventId,
      });

      AppLogger.info(LogCategory.events, 'RSVP cancelled for event $eventId');
    } catch (e, st) {
      AppLogger.error(
        LogCategory.events,
        'cancelRsvp failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  /// Fetch a single RSVP for a specific event and user.
  Future<RsvpModel?> getUserRsvp(String eventId, String userId) async {
    try {
      final data = await _client
          .from('rsvps')
          .select()
          .eq('event_id', eventId)
          .eq('user_id', userId)
          .maybeSingle();
      if (data == null) return null;
      return RsvpModel.fromJson(data);
    } catch (e, st) {
      AppLogger.error(
        LogCategory.events,
        'getUserRsvp failed',
        error: e,
        stack: st,
      );
      return null;
    }
  }

  /// Fetch all RSVPs for a user.
  Future<List<RsvpModel>> getUserRsvps(String userId) async {
    try {
      final data = await _client
          .from('rsvps')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return (data as List).map((row) => RsvpModel.fromJson(row)).toList();
    } catch (e, st) {
      AppLogger.error(
        LogCategory.events,
        'getUserRsvps failed',
        error: e,
        stack: st,
      );
      return [];
    }
  }
}
