import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/repositories/supabase_client.dart';
import '../../auth/data/auth_repository.dart';
import '../data/notification_repository.dart';
import '../../../shared/models/notification_model.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(supabase);
});

final notificationsProvider =
    FutureProvider.autoDispose<List<NotificationModel>>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return [];

  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getNotifications(user.id);
});

final unreadNotificationCountProvider = Provider.autoDispose<int>((ref) {
  final notifications = ref.watch(notificationsProvider).valueOrNull ?? [];
  return notifications.where((n) => !n.isRead).length;
});

final notificationStreamProvider = StreamProvider.autoDispose<List<NotificationModel>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return Stream.value([]);
  
  return ref.watch(notificationRepositoryProvider).subscribeToNotifications(user.id);
});
