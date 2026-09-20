/// Approved mobile confirmation callback used by Supabase Auth.
///
/// This value must be present in the Supabase Auth redirect allow-list for the
/// environment receiving the request. The callback deliberately signs the
/// temporary confirmation session out before returning the member to the
/// normal email-and-password sign-in screen.
class AppAuthRedirects {
  AppAuthRedirects._();

  static const emailConfirmationLanding =
      'com.idealab.mec.grow://auth/callback';

  /// Recovery uses the same verified mobile callback endpoint as confirmation.
  /// Supabase's signed recovery event—not a caller-controlled URL parameter—
  /// decides whether Grow may open the password-reset screen.
  static const passwordRecoveryLanding = emailConfirmationLanding;
}
