import 'app_qr.dart';
import 'app_roles.dart';

/// Default values for new user profiles.
///
/// Single source of truth — prevents drift between the 3 places
/// that insert new user rows (signUp, Google login, auto-heal).
class AppDefaults {
  AppDefaults._();

  // ── Profile defaults (must match DB column defaults) ──────
  static const defaultUserName = 'Maker';
  static const defaultRole = AppRole.student;
  static const defaultXp = 0;
  static const defaultLevel = 1;
  static const defaultReputationScore = 100;
  static const defaultProfileCompleted = false;

  /// Build a complete row for inserting into `public.users`.
  ///
  /// Used by: signUp, Google sign-in, and the self-healing auto-create.
  static Map<String, dynamic> buildNewUserRow({
    required String userId,
    required String name,
    required String email,
    String? phone,
    String? collegeRoll,
  }) {
    return {
      'id': userId,
      'name': name.isNotEmpty ? name : defaultUserName,
      'email': email,
      if (phone != null) 'phone': phone,
      if (collegeRoll != null) 'college_roll': collegeRoll,
      'role': defaultRole.value,
      'profile_completed': defaultProfileCompleted,
      'xp': defaultXp,
      'level': defaultLevel,
      'reputation_score': defaultReputationScore,
      'qr_code_data': AppQr.generateUserQr(userId),
    };
  }
}
