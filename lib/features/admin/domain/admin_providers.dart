import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/repositories/supabase_client.dart';
import '../data/admin_repository.dart';
import '../../../shared/models/booking_model.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(supabase);
});

final pendingBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  return repo.getPendingBookings();
});
