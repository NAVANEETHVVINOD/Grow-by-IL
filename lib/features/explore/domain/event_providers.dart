import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grow/shared/models/event_model.dart';
import 'package:grow/shared/models/rsvp_model.dart';
import 'package:grow/shared/repositories/supabase_client.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/explore/data/event_repository.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(supabase);
});

final activeEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getEvents();
});

final eventDetailProvider = FutureProvider.family<EventModel, String>((
  ref,
  id,
) async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getEventById(id);
});

final userRsvpProvider = FutureProvider.family<RsvpModel?, String>((
  ref,
  eventId,
) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return null;

  final repo = ref.watch(eventRepositoryProvider);
  return repo.getUserRsvp(eventId, user.id);
});

final myRsvpsProvider = FutureProvider<List<RsvpModel>>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return [];
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getUserRsvps(user.id);
});

/// Fetches RSVPs with embedded event data in a single query (no N+1).
final myRsvpsWithEventsProvider =
    FutureProvider<List<({RsvpModel rsvp, EventModel event})>>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return [];

  final data = await supabase
      .from('rsvps')
      .select('*, event:events(*)')
      .eq('user_id', user.id)
      .order('created_at', ascending: false);

  return (data as List).map((row) {
    final rsvp = RsvpModel.fromJson(row);
    final event = EventModel.fromJson(row['event'] as Map<String, dynamic>);
    return (rsvp: rsvp, event: event);
  }).toList();
});
