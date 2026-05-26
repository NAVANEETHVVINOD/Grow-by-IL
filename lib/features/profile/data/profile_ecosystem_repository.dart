import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grow/shared/models/profile_ecosystem_models.dart';
import 'package:grow/shared/repositories/supabase_client.dart';

/// Repository for the profile ecosystem tables.
/// All writes are owner-only via RLS. Reads respect visibility.
class ProfileEcosystemRepository {
  const ProfileEcosystemRepository();

  // ─── USER PROFILE ────────────────────────────────────

  Future<UserProfileModel?> getProfile(String userId) async {
    final response = await supabase
        .from('user_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (response == null) return null;
    return UserProfileModel.fromJson(response);
  }

  Future<UserProfileModel> upsertProfile(UserProfileModel profile) async {
    final response = await supabase
        .from('user_profiles')
        .upsert(profile.toJson(), onConflict: 'user_id')
        .select()
        .single();
    return UserProfileModel.fromJson(response);
  }

  // ─── EXPERIENCE ──────────────────────────────────────

  Future<List<UserExperienceModel>> getExperience(String userId) async {
    final response = await supabase
        .from('user_experience')
        .select()
        .eq('user_id', userId)
        .order('sort_order');
    return (response as List).map((e) => UserExperienceModel.fromJson(e)).toList();
  }

  Future<UserExperienceModel> addExperience(UserExperienceModel item) async {
    final response = await supabase
        .from('user_experience')
        .insert(item.toJson())
        .select()
        .single();
    return UserExperienceModel.fromJson(response);
  }

  Future<void> updateExperience(String id, Map<String, dynamic> updates) async {
    await supabase.from('user_experience').update(updates).eq('id', id);
  }

  Future<void> deleteExperience(String id) async {
    await supabase.from('user_experience').delete().eq('id', id);
  }

  // ─── EDUCATION ───────────────────────────────────────

  Future<List<UserEducationModel>> getEducation(String userId) async {
    final response = await supabase
        .from('user_education')
        .select()
        .eq('user_id', userId)
        .order('sort_order');
    return (response as List).map((e) => UserEducationModel.fromJson(e)).toList();
  }

  Future<UserEducationModel> addEducation(UserEducationModel item) async {
    final response = await supabase
        .from('user_education')
        .insert(item.toJson())
        .select()
        .single();
    return UserEducationModel.fromJson(response);
  }

  Future<void> updateEducation(String id, Map<String, dynamic> updates) async {
    await supabase.from('user_education').update(updates).eq('id', id);
  }

  Future<void> deleteEducation(String id) async {
    await supabase.from('user_education').delete().eq('id', id);
  }

  // ─── PORTFOLIO PROJECTS ──────────────────────────────

  Future<List<UserPortfolioProjectModel>> getPortfolioProjects(String userId) async {
    final response = await supabase
        .from('user_portfolio_projects')
        .select()
        .eq('user_id', userId)
        .order('sort_order');
    return (response as List).map((e) => UserPortfolioProjectModel.fromJson(e)).toList();
  }

  Future<UserPortfolioProjectModel> addPortfolioProject(UserPortfolioProjectModel item) async {
    final response = await supabase
        .from('user_portfolio_projects')
        .insert(item.toJson())
        .select()
        .single();
    return UserPortfolioProjectModel.fromJson(response);
  }

  Future<void> updatePortfolioProject(String id, Map<String, dynamic> updates) async {
    await supabase.from('user_portfolio_projects').update(updates).eq('id', id);
  }

  Future<void> deletePortfolioProject(String id) async {
    await supabase.from('user_portfolio_projects').delete().eq('id', id);
  }

  // ─── VOLUNTEERING ────────────────────────────────────

  Future<List<UserVolunteeringModel>> getVolunteering(String userId) async {
    final response = await supabase
        .from('user_volunteering')
        .select()
        .eq('user_id', userId)
        .order('sort_order');
    return (response as List).map((e) => UserVolunteeringModel.fromJson(e)).toList();
  }

  Future<UserVolunteeringModel> addVolunteering(UserVolunteeringModel item) async {
    final response = await supabase
        .from('user_volunteering')
        .insert(item.toJson())
        .select()
        .single();
    return UserVolunteeringModel.fromJson(response);
  }

  Future<void> updateVolunteering(String id, Map<String, dynamic> updates) async {
    await supabase.from('user_volunteering').update(updates).eq('id', id);
  }

  Future<void> deleteVolunteering(String id) async {
    await supabase.from('user_volunteering').delete().eq('id', id);
  }

  // ─── SOCIAL LINKS ────────────────────────────────────

  Future<List<UserSocialLinkModel>> getSocialLinks(String userId) async {
    final response = await supabase
        .from('user_social_links')
        .select()
        .eq('user_id', userId)
        .order('sort_order');
    return (response as List).map((e) => UserSocialLinkModel.fromJson(e)).toList();
  }

  Future<UserSocialLinkModel> upsertSocialLink(UserSocialLinkModel link) async {
    final response = await supabase
        .from('user_social_links')
        .upsert(link.toJson(), onConflict: 'user_id,platform')
        .select()
        .single();
    return UserSocialLinkModel.fromJson(response);
  }

  Future<void> deleteSocialLink(String id) async {
    await supabase.from('user_social_links').delete().eq('id', id);
  }

  // ─── SKILLS ──────────────────────────────────────────

  Future<List<UserSkillModel>> getSkills(String userId) async {
    final response = await supabase
        .from('user_skills')
        .select()
        .eq('user_id', userId)
        .order('sort_order');
    return (response as List).map((e) => UserSkillModel.fromJson(e)).toList();
  }

  Future<UserSkillModel> upsertSkill(UserSkillModel skill) async {
    final response = await supabase
        .from('user_skills')
        .upsert(skill.toJson(), onConflict: 'user_id,name')
        .select()
        .single();
    return UserSkillModel.fromJson(response);
  }

  Future<void> deleteSkill(String id) async {
    await supabase.from('user_skills').delete().eq('id', id);
  }

  // ─── INTERESTS ───────────────────────────────────────

  Future<List<String>> getInterests(String userId) async {
    final response = await supabase
        .from('user_interests')
        .select('name')
        .eq('user_id', userId);
    return (response as List).map((e) => e['name'] as String).toList();
  }

  Future<void> setInterests(String userId, List<String> interests) async {
    // Delete all existing interests and re-insert
    await supabase.from('user_interests').delete().eq('user_id', userId);
    if (interests.isEmpty) return;
    final rows = interests.map((name) => {'user_id': userId, 'name': name}).toList();
    await supabase.from('user_interests').insert(rows);
  }
}

/// Riverpod provider for the profile ecosystem repository.
final profileEcosystemRepositoryProvider = Provider<ProfileEcosystemRepository>((ref) {
  return const ProfileEcosystemRepository();
});
