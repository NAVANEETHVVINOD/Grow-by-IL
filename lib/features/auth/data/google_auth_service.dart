import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../../core/utils/app_logger.dart';
import '../../../shared/repositories/supabase_client.dart';

class GoogleAuthService {
  static const _webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // On Android, clientId MUST be null (it uses SHA-1/Package binding).
    // On Web, it MUST be the Web Client ID.
    clientId: kIsWeb ? _webClientId : null,
    // serverClientId is used on Android to get an idToken for backend verification (Supabase).
    serverClientId: kIsWeb ? null : _webClientId,
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

      AppLogger.info(
        LogCategory.auth,
        'GOOGLE_PICKER_LAUNCHING | serverClientId=${_googleSignIn.serverClientId} | clientId=${_googleSignIn.clientId}',
      );

      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        AppLogger.warn(
          LogCategory.auth,
          'GOOGLE_PICKER_CLOSED_OR_CANCELLED | User closed account picker or GMS sign-in aborted. (If immediate, check Android package name, SHA fingerprints, and empty oauth_client in google-services.json)',
        );
        return null;
      }

      AppLogger.success(
        LogCategory.auth,
        'GOOGLE_USER_SELECTED | email=${googleUser.email} | id=${googleUser.id}',
      );

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

      // 2. Firebase Session Verification (with dynamic fallback protection)
      try {
        AppLogger.info(
          LogCategory.auth,
          'FIREBASE_VERIFICATION_START | idTokenLength=${googleAuth.idToken?.length} | accessTokenLength=${googleAuth.accessToken?.length}',
        );
        final fb.AuthCredential credential = fb.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        AppLogger.info(
          LogCategory.auth,
          'FIREBASE_SIGNING_IN_WITH_CREDENTIAL | credentialProviderId=${credential.providerId}',
        );
        final fbUserCred =
            await fb.FirebaseAuth.instance.signInWithCredential(credential);
        AppLogger.success(
          LogCategory.auth,
          'FIREBASE_VERIFICATION_SUCCESS | email=${fbUserCred.user?.email} | uid=${fbUserCred.user?.uid}',
        );
      } catch (fbError, fbStack) {
        AppLogger.error(
          LogCategory.auth,
          'FIREBASE_VERIFICATION_FAILED | Proceeding with pure direct Supabase login fallback',
          error: fbError,
          stack: fbStack,
        );
      }

      // 3. Authenticate with Supabase using the Google ID Token
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
          await supabase.from('users').insert({
            'id': response.user!.id,
            'name': googleUser.displayName ?? 'Maker',
            'email': googleUser.email,
            'role': 'student', // Match existing DB column 'role'
            'profile_completed': false,
            'xp': 0,
            'level': 1,
            'reputation_score': 100,
            'qr_code_data': 'GROWLAB-USER-${response.user!.id}',
          });
        }
      }

      AppLogger.info(
        LogCategory.auth,
        'GOOGLE_SIGN_IN_COMPLETE | userId=${response.user?.id}',
      );
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
      await fb.FirebaseAuth.instance.signOut();
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
