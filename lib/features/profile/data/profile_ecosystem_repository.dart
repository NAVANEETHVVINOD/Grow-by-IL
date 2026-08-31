import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:grow/core/utils/app_logger.dart';
import 'package:grow/features/profile/domain/pending_profile_mutation.dart';
import 'package:grow/shared/models/profile_ecosystem_models.dart';
import 'package:grow/shared/repositories/supabase_client.dart';

/// Exception thrown when a write operation is successfully queued offline.
class OfflineQueueException implements Exception {
  const OfflineQueueException();
  @override
  String toString() =>
      'Offline: Changes queued on device. They will sync automatically.';
}

/// Repository for the profile ecosystem tables.
/// All writes are owner-only via RLS. Reads respect visibility.
class ProfileEcosystemRepository {
  const ProfileEcosystemRepository([this._client]);
  final SupabaseClient? _client;

  SupabaseClient get client => _client ?? supabase;

  /// Helper method to execute a write query. Catch network/socket errors,
  /// log it, append to the offline queue, and throw OfflineQueueException.
  Future<T> _executeWrite<T>({
    required String table,
    required String rowId,
    required Map<String, dynamic> payload,
    required String type, // 'upsert', 'delete'
    required Future<T> Function() supabaseCall,
    DateTime? lastKnownServerUpdatedAt,
  }) async {
    try {
      final result = await supabaseCall();
      AppLogger.info(LogCategory.profile,
          '[QUEUE_SYNC] Successful $type on $table for row $rowId');
      return result;
    } catch (e, st) {
      final errStr = e.toString();
      if (e is SocketException ||
          errStr.contains('SocketException') ||
          errStr.contains('Failed host lookup') ||
          errStr.contains('Network') ||
          errStr.contains('timeout')) {
        AppLogger.info(LogCategory.profile,
            '[PROFILE_QUEUE_RETRY] Device offline. Queueing $type on $table for row $rowId');

        await PendingProfileMutationQueue.addMutation(
          table: table,
          rowId: rowId,
          payload: payload,
          type: type,
          lastKnownServerUpdatedAt: lastKnownServerUpdatedAt,
        );
        throw const OfflineQueueException();
      }
      AppLogger.error(
          LogCategory.profile, 'Failed write on $table for row $rowId',
          error: e, stack: st);
      rethrow;
    }
  }

  /// Replays all offline queued mutations in order.
  /// Handles authentication suspension, stale write detection, and error backoff logging.
  Future<void> replayQueue() async {
    final queue = await PendingProfileMutationQueue.loadQueue();
    if (queue.isEmpty) return;

    // Diagnostics: respect manual pause toggle
    if (PendingProfileMutationQueue.isReplayPaused) {
      AppLogger.info(LogCategory.profile,
          '[QUEUE_SYNC] Replay paused by diagnostics toggle');
      return;
    }

    AppLogger.info(LogCategory.profile,
        '[QUEUE_SYNC] Starting offline queue replay of ${queue.length} mutations');

    for (final mutation in queue) {
      if (mutation.failedPermanently) {
        AppLogger.warn(LogCategory.profile,
            '[QUEUE_SYNC] Skipping permanently failed mutation ${mutation.id} on table ${mutation.table}');
        continue;
      }

      // Check authentication
      if (client.auth.currentSession == null) {
        AppLogger.warn(LogCategory.profile,
            '[QUEUE_SYNC] Sync suspended: No active authenticated session');
        return; // Suspend replay, preserve queue
      }

      try {
        // 1. Stale write detection
        bool isStale = false;
        try {
          final serverRow = await client
              .from(mutation.table)
              .select('updated_at')
              .eq('id', mutation.rowId)
              .maybeSingle();

          if (serverRow != null && serverRow['updated_at'] != null) {
            final serverUpdatedAt =
                DateTime.parse(serverRow['updated_at'] as String);
            if (mutation.lastKnownServerUpdatedAt != null &&
                serverUpdatedAt.isAfter(mutation.lastKnownServerUpdatedAt!)) {
              isStale = true;
              AppLogger.warn(
                LogCategory.profile,
                '[QUEUE_SYNC] Stale write detected on ${mutation.table} (Row: ${mutation.rowId}). Server: $serverUpdatedAt, Local base: ${mutation.lastKnownServerUpdatedAt}. Discarding local mutation.',
              );
            }
          }
        } catch (e) {
          // If the select fails (e.g. column updated_at doesn't exist on this table), we proceed with write
          AppLogger.info(LogCategory.profile,
              '[QUEUE_SYNC] Skipped stale check for ${mutation.table}: $e');
        }

        if (!isStale) {
          if (mutation.table == 'user_interests') {
            final interestsList =
                (mutation.payload['interests'] as List).cast<String>();
            final userId = mutation.rowId.replaceFirst('interests_', '');
            await client.from('user_interests').delete().eq('user_id', userId);
            if (interestsList.isNotEmpty) {
              final rows = interestsList
                  .map((name) => {'user_id': userId, 'name': name})
                  .toList();
              await client.from('user_interests').insert(rows);
            }
          } else if (mutation.type == 'upsert') {
            String? onConflict;
            if (mutation.table == 'user_profiles') {
              onConflict = 'user_id';
            } else if (mutation.table == 'user_social_links') {
              onConflict = 'user_id,platform';
            } else if (mutation.table == 'user_skills') {
              onConflict = 'user_id,name';
            } else if (mutation.table == 'user_education' ||
                mutation.table == 'user_experience' ||
                mutation.table == 'user_portfolio_projects' ||
                mutation.table == 'user_volunteering') {
              onConflict = 'id';
            }
            await client
                .from(mutation.table)
                .upsert(mutation.payload, onConflict: onConflict);
          } else if (mutation.type == 'delete') {
            await client.from(mutation.table).delete().eq('id', mutation.rowId);
          } else if (mutation.type == 'delete_by_name') {
            await client
                .from(mutation.table)
                .delete()
                .eq('user_id', mutation.payload['user_id'] as String)
                .eq('name', mutation.payload['name'] as String);
          } else if (mutation.type == 'delete_by_platform') {
            await client
                .from(mutation.table)
                .delete()
                .eq('user_id', mutation.payload['user_id'] as String)
                .eq('platform', mutation.payload['platform'] as String);
          }
          AppLogger.success(LogCategory.profile,
              '[QUEUE_SYNC] Successfully replayed mutation ${mutation.id} on table ${mutation.table}');
        }

        await PendingProfileMutationQueue.removeMutation(mutation.id);
      } catch (e, st) {
        final errStr = e.toString();
        if (e is SocketException ||
            errStr.contains('SocketException') ||
            errStr.contains('Failed host lookup') ||
            errStr.contains('Network') ||
            errStr.contains('timeout')) {
          AppLogger.warn(LogCategory.profile,
              '[QUEUE_SYNC] Replay paused due to network connectivity failure.');
          return; // Stop processing queue to preserve order
        }

        // Increment retry count or mark permanent failure
        AppLogger.error(
          LogCategory.profile,
          '[QUEUE_SYNC] Failed to replay mutation ${mutation.id} on table ${mutation.table}',
          error: e,
          stack: st,
        );
        await PendingProfileMutationQueue.reportFailure(mutation.id);
        break; // Stop subsequent executions to maintain order
      }
    }
  }

  // ─── USER PROFILE ────────────────────────────────────

  Future<UserProfileModel?> getProfile(String userId) async {
    final response = await client
        .from('user_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (response == null) return null;
    return UserProfileModel.fromJson(response);
  }

  Future<UserProfileModel> upsertProfile(UserProfileModel profile) async {
    return _executeWrite<UserProfileModel>(
      table: 'user_profiles',
      rowId: profile.id,
      payload: profile.toJson(),
      type: 'upsert',
      supabaseCall: () async {
        final response = await client
            .from('user_profiles')
            .upsert(profile.toJson(), onConflict: 'user_id')
            .select()
            .single();
        return UserProfileModel.fromJson(response);
      },
    );
  }

  // ─── EXPERIENCE ──────────────────────────────────────

  Future<List<UserExperienceModel>> getExperience(String userId) async {
    final response = await client
        .from('user_experience')
        .select()
        .eq('user_id', userId)
        .order('sort_order');
    return (response as List)
        .map((e) => UserExperienceModel.fromJson(e))
        .toList();
  }

  Future<UserExperienceModel> addExperience(UserExperienceModel item) async {
    return _executeWrite<UserExperienceModel>(
      table: 'user_experience',
      rowId: item.id,
      payload: item.toJson(),
      type: 'upsert',
      supabaseCall: () async {
        final response = await client
            .from('user_experience')
            .upsert(item.toJson(), onConflict: 'id')
            .select()
            .single();
        return UserExperienceModel.fromJson(response);
      },
    );
  }

  Future<void> updateExperience(String id, Map<String, dynamic> updates) async {
    await _executeWrite<void>(
      table: 'user_experience',
      rowId: id,
      payload: {'id': id, ...updates},
      type: 'upsert',
      supabaseCall: () async {
        await client.from('user_experience').update(updates).eq('id', id);
      },
    );
  }

  Future<void> deleteExperience(String id) async {
    await _executeWrite<void>(
      table: 'user_experience',
      rowId: id,
      payload: {},
      type: 'delete',
      supabaseCall: () async {
        await client.from('user_experience').delete().eq('id', id);
      },
    );
  }

  // ─── EDUCATION ───────────────────────────────────────

  Future<List<UserEducationModel>> getEducation(String userId) async {
    final response = await client
        .from('user_education')
        .select()
        .eq('user_id', userId)
        .order('sort_order');
    return (response as List)
        .map((e) => UserEducationModel.fromJson(e))
        .toList();
  }

  Future<UserEducationModel> addEducation(UserEducationModel item) async {
    return _executeWrite<UserEducationModel>(
      table: 'user_education',
      rowId: item.id,
      payload: item.toJson(),
      type: 'upsert',
      supabaseCall: () async {
        final response = await client
            .from('user_education')
            .upsert(item.toJson(), onConflict: 'id')
            .select()
            .single();
        return UserEducationModel.fromJson(response);
      },
    );
  }

  Future<void> updateEducation(String id, Map<String, dynamic> updates) async {
    await _executeWrite<void>(
      table: 'user_education',
      rowId: id,
      payload: {'id': id, ...updates},
      type: 'upsert',
      supabaseCall: () async {
        await client.from('user_education').update(updates).eq('id', id);
      },
    );
  }

  Future<void> deleteEducation(String id) async {
    await _executeWrite<void>(
      table: 'user_education',
      rowId: id,
      payload: {},
      type: 'delete',
      supabaseCall: () async {
        await client.from('user_education').delete().eq('id', id);
      },
    );
  }

  // ─── PORTFOLIO PROJECTS ──────────────────────────────

  Future<List<UserPortfolioProjectModel>> getPortfolioProjects(
      String userId) async {
    final response = await client
        .from('user_portfolio_projects')
        .select()
        .eq('user_id', userId)
        .order('sort_order');
    return (response as List)
        .map((e) => UserPortfolioProjectModel.fromJson(e))
        .toList();
  }

  Future<UserPortfolioProjectModel> addPortfolioProject(
      UserPortfolioProjectModel item) async {
    return _executeWrite<UserPortfolioProjectModel>(
      table: 'user_portfolio_projects',
      rowId: item.id,
      payload: item.toJson(),
      type: 'upsert',
      supabaseCall: () async {
        final response = await client
            .from('user_portfolio_projects')
            .upsert(item.toJson(), onConflict: 'id')
            .select()
            .single();
        return UserPortfolioProjectModel.fromJson(response);
      },
    );
  }

  Future<void> updatePortfolioProject(
      String id, Map<String, dynamic> updates) async {
    await _executeWrite<void>(
      table: 'user_portfolio_projects',
      rowId: id,
      payload: {'id': id, ...updates},
      type: 'upsert',
      supabaseCall: () async {
        await client
            .from('user_portfolio_projects')
            .update(updates)
            .eq('id', id);
      },
    );
  }

  Future<void> deletePortfolioProject(String id) async {
    await _executeWrite<void>(
      table: 'user_portfolio_projects',
      rowId: id,
      payload: {},
      type: 'delete',
      supabaseCall: () async {
        await client.from('user_portfolio_projects').delete().eq('id', id);
      },
    );
  }

  // ─── VOLUNTEERING ────────────────────────────────────

  Future<List<UserVolunteeringModel>> getVolunteering(String userId) async {
    final response = await client
        .from('user_volunteering')
        .select()
        .eq('user_id', userId)
        .order('sort_order');
    return (response as List)
        .map((e) => UserVolunteeringModel.fromJson(e))
        .toList();
  }

  Future<UserVolunteeringModel> addVolunteering(
      UserVolunteeringModel item) async {
    return _executeWrite<UserVolunteeringModel>(
      table: 'user_volunteering',
      rowId: item.id,
      payload: item.toJson(),
      type: 'upsert',
      supabaseCall: () async {
        final response = await client
            .from('user_volunteering')
            .upsert(item.toJson(), onConflict: 'id')
            .select()
            .single();
        return UserVolunteeringModel.fromJson(response);
      },
    );
  }

  Future<void> updateVolunteering(
      String id, Map<String, dynamic> updates) async {
    await _executeWrite<void>(
      table: 'user_volunteering',
      rowId: id,
      payload: {'id': id, ...updates},
      type: 'upsert',
      supabaseCall: () async {
        await client.from('user_volunteering').update(updates).eq('id', id);
      },
    );
  }

  Future<void> deleteVolunteering(String id) async {
    await _executeWrite<void>(
      table: 'user_volunteering',
      rowId: id,
      payload: {},
      type: 'delete',
      supabaseCall: () async {
        await client.from('user_volunteering').delete().eq('id', id);
      },
    );
  }

  // ─── SOCIAL LINKS ────────────────────────────────────

  Future<List<UserSocialLinkModel>> getSocialLinks(String userId) async {
    final response = await client
        .from('user_social_links')
        .select()
        .eq('user_id', userId)
        .order('sort_order');
    return (response as List)
        .map((e) => UserSocialLinkModel.fromJson(e))
        .toList();
  }

  Future<UserSocialLinkModel> upsertSocialLink(UserSocialLinkModel link) async {
    return _executeWrite<UserSocialLinkModel>(
      table: 'user_social_links',
      rowId: link.id,
      payload: link.toJson(),
      type: 'upsert',
      supabaseCall: () async {
        final response = await client
            .from('user_social_links')
            .upsert(link.toJson(), onConflict: 'user_id,platform')
            .select()
            .single();
        return UserSocialLinkModel.fromJson(response);
      },
    );
  }

  Future<void> deleteSocialLink(String id) async {
    await _executeWrite<void>(
      table: 'user_social_links',
      rowId: id,
      payload: {},
      type: 'delete',
      supabaseCall: () async {
        await client.from('user_social_links').delete().eq('id', id);
      },
    );
  }

  Future<void> deleteSocialLinkByPlatform(
      String userId, String platform) async {
    await _executeWrite<void>(
      table: 'user_social_links',
      rowId: 'social_${userId}_$platform',
      payload: {'user_id': userId, 'platform': platform},
      type: 'delete_by_platform',
      supabaseCall: () async {
        await client
            .from('user_social_links')
            .delete()
            .eq('user_id', userId)
            .eq('platform', platform);
      },
    );
  }

  // ─── SKILLS ──────────────────────────────────────────

  Future<List<UserSkillModel>> getSkills(String userId) async {
    final response = await client
        .from('user_skills')
        .select()
        .eq('user_id', userId)
        .order('sort_order');
    return (response as List).map((e) => UserSkillModel.fromJson(e)).toList();
  }

  Future<UserSkillModel> upsertSkill(UserSkillModel skill) async {
    return _executeWrite<UserSkillModel>(
      table: 'user_skills',
      rowId: skill.id,
      payload: skill.toJson(),
      type: 'upsert',
      supabaseCall: () async {
        final response = await client
            .from('user_skills')
            .upsert(skill.toJson(), onConflict: 'user_id,name')
            .select()
            .single();
        return UserSkillModel.fromJson(response);
      },
    );
  }

  Future<void> deleteSkill(String id) async {
    await _executeWrite<void>(
      table: 'user_skills',
      rowId: id,
      payload: {},
      type: 'delete',
      supabaseCall: () async {
        await client.from('user_skills').delete().eq('id', id);
      },
    );
  }

  Future<void> deleteSkillByName(String userId, String name) async {
    await _executeWrite<void>(
      table: 'user_skills',
      rowId: 'skill_${userId}_$name',
      payload: {'user_id': userId, 'name': name},
      type: 'delete_by_name',
      supabaseCall: () async {
        await client
            .from('user_skills')
            .delete()
            .eq('user_id', userId)
            .eq('name', name);
      },
    );
  }

  // ─── INTERESTS ───────────────────────────────────────

  Future<List<String>> getInterests(String userId) async {
    final response = await client
        .from('user_interests')
        .select('name')
        .eq('user_id', userId);
    return (response as List).map((e) => e['name'] as String).toList();
  }

  Future<void> setInterests(String userId, List<String> interests) async {
    await _executeWrite<void>(
      table: 'user_interests',
      rowId: 'interests_$userId',
      payload: {'interests': interests},
      type: 'upsert',
      supabaseCall: () async {
        await client.from('user_interests').delete().eq('user_id', userId);
        if (interests.isEmpty) return;
        final rows =
            interests.map((name) => {'user_id': userId, 'name': name}).toList();
        await client.from('user_interests').insert(rows);
      },
    );
  }
}

/// Riverpod provider for the profile ecosystem repository.
final profileEcosystemRepositoryProvider =
    Provider<ProfileEcosystemRepository>((ref) {
  return const ProfileEcosystemRepository();
});
