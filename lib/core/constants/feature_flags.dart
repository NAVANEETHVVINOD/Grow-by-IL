class FeatureFlags {
  FeatureFlags._();

  /// RC5 shell already depends on Akathalam; keep enabled by default.
  static const bool enableAkathalam =
      bool.fromEnvironment('ENABLE_AKATHALAM', defaultValue: true);

  /// Profile rollout guard for quick rollback without route rewrites.
  static const bool enableNewProfile =
      bool.fromEnvironment('ENABLE_NEW_PROFILE', defaultValue: true);

  /// UI placeholder flag only in this slice; backend arrives later.
  static const bool enableVouches =
      bool.fromEnvironment('ENABLE_VOUCHES', defaultValue: false);

  /// Safe onboarding & profile migration flag.
  static const bool kEnableProfileMigration = true;

  /// Debug diagnostics dashboard visibility toggle.
  static const bool kEnableDebugSyncDashboard = true;
}
