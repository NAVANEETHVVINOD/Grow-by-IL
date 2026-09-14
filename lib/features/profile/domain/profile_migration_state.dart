import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum representing the synchronization and migration state of a user profile.
enum ProfileMigrationState {
  localOnly,
  migrating,
  migrated,
  failed,
}

/// Helper class to read, write, and manage onboarding migration states,
/// checkpoints, and schema versioning inside SharedPreferences.
class ProfileMigrationStorage {
  ProfileMigrationStorage._();

  static const String _stateKey = 'profile_migration_state';
  static const String _versionKey = 'profile_schema_version';
  static const String _checkpointKey = 'profile_migration_checkpoint';

  /// The current schema version of user profile definitions.
  static const int currentProfileSchemaVersion = 2;

  /// Retrieves the current migration state for a user.
  static Future<ProfileMigrationState> getMigrationState(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('${_stateKey}_$userId');
    if (value == null) return ProfileMigrationState.localOnly;
    return ProfileMigrationState.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ProfileMigrationState.localOnly,
    );
  }

  /// Sets the migration state for a user.
  static Future<void> setMigrationState(
      String userId, ProfileMigrationState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_stateKey}_$userId', state.name);
  }

  /// Gets the local profile schema version for a user.
  static Future<int> getSchemaVersion(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('${_versionKey}_$userId') ?? 0;
  }

  /// Sets the local profile schema version for a user.
  static Future<void> setSchemaVersion(String userId, int version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_versionKey}_$userId', version);
  }

  /// Gets the checkpoints map of successfully migrated sub-tables.
  static Future<Map<String, bool>> getCheckpoints(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('${_checkpointKey}_$userId') ?? [];
    final map = <String, bool>{};
    for (final item in list) {
      final parts = item.split(':');
      if (parts.length == 2) {
        map[parts[0]] = parts[1] == 'true';
      }
    }
    return map;
  }

  /// Saves the checkpoints map of successfully migrated sub-tables.
  static Future<void> setCheckpoints(
      String userId, Map<String, bool> checkpoints) async {
    final prefs = await SharedPreferences.getInstance();
    final list = checkpoints.entries.map((e) => '${e.key}:${e.value}').toList();
    await prefs.setStringList('${_checkpointKey}_$userId', list);
  }

  /// Clears checkpoint logs after a successful migration.
  static Future<void> clearCheckpoints(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_checkpointKey}_$userId');
  }

  static const String _profileCacheKey = 'profile_cache';

  /// Caches full profile data locally in JSON format.
  static Future<void> cacheProfileData({
    required String userId,
    required String username,
    required String departmentOrRole,
    required String bio,
    required List<String> interests,
    required Map<String, int> skills,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final serializedSkills =
        skills.entries.map((e) => '${e.key}:${e.value}').toList();
    final map = {
      'username': username,
      'departmentOrRole': departmentOrRole,
      'bio': bio,
      'interests': interests,
      'skills': serializedSkills,
    };
    await prefs.setString('${_profileCacheKey}_$userId', json.encode(map));
  }

  /// Loads cached profile data locally (used during offline fallbacks).
  static Future<Map<String, dynamic>?> getCachedProfileData(
      String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('${_profileCacheKey}_$userId');
    if (raw == null) return null;
    return json.decode(raw) as Map<String, dynamic>;
  }
}
