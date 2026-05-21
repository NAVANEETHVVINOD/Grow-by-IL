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

final pendingBookingsProvider =
    FutureProvider.autoDispose<List<BookingModel>>((ref) async {
  // Watch the raw stream to trigger a re-fetch whenever the table changes
  ref.watch(pendingBookingsStreamProvider);

  final repo = ref.watch(adminRepositoryProvider);
  return repo.getPendingBookings();
});
