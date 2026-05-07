import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/utils/app_logger.dart';
import '../../../shared/models/lab_session_model.dart';

class LabRepository {
  LabRepository(this._client);
  final SupabaseClient _client;

  /// Get the user's currently active session (checkin without checkout).
  Future<LabSessionModel?> getActiveSession(String userId) async {
    AppLogger.action('Lab', 'getActiveSession', data: {'userId': userId});
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
      AppLogger.error('Lab', 'getActiveSession failed', e, st);
      return null;
    }
  }

  /// Check the user into the lab.
  Future<LabSessionModel> checkIn(String userId, String purpose) async {
    AppLogger.action('Lab', 'checkIn', data: {
      'userId': userId,
      'purpose': purpose,
    });

    try {
      final data = await _client.from('lab_sessions').insert({
        'user_id': userId,
        'purpose': purpose,
      }).select().single();

      final session = LabSessionModel.fromJson(data);
      AppLogger.info('Lab', 'Check-in successful, sessionId: ${session.id}');
      return session;
    } catch (e, st) {
      AppLogger.error('Lab', 'Check-in failed', e, st);
      rethrow;
    }
  }

  /// Check the user out of the lab.
  Future<void> checkOut(String sessionId) async {
    AppLogger.action('Lab', 'checkOut', data: {'sessionId': sessionId});

    try {
      await _client.from('lab_sessions').update({
        'checkout_time': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', sessionId);

      AppLogger.info('Lab', 'Check-out successful, sessionId: $sessionId');
    } catch (e, st) {
      AppLogger.error('Lab', 'Check-out failed', e, st);
      rethrow;
    }
  }

  /// Real-time stream of active visitor count.
  Stream<int> getLiveVisitorCount() {
    AppLogger.info('Lab', 'Subscribing to live visitor count stream');
    return _client
        .from('lab_sessions')
        .stream(primaryKey: ['id'])
        .map((rows) => rows.where((r) => r['checkout_time'] == null).length);
  }

  /// Get the user's session history.
  Future<List<LabSessionModel>> getMyHistory(String userId,
      {int limit = 20}) async {
    AppLogger.action('Lab', 'getMyHistory', data: {'userId': userId});
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
        AppLogger.warn('Auth', 'Heartbeat: no active session found');
        return;
      }
      final expiresAt = session.expiresAt;
      if (expiresAt == null) return;
      final expiresIn = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000)
          .difference(DateTime.now().toUtc());
      if (expiresIn.inMinutes < 10) {
        AppLogger.info(
            'Auth', 'Session expiring in ${expiresIn.inMinutes}m, refreshing...');
        await _client.auth.refreshSession();
        AppLogger.info('Auth', 'Session refreshed successfully');
      }
    } catch (e, st) {
      AppLogger.error('Auth', 'Session refresh failed', e, st);
    }
  }
}
