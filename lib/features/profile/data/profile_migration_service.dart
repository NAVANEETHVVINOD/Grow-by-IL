import 'dart:io';
import 'package:grow/core/utils/app_logger.dart';
import 'package:grow/features/profile/data/profile_ecosystem_repository.dart';
import 'package:grow/features/profile/domain/profile_migration_state.dart';
import 'package:grow/shared/models/profile_ecosystem_models.dart';
import 'package:grow/shared/repositories/supabase_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Legacy onboarding draft data loaded from SharedPreferences.
class _LegacyDraftData {
  const _LegacyDraftData({
    required this.username,
    required this.bio,
    required this.userType,
    required this.department,
    required this.eduCollege,
    required this.eduDepartment,
    required this.eduYear,
    required this.eduKtuid,
    required this.skills,
    required this.interests,
    required this.socialGithub,
    required this.socialLinkedin,
    required this.socialWebsite,
    required this.isPublic,
    required this.hideSocial,
    required this.hideActivity,
  });

  final String username;
  final String bio;
  final String userType;
  final String department;
  final String eduCollege;
  final String eduDepartment;
  final String eduYear;
  final String eduKtuid;
  final Map<String, int> skills;
  final List<String> interests;
  final String socialGithub;
  final String socialLinkedin;
  final String socialWebsite;
  final bool isPublic;
  final bool hideSocial;
  final bool hideActivity;
}

/// Service that handles safe, idempotent, checkpoint-aware migrations
/// from local SharedPreferences drafts to the Supabase database.
class ProfileMigrationService {
  ProfileMigrationService(this._repository);

  final ProfileEcosystemRepository _repository;

  /// Loads the legacy onboarding draft from SharedPreferences.
  Future<_LegacyDraftData> _loadLegacyDraft(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'rc5_onboarding.$userId';

    final interests = prefs.getStringList('$key.interests') ?? const [];
    final skillEntries = prefs.getStringList('$key.skills') ?? const [];
    final skills = <String, int>{};

    for (final entry in skillEntries) {
      final parts = entry.split(':');
      if (parts.length != 2) continue;
      final level = int.tryParse(parts.last);
      if (level == null || level < 1 || level > 3) continue;
      skills[parts.first] = level;
    }

    return _LegacyDraftData(
      username: prefs.getString('$key.username') ?? '',
      bio: prefs.getString('$key.bio') ?? '',
      userType: prefs.getString('$key.userType') ?? 'student',
      department: prefs.getString('$key.department') ?? '',
      eduCollege: prefs.getString('$key.edu_college') ?? '',
      eduDepartment: prefs.getString('$key.edu_department') ?? '',
      eduYear: prefs.getString('$key.edu_year') ?? '',
      eduKtuid: prefs.getString('$key.edu_ktuid') ?? '',
      skills: skills,
      interests: interests.take(5).toList(),
      socialGithub: prefs.getString('$key.social_github') ?? '',
      socialLinkedin: prefs.getString('$key.social_linkedin') ?? '',
      socialWebsite: prefs.getString('$key.social_website') ?? '',
      isPublic: prefs.getBool('$key.visibility_public') ?? true,
      hideSocial: prefs.getBool('$key.visibility_hide_social') ?? false,
      hideActivity: prefs.getBool('$key.visibility_hide_activity') ?? false,
    );
  }

  /// Run the profile migration table-by-table.
  /// If it was interrupted, it will pick up from the saved checkpoints.
  Future<void> migrate(String userId) async {
    final state = await ProfileMigrationStorage.getMigrationState(userId);
    if (state == ProfileMigrationState.migrated) {
      AppLogger.info(LogCategory.profile, '[PROFILE_MIGRATION] Profile already migrated for $userId');
      return;
    }

    AppLogger.info(LogCategory.profile, '[PROFILE_MIGRATION] Starting profile migration for $userId (State: $state)');
    
    // Set state to migrating if we are starting fresh
    if (state == ProfileMigrationState.localOnly) {
      await ProfileMigrationStorage.setMigrationState(userId, ProfileMigrationState.migrating);
      await ProfileMigrationStorage.setCheckpoints(userId, {
        'profile': false,
        'education': false,
        'skills': false,
        'interests': false,
        'social_links': false,
      });
    }

    final draft = await _loadLegacyDraft(userId);
    final checkpoints = await ProfileMigrationStorage.getCheckpoints(userId);

    try {
      // ─── STEP 1: BASIC PROFILE ──────────────────────────────────────────
      if (checkpoints['profile'] != true) {
        AppLogger.info(LogCategory.profile, '[PROFILE_MIGRATION] Migrating profile metadata...');
        final serverProfile = await _repository.getProfile(userId);
        
        // Scalar Merge Rule: server ?? local
        final mergedProfile = UserProfileModel(
          id: serverProfile?.id ?? const Uuid().v4(),
          userId: userId,
          username: serverProfile?.username ?? (draft.username.isNotEmpty ? draft.username : null),
          bio: serverProfile?.bio.isNotEmpty == true ? serverProfile!.bio : draft.bio,
          userType: serverProfile?.userType ?? draft.userType,
          department: serverProfile?.department.isNotEmpty == true ? serverProfile!.department : draft.department,
          isPublic: serverProfile?.isPublic ?? draft.isPublic,
          showStats: serverProfile?.showStats ?? !draft.hideActivity,
        );

        await _repository.upsertProfile(mergedProfile);
        checkpoints['profile'] = true;
        await ProfileMigrationStorage.setCheckpoints(userId, checkpoints);
      }

      // ─── STEP 2: EDUCATION ──────────────────────────────────────────────
      if (checkpoints['education'] != true) {
        AppLogger.info(LogCategory.profile, '[PROFILE_MIGRATION] Migrating education history...');
        
        if (draft.eduCollege.isNotEmpty) {
          final serverEduList = await _repository.getEducation(userId);
          final exists = serverEduList.any((e) => e.institution == draft.eduCollege);
          
          if (!exists) {
            final eduItem = UserEducationModel(
              id: const Uuid().v4(),
              userId: userId,
              institution: draft.eduCollege,
              degree: draft.eduDepartment,
              endYear: int.tryParse(draft.eduYear),
              isCurrent: true,
            );
            await _repository.addEducation(eduItem);
          }

          // KTU ID Sync to users.college_roll if provided
          if (draft.eduKtuid.isNotEmpty) {
            await supabase.from('users').update({
              'college_roll': draft.eduKtuid,
            }).eq('id', userId);
          }
        }
        
        checkpoints['education'] = true;
        await ProfileMigrationStorage.setCheckpoints(userId, checkpoints);
      }

      // ─── STEP 3: SKILLS ─────────────────────────────────────────────────
      if (checkpoints['skills'] != true) {
        AppLogger.info(LogCategory.profile, '[PROFILE_MIGRATION] Migrating skills...');
        
        if (draft.skills.isNotEmpty) {
          final serverSkills = await _repository.getSkills(userId);
          
          // Array/List Merge Rule: union(server, local) keeping highest level
          final mergedSkills = <String, int>{};
          for (final s in serverSkills) {
            mergedSkills[s.name] = s.level;
          }
          draft.skills.forEach((name, level) {
            final existingLevel = mergedSkills[name] ?? 0;
            if (level > existingLevel) {
              mergedSkills[name] = level;
            }
          });

          for (final entry in mergedSkills.entries) {
            final skillItem = UserSkillModel(
              id: const Uuid().v4(),
              userId: userId,
              name: entry.key,
              level: entry.value,
            );
            await _repository.upsertSkill(skillItem);
          }
        }

        checkpoints['skills'] = true;
        await ProfileMigrationStorage.setCheckpoints(userId, checkpoints);
      }

      // ─── STEP 4: INTERESTS ──────────────────────────────────────────────
      if (checkpoints['interests'] != true) {
        AppLogger.info(LogCategory.profile, '[PROFILE_MIGRATION] Migrating interests...');
        
        if (draft.interests.isNotEmpty) {
          final serverInterests = await _repository.getInterests(userId);
          
          // Array/List Merge Rule: union(server, local)
          final mergedInterests = {...serverInterests, ...draft.interests}.toList();
          await _repository.setInterests(userId, mergedInterests);
        }

        checkpoints['interests'] = true;
        await ProfileMigrationStorage.setCheckpoints(userId, checkpoints);
      }

      // ─── STEP 5: SOCIAL LINKS ───────────────────────────────────────────
      if (checkpoints['social_links'] != true) {
        AppLogger.info(LogCategory.profile, '[PROFILE_MIGRATION] Migrating social links...');
        
        final socialMap = {
          'github': draft.socialGithub,
          'linkedin': draft.socialLinkedin,
          'website': draft.socialWebsite,
        };

        for (final entry in socialMap.entries) {
          final url = entry.value;
          if (url.isNotEmpty) {
            final linkItem = UserSocialLinkModel(
              id: const Uuid().v4(),
              userId: userId,
              platform: entry.key,
              url: url,
            );
            await _repository.upsertSocialLink(linkItem);
          }
        }

        checkpoints['social_links'] = true;
        await ProfileMigrationStorage.setCheckpoints(userId, checkpoints);
      }

      // ─── MIGRATION COMPLETED ────────────────────────────────────────────
      AppLogger.info(LogCategory.profile, '[PROFILE_MIGRATION] Profile migration completed successfully for $userId');
      await ProfileMigrationStorage.setMigrationState(userId, ProfileMigrationState.migrated);
      await ProfileMigrationStorage.setSchemaVersion(userId, ProfileMigrationStorage.currentProfileSchemaVersion);
      await ProfileMigrationStorage.clearCheckpoints(userId);

    } catch (e, st) {
      AppLogger.error(
        LogCategory.profile,
        '[PROFILE_MIGRATION] Migration failed for $userId. Checkpoints preserved.',
        error: e,
        stack: st,
      );
      
      // Do not reset state to localOnly; keep it as migrating so it continues on next start.
      if (e is! SocketException) {
        await ProfileMigrationStorage.setMigrationState(userId, ProfileMigrationState.failed);
      }
      rethrow;
    }
  }
}
