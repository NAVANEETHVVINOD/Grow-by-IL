import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/utils/app_logger.dart';
import '../../../shared/repositories/supabase_client.dart';

class GoogleAuthService {
  static const _webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '296487965900-aaerodr4oepoe36jtadeqc8hqgljm405.apps.googleusercontent.com',
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

      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        AppLogger.warn(
          LogCategory.auth,
          'GOOGLE_SIGN_IN_CANCELLED | User closed popup',
        );
        return null;
      }

      AppLogger.info(
        LogCategory.auth,
        'GOOGLE_USER_SELECTED | email=${googleUser.email}',
      );

      final googleAuth = await googleUser.authentication;

      AppLogger.info(
        LogCategory.auth,
        'GOOGLE_TOKENS_RECEIVED | '
        'idToken=${googleAuth.idToken != null ? 'PRESENT' : 'MISSING'} '
        'accessToken=${googleAuth.accessToken != null ? 'PRESENT' : 'MISSING'}',
      );

      if (googleAuth.idToken == null) {
        throw Exception(
          'Google Auth failed: idToken is null. Check Cloud Console Android Client SHA-1.',
        );
      }

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
