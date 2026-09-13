import 'package:flutter_test/flutter_test.dart';
import 'package:grow/core/router/app_router.dart';

void main() {
  group('redirectAuthenticatedEntryRoute', () {
    test(
      'sends authenticated login and registration entry routes to Splash',
      () {
        for (final path in ['/login', '/register', '/onboarding']) {
          expect(
            redirectAuthenticatedEntryRoute(hasSession: true, path: path),
            '/splash',
          );
        }
      },
    );

    test(
      'leaves Splash and application routes available to their own guards',
      () {
        expect(
          redirectAuthenticatedEntryRoute(hasSession: true, path: '/splash'),
          isNull,
        );
        expect(
          redirectAuthenticatedEntryRoute(hasSession: true, path: '/home'),
          isNull,
        );
      },
    );

    test('does not redirect unauthenticated entry routes', () {
      expect(
        redirectAuthenticatedEntryRoute(hasSession: false, path: '/login'),
        isNull,
      );
    });
  });
}
