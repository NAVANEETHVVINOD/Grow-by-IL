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

final eventDetailProvider = FutureProvider.family<EventModel, String>((ref, id) async {
  final repo = ref.watch(eventRepositoryProvider);
  return repo.getEventById(id);
});

final userRsvpProvider = FutureProvider.family<RsvpModel?, String>((ref, eventId) async {
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
