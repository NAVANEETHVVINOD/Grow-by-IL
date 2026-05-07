import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/event_model.dart';
import '../../../shared/models/rsvp_model.dart';
import '../../../shared/repositories/supabase_client.dart';
import '../../auth/data/auth_repository.dart';
import '../data/event_repository.dart';

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
