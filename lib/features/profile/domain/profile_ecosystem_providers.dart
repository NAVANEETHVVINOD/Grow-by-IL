import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/profile/data/profile_ecosystem_repository.dart';
import 'package:grow/shared/models/profile_ecosystem_models.dart';

/// ─── USER PROFILE ────────────────────────────────────

final userProfileProvider = FutureProvider<UserProfileModel?>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return null;
  final repo = ref.read(profileEcosystemRepositoryProvider);
  return repo.getProfile(user.id);
});

/// ─── EXPERIENCE ──────────────────────────────────────

final userExperienceProvider = FutureProvider<List<UserExperienceModel>>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const [];
  final repo = ref.read(profileEcosystemRepositoryProvider);
  return repo.getExperience(user.id);
});

/// ─── EDUCATION ───────────────────────────────────────

final userEducationProvider = FutureProvider<List<UserEducationModel>>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const [];
  final repo = ref.read(profileEcosystemRepositoryProvider);
  return repo.getEducation(user.id);
});

/// ─── PORTFOLIO PROJECTS ──────────────────────────────

final userPortfolioProjectsProvider = FutureProvider<List<UserPortfolioProjectModel>>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const [];
  final repo = ref.read(profileEcosystemRepositoryProvider);
  return repo.getPortfolioProjects(user.id);
});

/// ─── VOLUNTEERING ────────────────────────────────────

final userVolunteeringProvider = FutureProvider<List<UserVolunteeringModel>>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const [];
  final repo = ref.read(profileEcosystemRepositoryProvider);
  return repo.getVolunteering(user.id);
});

/// ─── SOCIAL LINKS ────────────────────────────────────

final userSocialLinksProvider = FutureProvider<List<UserSocialLinkModel>>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const [];
  final repo = ref.read(profileEcosystemRepositoryProvider);
  return repo.getSocialLinks(user.id);
});

/// ─── SKILLS ──────────────────────────────────────────

final userSkillsProvider = FutureProvider<List<UserSkillModel>>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const [];
  final repo = ref.read(profileEcosystemRepositoryProvider);
  return repo.getSkills(user.id);
});

/// ─── INTERESTS ───────────────────────────────────────

final userInterestsProvider = FutureProvider<List<String>>((ref) async {
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (user == null) return const [];
  final repo = ref.read(profileEcosystemRepositoryProvider);
  return repo.getInterests(user.id);
});
