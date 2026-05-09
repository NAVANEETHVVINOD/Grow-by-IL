import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:grow/shared/models/notification_model.dart';
import 'package:grow/core/utils/app_logger.dart';

class NotificationRepository {
  final SupabaseClient _client;
  const NotificationRepository(this._client);

  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((n) => NotificationModel.fromJson(n))
          .toList();
    } catch (e) {
      AppLogger.error(
        LogCategory.notifications,
        'Error fetching notifications',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);
    } catch (e) {
      AppLogger.error(
        LogCategory.notifications,
        'Error marking as read',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true}).eq('user_id', userId);
    } catch (e) {
      AppLogger.error(
        LogCategory.notifications,
        'Error marking all as read',
        error: e,
      );
      rethrow;
    }
  }

  Future<void> createNotification(NotificationModel notification) async {
    try {
      await _client.from('notifications').insert(notification.toJson());
    } catch (e) {
      AppLogger.error(
        LogCategory.notifications,
        'Error creating notification',
        error: e,
      );
      rethrow;
    }
  }
}
