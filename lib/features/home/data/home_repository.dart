import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/app_logger.dart';
import '../../../shared/models/booking_model.dart';
import '../../../shared/models/event_model.dart';
import '../../../shared/models/project_model.dart';
import '../../../shared/repositories/supabase_client.dart';
import '../../auth/data/auth_repository.dart';

/// Repository for Home screen data fetching
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(supabase);
});

/// Providers in this file are legacy and being moved to feature-specific domains.
/// For Projects, use [userProjectsProvider] from project_providers.dart.
/// For Events, use [activeEventsProvider] from event_providers.dart.

/// Future provider for user's recent tool bookings
final recentBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final userId = userAsync.valueOrNull?.id;
  if (userId == null) return [];

  final repo = ref.watch(homeRepositoryProvider);
  return repo.getUserBookings(userId);
});

class HomeRepository {
  HomeRepository(this._client);
  final SupabaseClient _client;

  Future<List<EventModel>> getUpcomingEvents() async {
    AppLogger.action('Home', 'getUpcomingEvents');
    try {
      final response = await _client
          .from('events')
          .select()
          .eq('status', 'upcoming')
          .order('event_date', ascending: true)
          .limit(5);

      AppLogger.info('Home', 'Fetched ${(response as List).length} events');
      return response.map((data) => EventModel.fromJson(data)).toList();
    } catch (e, st) {
      AppLogger.error('Home', 'getUpcomingEvents failed', e, st);
      rethrow;
    }
  }

  Future<List<ProjectModel>> getUserProjects(String userId) async {
    AppLogger.action('Home', 'getUserProjects', data: {'userId': userId});
    try {
      final response = await _client
          .from('project_members')
          .select('projects(*)')
          .eq('user_id', userId)
          .limit(5);

      return (response as List).map((data) {
        final projectData = data['projects'] as Map<String, dynamic>;
        return ProjectModel.fromJson(projectData);
      }).toList();
    } catch (e, st) {
      AppLogger.error('Home', 'getUserProjects failed', e, st);
      rethrow;
    }
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    AppLogger.action('Home', 'getUserBookings', data: {'userId': userId});
    try {
      final response = await _client
          .from('tool_bookings')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(3);

      return (response as List)
          .map((data) => BookingModel.fromJson(data))
          .toList();
    } catch (e, st) {
      AppLogger.error('Home', 'getUserBookings failed', e, st);
      rethrow;
    }
  }
}
