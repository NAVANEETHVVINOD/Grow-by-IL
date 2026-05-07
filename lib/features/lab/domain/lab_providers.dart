import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/lab_session_model.dart';
import '../../../shared/repositories/supabase_client.dart';
import '../../auth/data/auth_repository.dart';
import '../data/lab_repository.dart';

/// Provider for the LabRepository singleton.
final labRepositoryProvider = Provider<LabRepository>((ref) {
  return LabRepository(supabase);
});

/// The current user's active lab session (null if not checked in).
final activeSessionProvider = FutureProvider.autoDispose<LabSessionModel?>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return null;

  final repo = ref.watch(labRepositoryProvider);
  return repo.getActiveSession(user.id);
});

/// Real-time count of people currently in the lab.
final liveLabVisitorCountProvider = StreamProvider.autoDispose<int>((ref) {
  final repo = ref.watch(labRepositoryProvider);
  return repo.getLiveVisitorCount();
});

/// The current user's past sessions (most recent first).
final mySessionHistoryProvider =
    FutureProvider.autoDispose<List<LabSessionModel>>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return [];

  final repo = ref.watch(labRepositoryProvider);
  return repo.getMyHistory(user.id, limit: 10);
});
