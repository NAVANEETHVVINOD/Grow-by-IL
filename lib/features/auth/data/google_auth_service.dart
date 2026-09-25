import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/utils/app_logger.dart';
import '../../../shared/repositories/supabase_client.dart';

class GoogleAuthService {
  static const _webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  /// Native Google sign-in needs the Supabase-compatible web OAuth client ID.
  /// Keep the button unavailable rather than sending users into a known-broken
  /// flow when it has not been injected by the build environment.
  static bool get isConfigured => _webClientId.isNotEmpty;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // On Android, clientId MUST be null (it uses SHA-1/Package binding).
    // On Web, it MUST be the Web Client ID.
    clientId: kIsWeb ? (_webClientId.isEmpty ? null : _webClientId) : null,
    // serverClientId is used on Android to get an idToken for backend verification (Supabase).
    serverClientId:
        kIsWeb ? null : (_webClientId.isEmpty ? null : _webClientId),
  );

  Future<AuthResponse?> signInWithGoogle() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      AppLogger.info(
        LogCategory.auth,
        'GOOGLE_SIGN_IN_START | '
        'platform=${kIsWeb ? 'web' : 'android'} '
        'package=${packageInfo.packageName} '
        'clientIdSetting=${kIsWeb ? 'explicit' : 'auto'} '
        'serverClientIdSetting=${!kIsWeb ? 'explicit' : 'none'}',
      );

      AppLogger.info(LogCategory.auth, 'GOOGLE_PICKER_LAUNCHING');

      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        AppLogger.warn(
          LogCategory.auth,
          'GOOGLE_PICKER_CLOSED_OR_CANCELLED | User closed account picker or GMS sign-in aborted. (If immediate, check Android package name, SHA fingerprints, and empty oauth_client in google-services.json)',
        );
        return null;
      }

      AppLogger.success(LogCategory.auth, 'GOOGLE_USER_SELECTED');

      final googleAuth = await googleUser.authentication;

      AppLogger.info(
        LogCategory.auth,
        'GOOGLE_TOKENS_RECEIVED | '
        'idToken=${googleAuth.idToken != null ? 'PRESENT (${googleAuth.idToken!.length} chars)' : 'MISSING'} '
        'accessToken=${googleAuth.accessToken != null ? 'PRESENT (${googleAuth.accessToken!.length} chars)' : 'MISSING'}',
      );

      if (googleAuth.idToken == null) {
        throw Exception(
          'Google Auth failed: idToken is null. Check Cloud Console Android Client SHA-1 and ensure serverClientId matches Google Console.',
        );
      }

      // Authenticate with Supabase using the Google ID token. Firebase is used
      // elsewhere for platform services; it is not a second account authority.
      AppLogger.info(
        LogCategory.auth,
        'SUPABASE_SIGN_IN_START | provider=google | idTokenLength=${googleAuth.idToken?.length}',
      );
      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (response.user != null) {
        final existing = await supabase
            .from('users')
            .select('id, profile_completed')
            .eq('id', response.user!.id)
            .maybeSingle();

        if (existing == null) {
          AppLogger.info(
            LogCategory.auth,
            'GOOGLE_NEW_USER_DETECTED | creating profile row',
          );
          await supabase.from('users').insert(
                AppDefaults.buildNewUserRow(
                  userId: response.user!.id,
                  name: googleUser.displayName ?? '',
                  email: googleUser.email,
                ),
              );
        }
      }

      AppLogger.info(LogCategory.auth, 'GOOGLE_SIGN_IN_COMPLETE');
      return response;
    } catch (e, st) {
      AppLogger.error(
        LogCategory.auth,
        'GOOGLE_SIGN_IN_FATAL',
        error: e,
        stack: st,
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      AppLogger.info(LogCategory.auth, 'GOOGLE_SIGN_OUT_COMPLETE');
    } catch (e, st) {
      AppLogger.error(
        LogCategory.auth,
        'GOOGLE_SIGN_OUT_FAILED',
        error: e,
        stack: st,
      );
    }
  }
}
