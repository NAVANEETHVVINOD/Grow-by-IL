import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:grow/shared/models/booking_model.dart';
import 'package:grow/shared/models/tool_model.dart';
import 'package:grow/shared/repositories/supabase_client.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/lab/data/tool_repository.dart';

/// Provider for the ToolRepository
final toolRepositoryProvider = Provider<ToolRepository>((ref) {
  return ToolRepository(supabase);
});

/// State provider for the current category filter
final toolCategoryFilterProvider = StateProvider<String>((ref) => 'All');

/// State provider for the current search query
final toolSearchQueryProvider = StateProvider<String>((ref) => '');

/// Future provider for the list of tools, filtered by category and search
final toolsProvider = FutureProvider<List<ToolModel>>((ref) async {
  final category = ref.watch(toolCategoryFilterProvider);
  final searchQuery = ref.watch(toolSearchQueryProvider);
  final repo = ref.watch(toolRepositoryProvider);
  return repo.getTools(category: category, searchQuery: searchQuery);
});

/// Future provider for the current user's bookings
final myBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final userId = userAsync.valueOrNull?.id;
  if (userId == null) return [];

  final repo = ref.watch(toolRepositoryProvider);
  return repo.getMyBookings(userId);
});

/// The current user's active or upcoming booking
final activeBookingProvider = Provider<AsyncValue<BookingModel?>>((ref) {
  final bookingsAsync = ref.watch(myBookingsProvider);
  return bookingsAsync.whenData((bookings) {
    if (bookings.isEmpty) return null;
    final now = DateTime.now().toUtc();
    try {
      return bookings.firstWhere(
        (b) =>
            (b.status == 'active') ||
            (b.status == 'approved' &&
                b.slotStart.isBefore(now.add(const Duration(hours: 1))) &&
                b.slotEnd.isAfter(now)),
      );
    } catch (_) {
      return null;
    }
  });
});

/// Future provider for tool bookings on a specific day
final toolBookingsForDayProvider =
    FutureProvider.family<
      List<BookingModel>,
      ({String toolId, DateTime date})
    >((ref, arg) async {
      final supabase = ref.watch(
        toolRepositoryProvider,
      ); // Actually it's better to just use the client or repo
      // We can query bookings where slot_start is between date.startOfDay and date.endOfDay
      final start = DateTime(
        arg.date.year,
        arg.date.month,
        arg.date.day,
      ).toUtc();
      final end = start.add(const Duration(days: 1));

      final data = await supabase.client
          .from('tool_bookings')
          .select()
          .eq('tool_id', arg.toolId)
          .inFilter('status', ['approved', 'active'])
          .filter('slot_start', 'lt', end.toIso8601String())
          .filter('slot_end', 'gt', start.toIso8601String());

      return (data as List).map((row) => BookingModel.fromJson(row)).toList();
    });

/// Extension on ToolRepository to expose the client if needed (or just use repo methods)
extension ToolRepoExt on ToolRepository {
  SupabaseClient get client => supabase;
}

/// State provider for the currently selected tool in the catalog
final selectedToolProvider = StateProvider<ToolModel?>((ref) => null);
