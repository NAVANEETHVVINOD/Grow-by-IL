import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/app_logger.dart';
import '../../../shared/models/lab_session_model.dart';

class LabRepository {
  LabRepository(this._client);
  final SupabaseClient _client;

  /// Get the user's currently active session (checkin without checkout).
  Future<LabSessionModel?> getActiveSession(String userId) async {
    AppLogger.action(LogCategory.lab, 'getActiveSession', {'userId': userId});
    try {
      final data = await _client
          .from('lab_sessions')
          .select()
          .eq('user_id', userId)
          .isFilter('checkout_time', null)
          .order('checkin_time', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data == null) return null;
      return LabSessionModel.fromJson(data);
    } catch (e, st) {
      AppLogger.error(LogCategory.lab, 'getActiveSession failed', error: e, stack: st);
      return null;
    }
  }

  /// Check the user into the lab.
  Future<LabSessionModel> checkIn(String userId, String purpose) async {
    AppLogger.action(LogCategory.lab, 'checkIn', {
      'userId': userId,
      'purpose': purpose,
    });

    try {
      final data = await _client.from('lab_sessions').insert({
        'user_id': userId,
        'purpose': purpose,
      }).select().single();

      final session = LabSessionModel.fromJson(data);
      AppLogger.info(LogCategory.lab, 'Check-in successful, sessionId: ${session.id}');
      return session;
    } catch (e, st) {
      AppLogger.error(LogCategory.lab, 'Check-in failed', error: e, stack: st);
      rethrow;
    }
  }

  /// Check the user out of the lab.
  Future<void> checkOut(String sessionId) async {
    AppLogger.action(LogCategory.lab, 'checkOut', {'sessionId': sessionId});

    try {
      await _client.from('lab_sessions').update({
        'checkout_time': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', sessionId);

      AppLogger.info(LogCategory.lab, 'Check-out successful, sessionId: $sessionId');
    } catch (e, st) {
      AppLogger.error(LogCategory.lab, 'Check-out failed', error: e, stack: st);
      rethrow;
    }
  }

  /// Real-time stream of active visitor count.
  Stream<int> getLiveVisitorCount() {
    AppLogger.info(LogCategory.lab, 'Subscribing to live visitor count stream');
    return _client
        .from('lab_sessions')
        .stream(primaryKey: ['id'])
        .map((rows) => rows.where((r) => r['checkout_time'] == null).length);
  }

  /// Get the user's session history.
  Future<List<LabSessionModel>> getMyHistory(String userId,
      {int limit = 20}) async {
    AppLogger.action(LogCategory.lab, 'getMyHistory', {'userId': userId});
    final data = await _client
        .from('lab_sessions')
        .select()
        .eq('user_id', userId)
        .order('checkin_time', ascending: false)
        .limit(limit);

    return (data as List)
        .map((row) => LabSessionModel.fromJson(row))
        .toList();
  }
  /// Refresh Supabase auth session if close to expiry.
  Future<void> refreshSession() async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) {
        AppLogger.warn(LogCategory.auth, 'Heartbeat: no active session found');
        return;
      }
      final expiresAt = session.expiresAt;
      if (expiresAt == null) return;
      final expiresIn = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000)
          .difference(DateTime.now().toUtc());
      if (expiresIn.inMinutes < 10) {
        AppLogger.info(
            LogCategory.auth, 'Session expiring in ${expiresIn.inMinutes}m, refreshing...');
        await _client.auth.refreshSession();
        AppLogger.info(LogCategory.auth, 'Session refreshed successfully');
      }
    } catch (e, st) {
      AppLogger.error(LogCategory.auth, 'Session refresh failed', error: e, stack: st);
    }
  }
}
