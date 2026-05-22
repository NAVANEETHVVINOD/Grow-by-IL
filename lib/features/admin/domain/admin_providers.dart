import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/repositories/supabase_client.dart';
import '../data/admin_repository.dart';
import '../../../shared/models/booking_model.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(supabase);
});

final pendingBookingsStreamProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return supabase
      .from('tool_bookings')
      .stream(primaryKey: ['id']).eq('status', 'pending');
});

/// Provider for pending bookings, derived directly from stream data.
final pendingBookingsProvider = Provider<AsyncValue<List<BookingModel>>>((ref) {
  final streamData = ref.watch(pendingBookingsStreamProvider);
  return streamData.whenData((data) {
    return data.map((row) => BookingModel.fromJson(row)).toList();
  });
});
