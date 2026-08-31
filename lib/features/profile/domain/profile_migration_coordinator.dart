import 'dart:async';

/// Global coordinator to lock and serialize profile migrations,
/// ensuring only one migration process runs at any time, preventing race conditions.
class ProfileMigrationCoordinator {
  ProfileMigrationCoordinator._();

  static Completer<void>? _activeMigration;

  /// Returns true if a profile migration is currently in progress.
  static bool get isMigrating => _activeMigration != null;

  /// Runs the provided migration callback inside a global mutex lock.
  /// If a migration is already active, returns the future of the active migration.
  static Future<void> run(Future<void> Function() migration) async {
    if (_activeMigration != null) {
      return _activeMigration!.future;
    }

    final completer = Completer<void>();
    _activeMigration = completer;

    try {
      await migration();
      completer.complete();
    } catch (e, st) {
      completer.completeError(e, st);
      rethrow;
    } finally {
      _activeMigration = null;
    }
  }
}
