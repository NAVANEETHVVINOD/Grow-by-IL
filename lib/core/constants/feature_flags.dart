class FeatureFlags {
  FeatureFlags._();

  /// Profile rollout guard for quick rollback without route rewrites.
  static const bool enableNewProfile =
      bool.fromEnvironment('ENABLE_NEW_PROFILE', defaultValue: true);

  /// UI placeholder flag only in this slice; backend arrives later.
  static const bool enableVouches =
      bool.fromEnvironment('ENABLE_VOUCHES', defaultValue: false);

  /// V1 operations foundation for Work Requests and machine task queues.
  static const bool enableWorkRequests =
      bool.fromEnvironment('ENABLE_WORK_REQUESTS', defaultValue: true);

  /// Safe onboarding & profile migration flag.
  static const bool kEnableProfileMigration = true;

  /// Debug diagnostics dashboard visibility toggle.
  static const bool kEnableDebugSyncDashboard = true;
}
