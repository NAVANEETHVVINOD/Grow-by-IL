/// Type-safe role system for Grow~.
///
/// Maps to the PostgreSQL CHECK constraint on public.users.role:
///   role IN ('student', 'lab_admin', 'super_admin')
///
/// ALL role checks across the codebase MUST use this enum.
/// Never compare raw strings like `user.role == 'lab_admin'`.
enum AppRole {
  student('student', 'Student'),
  labAdmin('lab_admin', 'Lab Admin'),
  superAdmin('super_admin', 'Super Admin');

  const AppRole(this.value, this.displayName);

  /// The database column value (e.g. 'lab_admin').
  final String value;

  /// Human-readable label for UI display.
  final String displayName;

  /// Parse a database string into an [AppRole].
  /// Falls back to [AppRole.student] for unknown values.
  static AppRole fromString(String? raw) {
    if (raw == null || raw.isEmpty) return AppRole.student;
    return AppRole.values.firstWhere(
      (r) => r.value == raw,
      orElse: () => AppRole.student,
    );
  }

  /// Roles that grant access to the admin dashboard.
  static const Set<AppRole> adminRoles = {AppRole.labAdmin, AppRole.superAdmin};

  /// Roles available for self-selection during profile setup.
  /// Admin roles are assigned manually by super_admins, not self-selected.
  static const List<AppRole> selfAssignableRoles = [AppRole.student];

  /// Check if a raw role string represents an admin.
  static bool isAdminRole(String? role) {
    return adminRoles.contains(AppRole.fromString(role));
  }

  /// Check if a raw role string is a super admin.
  static bool isSuperAdminRole(String? role) {
    return AppRole.fromString(role) == AppRole.superAdmin;
  }
}
