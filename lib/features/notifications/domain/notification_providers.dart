import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/repositories/supabase_client.dart';
import '../../auth/data/auth_repository.dart';
import '../data/notification_repository.dart';
import '../../../shared/models/notification_model.dart';
import '../../../core/utils/app_logger.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(supabase);
});

final notificationsProvider = StateNotifierProvider.autoDispose<
    NotificationListNotifier, AsyncValue<List<NotificationModel>>>((ref) {
  final user = ref.watch(currentUserProvider).valueOrNull;
  final repo = ref.watch(notificationRepositoryProvider);
  return NotificationListNotifier(repo, user?.id);
});

final unreadNotificationCountProvider = Provider.autoDispose<int>((ref) {
  final notifications = ref.watch(notificationsProvider).valueOrNull ?? [];
  return notifications.where((n) => !n.isRead).length;
});

class NotificationListNotifier
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  NotificationListNotifier(this.repository, this.userId)
      : super(const AsyncLoading()) {
    if (userId != null) {
      loadInitial();
      _setupRealtime();
    } else {
      state = const AsyncData([]);
    }
  }

  final NotificationRepository repository;
  final String? userId;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  static const int _pageSize = 50;
  RealtimeChannel? _channel;

  void _setupRealtime() {
    _channel = supabase
        .channel('public:notifications:user=$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            AppLogger.info(
                LogCategory.notifications, 'Realtime update received');
            // On any change, simplest approach for RC4 is to refresh the top page
            // to ensure accurate unread counts and ordering without complex merge logic.
            refresh();
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  Future<void> loadInitial() async {
    state = const AsyncLoading();
    try {
      final items = await repository.getNotifications(userId!,
          offset: 0, limit: _pageSize);
      _hasMore = items.length == _pageSize;
      state = AsyncData(items);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    if (userId == null) return;
    try {
      final items = await repository.getNotifications(userId!,
          offset: 0, limit: _pageSize);
      _hasMore = items.length == _pageSize;
      state = AsyncData(items);
    } catch (e, st) {
      // Don't override state with error if we already have data, just log it
      AppLogger.error(
          LogCategory.notifications, 'Failed to refresh notifications',
          error: e, stack: st);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore ||
        state.isLoading ||
        state.isRefreshing ||
        state.valueOrNull == null ||
        userId == null) return;

    final currentItems = state.value!;
    try {
      final newItems = await repository.getNotifications(
        userId!,
        offset: currentItems.length,
        limit: _pageSize,
      );

      _hasMore = newItems.length == _pageSize;
      state = AsyncData([...currentItems, ...newItems]);
    } catch (e, st) {
      AppLogger.error(
          LogCategory.notifications, 'Failed to load more notifications',
          error: e, stack: st);
    }
  }
}
