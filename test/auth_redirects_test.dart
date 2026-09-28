import 'package:flutter_test/flutter_test.dart';
import 'package:grow/core/constants/auth_redirects.dart';

void main() {
  test('email confirmation uses the registered Android callback', () {
    final landing = Uri.parse(AppAuthRedirects.emailConfirmationLanding);

    expect(landing.scheme, 'com.idealab.mec.grow');
    expect(landing.host, 'auth');
    expect(landing.path, '/callback');
    expect(landing.hasQuery, isFalse);
  });
}
