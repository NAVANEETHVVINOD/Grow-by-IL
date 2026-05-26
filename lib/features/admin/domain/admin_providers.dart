import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/repositories/supabase_client.dart';
import '../data/admin_repository.dart';
import '../../../shared/models/booking_model.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(supabase);
});

final pendingBookingsStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  return supabase
      .from('tool_bookings')
      .stream(primaryKey: ['id']).eq('status', 'pending');
});

/// Provider for pending bookings.
///
/// Raw realtime rows do not include joined tool/user names required by the
/// admin queue, so realtime is used as a refresh signal for the joined query.
final pendingBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  ref.watch(pendingBookingsStreamProvider);
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getPendingBookings();
});
