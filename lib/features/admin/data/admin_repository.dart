import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/app_logger.dart';
import '../../../shared/models/booking_model.dart';

class AdminRepository {
  final SupabaseClient _client;
  const AdminRepository(this._client);

  /// Fetch all pending tool bookings.
  Future<List<BookingModel>> getPendingBookings() async {
    try {
      final data = await _client
          .from('tool_bookings')
          .select('*, tools(name), users!tool_bookings_user_id_fkey(name)')
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      return (data as List).map((row) => BookingModel.fromJson(row)).toList();
    } catch (e, st) {
      AppLogger.error(
        LogCategory.admin,
        'getPendingBookings failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  /// Create a new tool (Admin).
  Future<void> addTool(Map<String, dynamic> toolData) async {
    try {
      await _client.from('tools').insert(toolData);
    } catch (e, st) {
      AppLogger.error(
        LogCategory.admin,
        'addTool failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  /// Update metadata for an existing tool (Admin).
  Future<void> updateTool(String id, Map<String, dynamic> updates) async {
    try {
      await _client.from('tools').update(updates).eq('id', id);
    } catch (e, st) {
      AppLogger.error(
        LogCategory.admin,
        'updateTool failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  /// Update a tool's health status and optional maintenance date (Admin).
  Future<void> updateToolStatus(
    String id,
    String status, {
    DateTime? lastMaintained,
  }) async {
    try {
      final updates = <String, dynamic>{'health_status': status};
      if (lastMaintained != null) {
        updates['last_maintained'] = lastMaintained.toUtc().toIso8601String();
      }
      await _client.from('tools').update(updates).eq('id', id);
    } catch (e, st) {
      AppLogger.error(
        LogCategory.admin,
        'updateToolStatus failed',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }
}
